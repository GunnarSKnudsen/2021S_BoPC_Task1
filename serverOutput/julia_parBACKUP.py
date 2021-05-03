#! /usr/bin/env python

import numpy as np
import argparse
import time
from multiprocessing import Pool, TimeoutError


def compute_julia_set_sequential(xmin, xmax, ymin, ymax, im_width, im_height):

    zabs_max = 10
    c = complex(-0.1, 0.65)
    nit_max = 1000

    xwidth  = xmax - xmin
    yheight = ymax - ymin

    julia = np.zeros((im_width, im_height))
    for ix in range(im_width):
        for iy in range(im_height):
            nit = 0
            # Map pixel position to a point in the complex plane
            z = complex(ix / im_width * xwidth + xmin,
                        iy / im_height * yheight + ymin)
            # Do the iterations
            while abs(z) <= zabs_max and nit < nit_max:
                z = z**2 + c
                nit += 1
            ratio = nit / nit_max
            julia[ix,iy] = ratio

    return julia

def compute_julia_in_parallel(size, xmin, xmax, ymin, ymax, patch, nprocs):

    # replace the following code
    # with a parallel version
    julia_img = compute_julia_set_sequential(xmin, xmax, ymin, ymax, size, size)

    return julia_img

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--size", help="image size in pixels (square images)", type=int, default=500)
    parser.add_argument("--xmin", help="", type=float, default=-1.5)
    parser.add_argument("--xmax", help="", type=float, default=1.5)
    parser.add_argument("--ymin", help="", type=float, default=-1.5)
    parser.add_argument("--ymax", help="", type=float, default=1.5)
    parser.add_argument("--patch", help="patch size in pixels (square images)", type=int, default=20)
    parser.add_argument("--nprocs", help="number of workers", type=int, default=1)
    parser.add_argument("-o", help="output file")
    args = parser.parse_args()

    #print(args)

    stime = time.perf_counter()
    julia_img = compute_julia_in_parallel(
        args.size,
        args.xmin, args.xmax, 
        args.ymin, args.ymax, 
        args.patch,
        args.nprocs)
    rtime = time.perf_counter() - stime

    print(f"{args.size};{args.patch};{args.nprocs};{rtime}")

    if not args.o is None:
        import matplotlib.pyplot as plt
        import matplotlib.cm as cm
        fig, ax = plt.subplots()
        ax.imshow(julia_img, interpolation='nearest', cmap=plt.get_cmap("hot"))
        plt.savefig(args.o)
        plt.show()
