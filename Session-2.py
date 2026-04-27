# Databricks notebook source
# COMMAND ----------
# ── Cluster warm-up — always the first Spark call after a restart ─────────────
# After dbutils.library.restartPython(), the Spark cluster may be cold.
# Running a trivial SQL query wakes it up so that the first real
# Delta or Spark operation does not time out.
#
# WHY THIS MATTERS:
#   DeltaTable operations called on a cold cluster can hang for
#   30-90 seconds or raise a timeout error. This one-liner
#   eliminates that risk for all subsequent cells.
import time
t0 = time.time()
_ = spark.sql('SELECT current_timestamp() AS ts').collect()
print(f'Cluster live  ({round(time.time() - t0, 1)}s)')
print(f'Spark version : {spark.version}')

# COMMAND ----------

# COMMAND ----------
# ── All configuration in ONE cell ─────────────────────────────────────────────
# PRODUCTION BEST PRACTICE:
#   Every constant lives here. If a path, name, or threshold
#   changes, you change it in one place and re-run. Nothing
#   is scattered across 20 cells.

# Workspace / storage
CATALOG              = 'hive_metastore'          # change if using Unity Catalog
DATABASE             = 'mlops_session1'           # created by this notebook
DELTA_RAW_PATH       = 'dbfs:/FileStore/mlops_s1/raw_retail'
DELTA_FEATURES_PATH  = 'dbfs:/FileStore/mlops_s1/features'
SCORES_PATH          = 'dbfs:/FileStore/mlops_s1/churn_scores'

# MLflow
EXPERIMENT           = '/Shared/mlops_s1_churn'  # MLflow experiment path
MODEL_NAME           = 'retail_churn_s1'          # Model Registry name

# Feature column list — single source of truth used in training and inference
FEATURE_COLS = [
    'recency_days', 'frequency', 'monetary_total',
    'avg_invoice_value', 'avg_unit_price', 'unique_products',
    'purchase_days', 'total_quantity',
    'avg_items_per_invoice', 'spend_per_day',
]
TARGET_COL           = 'Churn'

# Reproducibility — same seed = same train/test split every time
RANDOM_STATE         = 42

# Data version — increment this number each time the raw data is reloaded.
# It is logged with every MLflow run so you can always trace which
# version of data produced which model.
DATA_VERSION         = 1

print(f'Database         : {DATABASE}')
print(f'MLflow experiment: {EXPERIMENT}')
print(f'Model name       : {MODEL_NAME}')
print(f'Feature columns  : {len(FEATURE_COLS)}')
print(f'Random state     : {RANDOM_STATE}')

# COMMAND ----------

# COMMAND ----------
# ── Create the Spark database and DBFS folders ────────────────────────────────
# IF NOT EXISTS makes this cell idempotent — safe to re-run the
# entire notebook from scratch without errors.
spark.sql(f'CREATE DATABASE IF NOT EXISTS {DATABASE}')
spark.sql(f'USE {DATABASE}')

dbutils.fs.mkdirs('dbfs:/FileStore/mlops_s1/raw_retail')
dbutils.fs.mkdirs('dbfs:/FileStore/mlops_s1/features')
dbutils.fs.mkdirs('dbfs:/FileStore/mlops_s1/churn_scores')

print(f"Database '{DATABASE}' ready.")
print('DBFS folders created (or already exist).')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# PART 1: Understanding Label Leakage
#
# Label leakage is the single most common ML error.
# It always produces suspiciously perfect metrics.
# ============================================================

import pandas as pd
import numpy as np

url = 'https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/retail-data/by-day/2010-12-01.csv'
df_orig = pd.read_csv(url).dropna()

# THE BROKEN APPROACH — label is a direct function of the features
df_orig['Churn_WRONG'] = (
    (df_orig['Quantity'] < 0) | (df_orig['UnitPrice'] > 100)
).astype(int)

print('=' * 55)
print('ORIGINAL NOTEBOOK — LABEL LEAKAGE DEMONSTRATION')
print('=' * 55)
print(f'\nLabel distribution (WRONG):')
print(df_orig['Churn_WRONG'].value_counts().to_string())
print('\nSample rows where Churn_WRONG = 1:')
print(df_orig[df_orig['Churn_WRONG'] == 1][['Quantity', 'UnitPrice', 'Churn_WRONG']].head(5).to_string())
print()
print('ROOT CAUSE: Every row with Churn=1 has Quantity<0 OR UnitPrice>100.')
print('The model is asked to predict a label computed FROM its own features.')
print('It achieves 100% accuracy by learning the rule, not the behaviour.')
print()
print('FIX: Compute the label from a DIFFERENT time period than the features.')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# CORRECT CHURN DEFINITION — temporal separation
#
# A churned customer is one who was active in a reference
# period but did NOT return in the following label period.
#
# REFERENCE PERIOD  : December 2010  → compute features here
# LABEL PERIOD      : January 2011   → compute churn label here
#
# The model trains on December behaviour to predict
# January return. It never sees January data during training.
# This is correct temporal separation — no leakage.
# ============================================================

