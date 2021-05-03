#! /usr/bin/env python
from math import ceil

import numpy as np
import argparse
import time
from multiprocessing import Pool


def compute_julia_set_sequential(x_min, x_max, y_min, y_max, im_width, im_height):
    z_abs_max = 10
    c = complex(-0.1, 0.65)
    nit_max = 1000

    x_width = x_max - x_min
    y_height = y_max - y_min

    julia = np.zeros((im_width, im_height))
    for ix in range(im_width):
        for iy in range(im_height):
            nit = 0
            # Map pixel position to a point in the complex plane
            z = complex(ix / im_width * x_width + x_min,
                        iy / im_height * y_height + y_min)
            # Do the iterations<<<<<<<<<<<<<<<
            while abs(z) <= z_abs_max and nit < nit_max:
                z = z ** 2 + c
                nit += 1
            ratio = nit / nit_max
            julia[ix, iy] = ratio

    return julia


def compute_julia_in_parallel(size, x_min, x_max, y_min, y_max, patch, n_procs):
    # Define ranges that will be run in parallel
    number_of_iterations = ceil(size / patch)

    size_orig = size
    size = number_of_iterations * patch
    ratio = size/size_orig
    x_max = x_min + ratio * (x_max-x_min)
    y_max = y_min + ratio * (y_max-y_min)


    x_range = x_max - x_min
    y_range = y_max - y_min
    x_step = x_range / number_of_iterations
    y_step = y_range / number_of_iterations

    # Define the pool (as slide 9 in Lecture 2)
    pool = Pool(processes=n_procs)
    task_handles = []

    # As image is square, we can iterate through iterations
    # Could (Should?) probably have iterated with a stepsize of "patch",
    # but I didn't, and too lazy to rework the math now
    for x_id in range(0, number_of_iterations, 1):
        for y_id in range(0, number_of_iterations, 1):
            # Calculate parameters and metadata
            x_min_parallel = x_min + (x_id + 0) * x_step
            x_max_parallel = x_min + (x_id + 1) * x_step
            y_min_parallel = y_min + (y_id + 0) * y_step
            y_max_parallel = y_min + (y_id + 1) * y_step

            # Define task to be run by thread
            t = pool.apply_async(compute_julia_set_sequential, (x_min_parallel
                                                                , x_max_parallel
                                                                , y_min_parallel
                                                                , y_max_parallel
                                                                , patch
                                                                , patch
                                                                )
                                 )
            # And append to the pool
            task_handles.append(t)

    # Wait for workers:
    pool.close()

    # Collect the results:
    results = np.array(list(map(lambda x: x.get(), task_handles)))

    # Join all:
    pool.join()

    # Reshape to image in correct order.
    # Nifty trick in reshaping in 4 dimensions is found in comment
    # under https://stackoverflow.com/questions/13990465/3d-numpy-array-to-2d
    (n, n_rows, n_cols) = results.shape
    h = size
    w = size

    julia_img = results.reshape(h // n_rows, -1, n_rows, n_cols).swapaxes(1, 2).reshape(h, w)

    julia_img_cut = julia_img[:size_orig, :size_orig]
    return julia_img_cut


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

    # print(args)

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

        fig, ax = plt.subplots()
        ax.imshow(julia_img, interpolation='nearest', cmap=plt.get_cmap("hot"))
        plt.savefig(args.o)
        plt.show()
