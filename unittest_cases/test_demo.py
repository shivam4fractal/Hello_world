import unittest
from demo import calculate_area_circle

class TestDemo(unittest.TestCase):

    def test_calculate_area_of_circle_1(self):
        # Test the area calculation with a radius of 10
        self.assertEqual(calculate_area_circle(10), 314.0)
        # Test the area calculation with a radius of 0
    def test_calculate_area_of_circle_2(self):

        self.assertEqual(calculate_area_circle(0), 0.0)
    def test_calculate_area_of_circle_3(self):
        
        # Test the area calculation with a negative radius
        self.assertEqual(calculate_area_circle(-5), 78.5)

if __name__ == '__main__':
    unittest.main()