print('CORRECT CHURN DEFINITION')
print('-' * 45)
print('Churn = 1  : bought in December, did NOT return in January')
print('Churn = 0  : bought in December AND returned in January')
print()
print('Features  →  computed from DECEMBER 2010 data only')
print('Label     →  computed from JANUARY 2011 data only')
print()
print('The model cannot see January during training. No leakage.')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# PART 2: Load multi-day data from GitHub
#
# WHY MULTIPLE DAYS?
#   The original notebook used a single day (2010-12-01.csv),
#   giving only 1,968 rows. We load 9 days of December 2010
#   as the reference period and 9 days of January 2011 as
#   the label period. This gives us:
#     - Enough customers for a meaningful train/test split
#     - True temporal separation between features and labels
#
# VARIABLE NAMING:
#   df_ref_raw  = December 2010 = reference period (features come from here)
#   df_lbl_raw  = January  2011 = label period    (churn label comes from here)
# ============================================================

import pandas as pd
import requests

BASE_URL = 'https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/retail-data/by-day'

REF_FILES = [
    '2010-12-01.csv', '2010-12-02.csv', '2010-12-03.csv',
    '2010-12-05.csv', '2010-12-06.csv', '2010-12-07.csv',
    '2010-12-08.csv', '2010-12-09.csv', '2010-12-10.csv',
]
LBL_FILES = [
    '2011-01-04.csv', '2011-01-05.csv', '2011-01-06.csv',
    '2011-01-07.csv', '2011-01-09.csv', '2011-01-10.csv',
    '2011-01-11.csv', '2011-01-12.csv', '2011-01-13.csv',
]


def load_files(file_list, period_label):
    """Download a list of daily CSV files from GitHub and concatenate them."""
    frames = []
    for fname in file_list:
        try:
            df_day = pd.read_csv(f'{BASE_URL}/{fname}')
            df_day['_source_file'] = fname
            frames.append(df_day)
        except Exception as e:
            print(f'  Skipping {fname}: {e}')
    combined = pd.concat(frames, ignore_index=True)
    print(f'  {period_label}: {len(combined):,} rows from {len(frames)} files')
    return combined


print('Loading reference period — December 2010 (features)...')
df_ref_raw = load_files(REF_FILES, 'December 2010')

print('Loading label period    — January 2011  (churn label)...')
df_lbl_raw = load_files(LBL_FILES, 'January 2011')

print(f'\nTotal rows: reference={len(df_ref_raw):,}  label={len(df_lbl_raw):,}')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# Explicit 6-step data cleaning with row-level reporting
#   Step 1 alone removes ~9,000 rows (35% of the data).
#   Without explicit reporting, this loss is invisible.
# ============================================================

def clean_retail_data(df, name):
    """Clean retail transaction data with explicit per-step reporting."""
    original_count = len(df)
    report = []

    # Step 1: Drop rows where CustomerID is null
    #   These rows cannot be linked to any customer — useless for churn.
    df = df.dropna(subset=['CustomerID'])
    report.append(('Null CustomerID              ', original_count - len(df)))

    # Step 2: Convert column types safely
    #   Coerce errors to NaN rather than raising — Step 3 removes them.
    df['CustomerID']  = df['CustomerID'].astype(int).astype(str)
    df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])
    df['Quantity']    = pd.to_numeric(df['Quantity'],  errors='coerce')
    df['UnitPrice']   = pd.to_numeric(df['UnitPrice'], errors='coerce')

    # Step 3: Drop rows where numeric conversion produced NaN
    before = len(df)
    df = df.dropna(subset=['Quantity', 'UnitPrice'])
    report.append(('Bad numeric values           ', before - len(df)))

    # Step 4: Remove cancellations (InvoiceNo starts with 'C')
    #   Cancellations have negative Quantity and would distort all RFM features.
    before = len(df)
    df = df[~df['InvoiceNo'].astype(str).str.startswith('C')]
    report.append(('Cancellations (InvoiceNo=C)  ', before - len(df)))

    # Step 5: Remove rows with zero or negative UnitPrice
    #   Free samples, adjustments, and data errors — not real purchases.
    before = len(df)
    df = df[df['UnitPrice'] > 0]
    report.append(('Zero/negative UnitPrice      ', before - len(df)))

    # Step 6: Remove rows with zero or negative Quantity
    before = len(df)
    df = df[df['Quantity'] > 0]
    report.append(('Zero/negative Quantity       ', before - len(df)))

    # Derive TotalAmount for use in feature engineering
    df['TotalAmount'] = df['Quantity'] * df['UnitPrice']

    print(f'Cleaning report: {name}')
    print(f'  Original rows   : {original_count:>7,}')
    for step, removed in report:
        print(f'  Removed ({step}): {removed:>5,}')
    print(f'  Final rows      : {len(df):>7,}')
    print(f'  Unique customers: {df["CustomerID"].nunique():>6,}')
    print()

    return df.reset_index(drop=True)


