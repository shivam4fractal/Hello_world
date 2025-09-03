"""Unit test cases for the demo module."""
import unittest
from demo import calculate_area_circle


"""Test case class for the demo module."""


class TestDemo(unittest.TestCase):
    """Test case class for the demo module."""

    def test_calculate_area_circle(self):
        """Test the calculate_area_circle function."""
        self.assertEqual(calculate_area_circle(5), 3.14 * 5 * 5)

    def test_calculate_area_circle_zero(self):
        """Test the calculate_area_circle function with zero radius."""
        self.assertEqual(calculate_area_circle(0), 0)

    def test_calculate_area_circle_one(self):
        """Test the calculate_area_circle function with radius one."""
        self.assertEqual(calculate_area_circle(1), 3.14)


if __name__ == '__main__':
    unittest.main()