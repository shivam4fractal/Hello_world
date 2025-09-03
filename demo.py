"""
This module demonstrates basic Python print statements.
It prints "Hello from RDP" and "Inside Github IDE",
calculates the area of a circle.
"""

import sys

# Demo Code

print("Hello from RDP")
print("Inside Github IDE")


def calculate_area_circle(r):
    """Calculates the area of a circle."""
    return 3.14 * r * r


def main(r):
    """Main function to calculate and print the area of a circle."""
    result = calculate_area_circle(r)
    print("The area of the circle is: ", result)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        radius = float(sys.argv[1])
    else:
        radius = 10
    main(radius)