df_ref = clean_retail_data(df_ref_raw, 'December 2010 (reference)')
df_lbl = clean_retail_data(df_lbl_raw, 'January 2011  (label)')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# Save cleaned data to Delta Lake
#
# Why Delta Lake, not CSV:
#   1. ACID transactions  : no partial writes, no corrupt files
#   2. Time-travel        : query any past version by number
#   3. Schema enforcement : wrong column types are rejected
#   4. Lineage            : every write is logged with timestamp
#
# We record the Delta version number and log it with every
# MLflow run. Six months from now, anyone can reproduce the
# exact training data with:
#   spark.read.format('delta').option('versionAsOf', N).load(path)
# ============================================================

# Convert pandas → Spark and write to Delta
spark.createDataFrame(df_ref).write \
    .format('delta').mode('overwrite') \
    .option('overwriteSchema', 'true') \
    .save(DELTA_RAW_PATH + '/reference')

spark.createDataFrame(df_lbl).write \
    .format('delta').mode('overwrite') \
    .option('overwriteSchema', 'true') \
    .save(DELTA_RAW_PATH + '/label')

# Read Delta version using SQL — avoids cold-cluster hang from DeltaTable.forPath()
ref_version = spark.sql(
    f"DESCRIBE HISTORY delta.`{DELTA_RAW_PATH}/reference`"
).select('version').first()[0]

lbl_version = spark.sql(
    f"DESCRIBE HISTORY delta.`{DELTA_RAW_PATH}/label`"
).select('version').first()[0]

print(f'Reference period Delta version : {ref_version}')
print(f'Label period    Delta version  : {lbl_version}')
print()
print('Time-travel read example:')
print(f'  spark.read.format("delta")')
print(f'       .option("versionAsOf", {ref_version})')
print(f'       .load("{DELTA_RAW_PATH}/reference")')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# Data validation — 5 quality checks before any training
#
#   Never train on data that has not been validated.
#   If any check fails, raise ValueError and stop the pipeline.
#   A failure here prevents any downstream task from running.
# ============================================================

def validate_dataset(df, name, min_rows=500, min_customers=100):
    """Run 5 data quality checks. Raises ValueError if any check fails."""
    errors = []

    # Check 1: Minimum row count
    if len(df) < min_rows:
        errors.append(f'Too few rows: {len(df)} < {min_rows}')

    # Check 2: Minimum unique customers
    n_customers = df['CustomerID'].nunique()
    if n_customers < min_customers:
        errors.append(f'Too few customers: {n_customers} < {min_customers}')

    # Check 3: No nulls in critical columns
    for col in ['CustomerID', 'InvoiceDate', 'Quantity', 'UnitPrice', 'TotalAmount']:
        nulls = df[col].isnull().sum()
        if nulls > 0:
            errors.append(f'Null values in {col}: {nulls}')

    # Check 4: TotalAmount must be positive
    neg = (df['TotalAmount'] <= 0).sum()
    if neg > 0:
        errors.append(f'Non-positive TotalAmount rows: {neg}')

    # Check 5: InvoiceDate must be datetime
    if not pd.api.types.is_datetime64_any_dtype(df['InvoiceDate']):
        errors.append('InvoiceDate is not datetime type')

    print(f'Data Validation: {name}')
    if errors:
        for err in errors:
            print(f'  FAIL: {err}')
        raise ValueError(f'Validation failed for {name}: {errors}')

    print(f'  All checks PASSED')
    print(f'  Rows: {len(df):,}  |  Customers: {n_customers:,}')
    print(f'  Date range  : {df["InvoiceDate"].min().date()} to {df["InvoiceDate"].max().date()}')
    print(f'  TotalAmount : £{df["TotalAmount"].min():.2f} – £{df["TotalAmount"].max():.2f}')
    print()


validate_dataset(df_ref, 'December 2010 (reference)')
validate_dataset(df_lbl, 'January 2011  (label)')

# COMMAND ----------

# COMMAND ----------
# ============================================================
# PART 3: Build the churn label — correct, no leakage
#
# COHORT  : every customer who bought in December 2010
# LABEL   : did they return in January 2011?
#             0 = returned  (not churned)
#             1 = did not return (churned)
#
# CRITICAL: the label is derived from JANUARY data.
#           The features (next cell) are derived from DECEMBER data.
#           The two sets of columns never overlap. No leakage.
# ============================================================

ref_customers = set(df_ref['CustomerID'].unique())
lbl_customers = set(df_lbl['CustomerID'].unique())

labels = pd.DataFrame({'CustomerID': list(ref_customers)})
labels['Churn'] = labels['CustomerID'].apply(
    lambda cid: 0 if cid in lbl_customers else 1
)

