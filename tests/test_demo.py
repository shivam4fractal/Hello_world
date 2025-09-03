import io
import sys
import pytest
from unittest.mock import patch
from demo import calculate_area_circle, main

def test_calculate_area_circle():
    """Test the calculate_area_circle function with various inputs."""
    # Test with radius = 0
    assert calculate_area_circle(0) == 0
    
    # Test with radius = 1
    assert pytest.approx(calculate_area_circle(1)) == 3.14
    
    # Test with radius = 2
    assert pytest.approx(calculate_area_circle(2)) == 12.56
    
    # Test with negative radius (though this might not be physically meaningful)
    assert pytest.approx(calculate_area_circle(-1)) == 3.14

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