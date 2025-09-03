import sys
"""Basic Python Code for Docs edited"""
print("Hello from RDP")
print("Inside Github IDE")


def calculate_area_circle(r):
    return 3.14 * r * r

def main(r):
    result = calculate_area_circle(r)
    print("The area of the circle is: ", result)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        radius = float(sys.argv[1])
    else:
        radius = 10
    main(radius)