print('Churn label distribution (no leakage):')
print(labels['Churn'].value_counts().to_string())
churn_rate = labels['Churn'].mean()
print(f'\nChurn rate: {churn_rate:.1%}')
print()
print('Features come from December 2010. Label comes from January 2011.')
print('The model predicts future behaviour from past behaviour. No leakage.')

# COMMAND ----------

# COMMAND ----------
# All features come from December 2010 (df_ref) only.
# Not a single column from January is used here.
#
# RFM FEATURES (classic marketing framework):
#   Recency   — how recently did they buy? (lower = more recent)
#   Frequency — how many distinct invoices? (higher = more engaged)
#   Monetary  — total spend in the period   (higher = more valuable)
#
# BEHAVIOURAL FEATURES:
#   avg_invoice_value    — average basket size in GBP
#   avg_unit_price       — premium vs budget buyer signal
#   unique_products      — product variety = breadth of engagement
#   purchase_days        — spread of buying across the month
#   total_quantity       — raw volume of items bought
#   avg_items_per_invoice— items per visit
#   spend_per_day        — purchasing intensity

REF_DATE = pd.Timestamp('2010-11-30')   # reference point for recency

features = (
    df_ref.groupby('CustomerID')
    .agg(
        recency_days      = ('InvoiceDate', lambda x: (REF_DATE - x.max()).days),
        frequency         = ('InvoiceNo',   'nunique'),
        monetary_total    = ('TotalAmount',  'sum'),
        avg_invoice_value = ('TotalAmount',  'mean'),
        avg_unit_price    = ('UnitPrice',    'mean'),
        unique_products   = ('StockCode',    'nunique'),
        purchase_days     = ('InvoiceDate',  lambda x: x.dt.date.nunique()),
        total_quantity    = ('Quantity',     'sum'),
    )
    .reset_index()
)

# Derived features (built from the grouped aggregations)
features['avg_items_per_invoice'] = features['total_quantity'] / features['frequency']
features['spend_per_day']         = features['monetary_total'] / (features['purchase_days'] + 1)

print(f'Feature matrix shape : {features.shape}')
print(f'Feature columns      : {list(features.columns[1:])}')

# COMMAND ----------

# COMMAND ----------
# ── Merge, stratified split, save features to Delta ───────────────────────────

from sklearn.model_selection import train_test_split

# Merge features with labels on CustomerID
df_model = features.merge(labels, on='CustomerID', how='inner')
print(f'Model dataset shape : {df_model.shape}')
print(f'Churn rate          : {df_model[TARGET_COL].mean():.1%}')

X = df_model[FEATURE_COLS]
y = df_model[TARGET_COL]

# stratify=y preserves the churn ratio in both train and test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=RANDOM_STATE, stratify=y,
)

print(f'\nTrain: {len(X_train):,} rows  ({y_train.mean():.1%} churn)')
print(f'Test : {len(X_test):,} rows  ({y_test.mean():.1%} churn)')

# Save feature table to Delta and record the version for MLflow
spark.createDataFrame(df_model).write \
    .format('delta').mode('overwrite') \
    .option('overwriteSchema', 'true') \
    .save(DELTA_FEATURES_PATH)

# Read version via SQL to avoid cold-cluster hang
FEATURES_VERSION = spark.sql(
    f"DESCRIBE HISTORY delta.`{DELTA_FEATURES_PATH}`"
).select('version').first()[0]

print(f'\nFeature table Delta version : {FEATURES_VERSION}')
print('This version will be logged with every MLflow run.')

# COMMAND ----------

# COMMAND ----------
# ── SMOTE — correct class imbalance handling ───────────────────────────────────
#
# Why SMOTE must come AFTER the split:
#   SMOTE creates synthetic minority-class samples by interpolating
#   between real samples. If you apply it BEFORE splitting, synthetic
#   versions of test-set samples end up in the training set. The model
#   "remembers" test patterns and evaluation is dishonest.
#
#   CORRECT: split first → SMOTE on training set only.
#   The test set is NEVER touched. It stays as real, unseen data.

!pip install imbalanced-learn
from imblearn.over_sampling import SMOTE


print('Before SMOTE (training set only):')
print(y_train.value_counts().to_string())

smote = SMOTE(random_state=RANDOM_STATE, k_neighbors=5)
X_train_bal, y_train_bal = smote.fit_resample(X_train, y_train)

print('\nAfter SMOTE (training set balanced):')
print(pd.Series(y_train_bal).value_counts().to_string())

print('\nTest set (UNCHANGED — real distribution, honest evaluation):')
print(y_test.value_counts().to_string())

# COMMAND ----------

# COMMAND ----------
# ============================================================
# PART 4: MLflow Experiment Setup
#
# MLflow Tracking stores:
#   Experiments : a folder grouping related runs
#   Runs        : one execution of training code
#   Parameters  : what you CONFIGURED before training
#   Metrics     : what you MEASURED after training
#   Tags        : searchable labels (team, session, model type)
#   Artifacts   : files stored with the run (model pkl, plots)
#
# On Databricks the MLflow server is fully managed.
# No configuration or URL needed — just set the experiment path.
# ============================================================

