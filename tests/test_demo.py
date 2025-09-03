import io
import sys
import pytest
from unittest.mock import patch
from demo import calculate_area_circle, main

"""Unit tests for the demo module."""

def test_calculate_area_circle():
    """Test the calculate_area_circle function with various inputs."""
    assert calculate_area_circle(5) == 3.14 * 5 * 5
    assert calculate_area_circle(0) == 0
    assert calculate_area_circle(1) == 3.14


def test_calculate_area_circle_negative():
    """Test the calculate_area_circle function with a negative radius."""
    assert calculate_area_circle(-5) == 3.14 * 25

def test_main_function():
    """Test the main function's output."""
    # Test with radius = 5
    with patch('sys.stdout', new_callable=io.StringIO) as mock_stdout:
        main(5)
        expected_output = "The area of the circle is: 78.5\n"
        assert mock_stdout.getvalue() == expected_output
    
    # Test with radius = 0
    with patch('sys.stdout', new_callable=io.StringIO) as mock_stdout:
        main(0)
        expected_output = "The area of the circle is: 0.0\n"
        assert mock_stdout.getvalue() == expected_output