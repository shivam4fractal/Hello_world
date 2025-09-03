import streamlit as st
from demo import calculate_area_circle

st.header("Hello, Streamlit!")
st.write("This is a simple Calculator application.")


radius = st.text_input("Enter the radius:")

if st.button("Calculate Area"):

    area = calculate_area_circle(int(radius))
    st.write(f"The area of the circle with radius {radius} is {area}.")