import mlflow
import mlflow.sklearn
from mlflow.tracking import MlflowClient

# Point all MLflow operations at the Databricks-managed registry
mlflow.set_registry_uri('databricks')

# Create the experiment if it does not exist
mlflow.set_experiment(EXPERIMENT)
experiment = mlflow.get_experiment_by_name(EXPERIMENT)

# Single client instance, used for registry operations in later cells
client = MlflowClient(registry_uri='databricks')

print(f'Experiment ID   : {experiment.experiment_id}')
print(f'Experiment name : {experiment.name}')
print(f'Artifact root   : {experiment.artifact_location}')
print()
print('Navigate to: Experiments (left sidebar) → mlops_s1_churn')
print('It is empty now. A new run appears after the next cell executes.')

# COMMAND ----------

# COMMAND ----------
# ── Run 1: Logistic Regression baseline ───────────────────────────────────────
#
# The four things logged in every production run:
#
#   PARAMETERS  = what you configured   (hyperparameters + data version)
#   METRICS     = what you measured     (AUC, F1, precision, recall)
#   TAGS        = searchable labels     (team, session, model family)
#   ARTIFACTS   = files                 (model pkl, feature_names.txt)
#
# WHY A PIPELINE (StandardScaler + LogisticRegression):
#   The scaler lives inside the model. At inference time you
#   cannot accidentally forget to scale. The model is self-contained.
#
# WHY roc_auc OVER accuracy:
#   With 78% churn, a model that always predicts "churn" gets
#   78% accuracy. AUC measures ranking quality, not label accuracy,
#   and is unaffected by class imbalance.

from mlflow.models import infer_signature
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.metrics import (
    accuracy_score, roc_auc_score, f1_score,
    precision_score, recall_score,
    average_precision_score, classification_report,
)

lr_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model',  LogisticRegression(
        C=1.0, class_weight='balanced',
        max_iter=500, random_state=RANDOM_STATE,
    )),
])

with mlflow.start_run(run_name='logistic_regression_baseline') as run:

    lr_pipeline.fit(X_train_bal, y_train_bal)
    y_pred      = lr_pipeline.predict(X_test)
    y_pred_prob = lr_pipeline.predict_proba(X_test)[:, 1]

    # -- PARAMETERS --
    mlflow.log_params({
        'model_type':       'LogisticRegression',
        'C':                1.0,
        'max_iter':         500,
        'class_weight':     'balanced',
        'scaler':           'StandardScaler',
        'smote_applied':    True,
        'random_state':     RANDOM_STATE,
        'feature_count':    len(FEATURE_COLS),
        'data_version':     DATA_VERSION,
        'features_delta_v': FEATURES_VERSION,
        'ref_delta_v':      ref_version,
        'ref_date':         str(REF_DATE.date()),
    })

    # -- METRICS --
    acc  = accuracy_score(y_test, y_pred)
    auc  = roc_auc_score(y_test, y_pred_prob)
    apr  = average_precision_score(y_test, y_pred_prob)
    f1   = f1_score(y_test, y_pred, zero_division=0)
    prec = precision_score(y_test, y_pred, zero_division=0)
    rec  = recall_score(y_test, y_pred, zero_division=0)

    mlflow.log_metrics({
        'accuracy':        round(acc,  4),
        'roc_auc':         round(auc,  4),
        'avg_precision':   round(apr,  4),
        'f1_score':        round(f1,   4),
        'precision':       round(prec, 4),
        'recall':          round(rec,  4),
        'train_size':      len(X_train_bal),
        'test_size':       len(X_test),
        'churn_rate_test': round(float(y_test.mean()), 4),
    })

    # -- TAGS --
    mlflow.set_tags({
        'team':         'mlops-training',
        'session':      'session-1',
        'model_family': 'linear',
        'dataset':      'uci_online_retail',
        'problem_type': 'binary_classification',
        'feature_set':  'rfm_v1',
        'smote':        'yes',
    })

    # -- ARTIFACTS --
    mlflow.log_text('\n'.join(FEATURE_COLS), 'feature_names.txt')
    signature = infer_signature(X_train_bal, lr_pipeline.predict_proba(X_train_bal)[:, 1])
    mlflow.sklearn.log_model(
        sk_model=lr_pipeline, name='model',
        signature=signature, input_example=X_test.head(5),
    )

    lr_run_id = run.info.run_id

print(f'Run ID      : {lr_run_id}')
print(f'ROC-AUC     : {auc:.4f}  (main metric — use this, not accuracy)')
print(f'Avg Prec    : {apr:.4f}')
print(f'F1          : {f1:.4f}')
print(f'Precision   : {prec:.4f}   Recall: {rec:.4f}')
print(f'\n{classification_report(y_test, y_pred, target_names=["No Churn", "Churn"])}')

