import sys

# Demo Code
"""
This module demonstrates basic Python print statements.
It prints "Hello World" and the result of a simple arithmetic operation.
"""

def calculate_area_circle(r):
    return 3.14 * r * r

def main(r):
    result = calculate_area_circle(r)
    print("The area of the circle is:", result)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        radius = float(sys.argv[1])
    else:
        radius = 10
    main(radius)