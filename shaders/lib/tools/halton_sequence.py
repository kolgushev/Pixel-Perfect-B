from scipy.stats.qmc import Halton


def generate_coordinates():
    # Create a new Halton sequence generator
    hal = Halton(2)

    # Generate a 2D Halton sequence of 16 points
    seq = hal.random(n=16)

    # Print the sequence
    for coords in seq:
        print(coords[0] * 2 - 1, coords[1] * 2 - 1)


generate_coordinates()