# COMMAND ----------

# COMMAND ----------
# ── Runs 2–4: Random Forest (three configurations) ────────────────────────────
#
# Each configuration gets its own MLflow run with a descriptive name.
# The run name encodes the key hyperparameters so you can read the
# experiment table in the UI without clicking into each run.

from sklearn.ensemble import RandomForestClassifier

rf_configs = [
    {'n_estimators': 100, 'max_depth': 5,    'min_samples_leaf': 10},
    {'n_estimators': 200, 'max_depth': 8,    'min_samples_leaf': 5},
    {'n_estimators': 300, 'max_depth': None, 'min_samples_leaf': 2},
]

for cfg in rf_configs:
    run_name = f"rf_n{cfg['n_estimators']}_d{cfg['max_depth']}_leaf{cfg['min_samples_leaf']}"

    with mlflow.start_run(run_name=run_name) as run:

        rf = RandomForestClassifier(
            **cfg, class_weight='balanced',
            random_state=RANDOM_STATE, n_jobs=-1,
        )
        rf.fit(X_train_bal, y_train_bal)
        y_pred      = rf.predict(X_test)
        y_pred_prob = rf.predict_proba(X_test)[:, 1]

        metrics = {
            'accuracy':      round(accuracy_score(y_test, y_pred), 4),
            'roc_auc':       round(roc_auc_score(y_test, y_pred_prob), 4),
            'avg_precision': round(average_precision_score(y_test, y_pred_prob), 4),
            'f1_score':      round(f1_score(y_test, y_pred, zero_division=0), 4),
            'precision':     round(precision_score(y_test, y_pred, zero_division=0), 4),
            'recall':        round(recall_score(y_test, y_pred, zero_division=0), 4),
            'train_size':    len(X_train_bal),
            'test_size':     len(X_test),
        }
        mlflow.log_params({
            'model_type':       'RandomForest', **cfg,
            'class_weight':     'balanced',
            'smote_applied':    True,
            'random_state':     RANDOM_STATE,
            'feature_count':    len(FEATURE_COLS),
            'data_version':     DATA_VERSION,
            'features_delta_v': FEATURES_VERSION,
        })
        mlflow.log_metrics(metrics)
        mlflow.set_tags({
            'team': 'mlops-training', 'session': 'session-1',
            'model_family': 'tree', 'dataset': 'uci_online_retail',
            'problem_type': 'binary_classification',
            'feature_set': 'rfm_v1', 'smote': 'yes',
        })

        # Feature importance as a readable artifact
        fi_df = pd.DataFrame({'feature': FEATURE_COLS,
                              'importance': rf.feature_importances_})
        fi_df = fi_df.sort_values('importance', ascending=False)
        mlflow.log_text(fi_df.to_string(index=False), 'feature_importance.txt')
        mlflow.log_text('\n'.join(FEATURE_COLS), 'feature_names.txt')

        signature = infer_signature(X_train_bal, rf.predict_proba(X_train_bal)[:, 1])
        mlflow.sklearn.log_model(
            sk_model=rf, name='model',
            signature=signature, input_example=X_test.head(5),
        )

        print(f'  {run_name:<48} AUC={metrics["roc_auc"]:.4f}  F1={metrics["f1_score"]:.4f}')

print('\nAll Random Forest runs logged.')

# COMMAND ----------

# COMMAND ----------
# ── Runs 5–6: XGBoost (two configurations) ────────────────────────────────────
#
# XGBoost handles imbalance differently from Random Forest:
#   Random Forest: we used SMOTE to balance the training set.
#   XGBoost:       we use scale_pos_weight — a built-in parameter
#                  that tells the algorithm how imbalanced the data is.
#                  No synthetic samples are created.
#
# scale_pos_weight = count(negative class) / count(positive class)
#   in the ORIGINAL (pre-SMOTE) training data.
#   This is logged as a parameter so the run is reproducible.
!pip install xgboost
import xgboost as xgb

# Ratio of majority (no-churn) to minority (churn) in original training set
scale_pos_weight = float((y_train == 0).sum() / (y_train == 1).sum())

xgb_configs = [
    {'n_estimators': 100, 'max_depth': 4, 'learning_rate': 0.1,  'subsample': 0.8},
    {'n_estimators': 200, 'max_depth': 5, 'learning_rate': 0.05, 'subsample': 0.8},
]

