"""A simple Streamlit app."""

import streamlit as st


def main():
    """Main function to run the Streamlit app."""
    st.title("My Streamlit App")
    st.write("Hello, world!")

    st.header("Hello, Streamlit!")
    st.write("This is a simple Calculator application.")

    radius = st.text_input("Enter the radius:")

    if st.button("Calculate Area"):
        from demo import calculate_area_circle

        area = calculate_area_circle(int(radius))
        st.write(f"The area of the circle with radius {radius} is {area}.")


if __name__ == "__main__":
    main()