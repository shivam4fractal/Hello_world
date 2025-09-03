import sys

# Demo Code
"""
This module demonstrates basic Python print statements.
It prints "Hello World" and the result of a simple arithmetic operation.
"""

def calculate_area_circle(r):
    """Calculates the area of a circle."""
    return 3.14 * r * r

def main(r):
    """Main function to calculate and print the area of a circle."""
    result = calculate_area_circle(r)
    print("The area of the circle is:", result)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        RADIUS = float(sys.argv[1])
    else:
        RADIUS = 10
    main(RADIUS)