for cfg in xgb_configs:
    run_name = f"xgb_n{cfg['n_estimators']}_d{cfg['max_depth']}_lr{cfg['learning_rate']}"

    with mlflow.start_run(run_name=run_name) as run:

        model = xgb.XGBClassifier(
            **cfg,
            scale_pos_weight=scale_pos_weight,
            eval_metric='logloss',
            random_state=RANDOM_STATE,
            n_jobs=-1,
        )
        # XGBoost uses original training data — scale_pos_weight handles the imbalance
        model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=False)

        y_pred      = model.predict(X_test)
        y_pred_prob = model.predict_proba(X_test)[:, 1]

        metrics = {
            'accuracy':      round(accuracy_score(y_test, y_pred), 4),
            'roc_auc':       round(roc_auc_score(y_test, y_pred_prob), 4),
            'avg_precision': round(average_precision_score(y_test, y_pred_prob), 4),
            'f1_score':      round(f1_score(y_test, y_pred, zero_division=0), 4),
            'precision':     round(precision_score(y_test, y_pred, zero_division=0), 4),
            'recall':        round(recall_score(y_test, y_pred, zero_division=0), 4),
            'train_size':    len(X_train),
            'test_size':     len(X_test),
        }
        mlflow.log_params({
            'model_type':         'XGBoost', **cfg,
            'scale_pos_weight':   round(scale_pos_weight, 2),
            'smote_applied':      False,
            'random_state':       RANDOM_STATE,
            'feature_count':      len(FEATURE_COLS),
            'data_version':       DATA_VERSION,
            'features_delta_v':   FEATURES_VERSION,
        })
        mlflow.log_metrics(metrics)
        mlflow.set_tags({
            'team': 'mlops-training', 'session': 'session-1',
            'model_family': 'boosting', 'dataset': 'uci_online_retail',
            'problem_type': 'binary_classification',
            'feature_set': 'rfm_v1', 'smote': 'no',
        })

        mlflow.log_text('\n'.join(FEATURE_COLS), 'feature_names.txt')
        signature = infer_signature(X_train, model.predict_proba(X_train)[:, 1])
        mlflow.sklearn.log_model(
            sk_model=model, name='model',
            signature=signature, input_example=X_test.head(5),
        )

        print(f'  {run_name:<48} AUC={metrics["roc_auc"]:.4f}  F1={metrics["f1_score"]:.4f}')

print('\nAll XGBoost runs logged.')

# COMMAND ----------

# COMMAND ----------
# ── Select the best run programmatically ──────────────────────────────────────
#
#   Never manually copy a run ID. Use mlflow.search_runs() to find
#   the best run by any metric. The code picks the winner regardless
#   of how many runs exist or what their IDs are.
#
#   In Session 4 (CI/CD) this becomes a pipeline task that runs
#   automatically after every retraining job.

all_runs = mlflow.search_runs(
    experiment_ids=[experiment.experiment_id],
    order_by=['metrics.roc_auc DESC'],
)

print('All runs ranked by ROC-AUC:')
print('-' * 75)
cols = ['tags.mlflow.runName', 'metrics.roc_auc',
        'metrics.avg_precision', 'metrics.f1_score', 'params.model_type']
print(all_runs[cols].to_string(index=False))

best_row    = all_runs.iloc[0]
best_run_id = best_row['run_id']
best_auc    = best_row['metrics.roc_auc']
best_model  = best_row['params.model_type']
best_metrics = {
    'roc_auc':       best_row['metrics.roc_auc'],
    'avg_precision': best_row['metrics.avg_precision'],
    'f1_score':      best_row['metrics.f1_score'],
}

print(f'\nBest run   : {best_run_id}')
print(f'Model type : {best_model}')
print(f'ROC-AUC    : {best_auc:.4f}')

# COMMAND ----------

# COMMAND ----------
# ── Quality gate — validate before registering ────────────────────────────────
#
#   A model must PASS minimum quality thresholds before it is
#   registered. If it fails, a ValueError stops the pipeline.
#   No bad model ever reaches the registry.
#
#   In Session 4 (CI/CD) this becomes an explicit pipeline task
#   that gates the entire promotion workflow.

QUALITY_GATE = {
    'roc_auc':       0.60,
    'avg_precision': 0.30,
    'f1_score':      0.30,
}

print('Quality Gate Check:')
print('-' * 50)
passed = True
for metric, threshold in QUALITY_GATE.items():
    actual = best_metrics[metric]
    status = 'PASS' if actual >= threshold else 'FAIL'
    if status == 'FAIL':
        passed = False
    print(f'  {metric:<20}: {actual:.4f}  (threshold: {threshold})  [{status}]')

if not passed:
    raise ValueError(
        'Quality gate FAILED. Model does not meet minimum thresholds. '
        'Retrain with better hyperparameters before registering.'
    )

print('\nAll quality gates PASSED. Proceeding to Model Registry.')

# COMMAND ----------

# COMMAND ----------
# ── Register the best model to the MLflow Model Registry ─────────────────────
#
# Stages vs Aliases:
#   Stages (None / Staging / Production / Archived) are the
#   classic MLflow registry API, used here for familiarity.
#
#   From Session 2 onwards we switch to Aliases
#   (client.set_registered_model_alias) which is the modern API
#   and does not trigger FutureWarning deprecation notices.
#
# WHAT REGISTERING DOES:
#   Creates a pointer from the registry to the model artefact
#   in DBFS. It does NOT copy the file. Version number is
#   auto-incremented each time the same model name is registered.

result = mlflow.register_model(
    model_uri=f'runs:/{best_run_id}/model',
    name=MODEL_NAME,
)
model_version = result.version
print(f'Registered: {MODEL_NAME} version {model_version}')

# Add a human-readable description to this version
client.update_model_version(
    name=MODEL_NAME,
    version=model_version,
    description=(
        f'Session 1 best model. {best_model}. '
        f'AUC={best_auc:.4f}. Features: RFM v1. '
        f'Run: {best_run_id[:16]}…'
    ),
)

# Transition to Staging — quality gate passed but not yet in production
# NOTE: transition_model_version_stage is the classic API (used here for
# familiarity). Session 2 uses the modern set_registered_model_alias().
client.transition_model_version_stage(
    name=MODEL_NAME,
    version=model_version,
    stage='Staging',
    archive_existing_versions=False,
)

print(f'Version {model_version} → Staging')
print()
print('Navigate to: Models (left sidebar) → retail_churn_s1')
print('You will see the version, stage, description, and lineage.')

# COMMAND ----------

# COMMAND ----------
# ── Load by stage and run inference on test profiles ──────────────────────────
#
# Load by STAGE not by run ID:
#
#   WRONG: mlflow.pyfunc.load_model(f'runs:/{run_id}/model')
#     Hardcodes a specific run. When a new model is promoted,
#     serving code must be edited — deployment risk.
#
#   CORRECT: mlflow.pyfunc.load_model(f'models:/{MODEL_NAME}/Staging')
#     Always resolves to whatever version is currently in Staging.
#     Promoting a new model = change the stage alias, not the code.

staging_model = mlflow.pyfunc.load_model(f'models:/{MODEL_NAME}/Staging')
sklearn_model = mlflow.sklearn.load_model(f'models:/{MODEL_NAME}/Staging')
print(f'Loaded: models:/{MODEL_NAME}/Staging')

# Five representative customer profiles
test_customers = pd.DataFrame([
    [2,  15, 1200.0, 80.0, 3.50, 25, 10, 180, 12.00, 120.0],
    [25,  2,   45.0, 22.5, 2.00,  8,  2,  20, 10.00,  15.0],
    [1,  30, 5600.0,186.7, 5.20, 60, 15, 850, 28.33, 350.0],
    [28,  1,   12.0, 12.0, 1.50,  3,  1,   8,  8.00,   6.0],
    [10,  8,  320.0, 40.0, 2.80, 18,  6,  90, 11.25,  45.7],
], columns=FEATURE_COLS)
profiles = ['Active customer', 'Infrequent customer', 'High-value customer',
            'About to churn', 'Medium customer']

predictions  = staging_model.predict(test_customers)
probabilities = sklearn_model.predict_proba(test_customers)

print('\nInference results:')
print('-' * 60)
for i, profile in enumerate(profiles):
    label = 'CHURN' if predictions[i] == 1 else 'RETAIN'
    prob  = probabilities[i][1]
    print(f'  {profile:<25}: {label}  (churn prob: {prob:.2%})')

# COMMAND ----------

# COMMAND ----------
# ── Batch score all customers and save to Delta ───────────────────────────────
#
#   In production this cell runs nightly. It scores every customer
#   and saves results to a Delta table. The CRM team reads from
#   this table each morning to prioritise retention outreach.
#
#   Every row includes model_name and model_version so you can
#   always trace any prediction back to the exact model that made it.

X_all       = df_model[FEATURE_COLS]
churn_probs = sklearn_model.predict_proba(X_all)[:, 1]
churn_preds = sklearn_model.predict(X_all)

scores_df = df_model[['CustomerID'] + FEATURE_COLS + [TARGET_COL]].copy()
scores_df['churn_probability'] = churn_probs
scores_df['churn_predicted']   = churn_preds
scores_df['risk_tier']         = pd.cut(
    churn_probs, bins=[0, 0.30, 0.60, 1.0],
    labels=['LOW', 'MEDIUM', 'HIGH'], include_lowest=True,
)
scores_df['scored_at']     = pd.Timestamp.now()
scores_df['model_name']    = MODEL_NAME
scores_df['model_version'] = model_version   # ties each row to registry version

spark.createDataFrame(scores_df).write \
    .format('delta').mode('overwrite') \
    .option('overwriteSchema', 'true') \
    .save(SCORES_PATH)

print('Batch scoring complete.')
print(f'  Customers scored : {len(scores_df):,}')
print(f'  Risk distribution:')
print(scores_df['risk_tier'].value_counts().to_string())
print(f'\nTop 5 highest-risk customers:')
top5 = scores_df.nlargest(5, 'churn_probability')[
    ['CustomerID', 'churn_probability', 'risk_tier', 'recency_days', 'frequency']
]
print(top5.to_string(index=False))
print(f'\nScores saved to: {SCORES_PATH}')
