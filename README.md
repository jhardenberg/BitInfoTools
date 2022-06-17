# BitInfoTools
## Command-line tool to implement BitInformation shaving of netcdf files

This small repository hosts a simple CLI tool in Julia which allows to shave/round mantissa bits in a netcdf file to explore different compression options. Based on the package [BitInformation.jl](https://github.com/milankl/BitInformation.jl) and on the ideas in [Klöwer et al. 2021](https://www.nature.com/articles/s43588-021-00156-2).

It also contains addirional tools and scripts to explore the impact of this form of compression on various climate diagnostics.


## CLI tool

    usage: shave.jl [-b BITS] [-p PERCENTAGE] [-d DIM] [-s] [-f] [-t TRIM] infile var

For example:

    shave.jl tas.nc tas -d 2 -p 99.9 -f

Computes automatically the number of bits to preserve in the mantissa maintaining 99.9% of information and using halfshaving instead of the default rounding. Bits are considere adjacent in the second (lat) dimension.

NB: the calculation of preserved information is based on shaving/halfshaving, it is not exact for rounding.

    shave.jl tas.nc tas -b 10

Keep 10 bits of mantissa using rounding by default.

Full man page:

    usage: shave.jl [-b BITS] [-p PERCENTAGE] [-d DIM] [-s] [-f] [-t TRIM] [-h] infile var

    Remove false information setting to fixed value extra bits of mantissa,

    positional arguments:
       infile                The input file to shave
       var                   Input variable name (default: "")

    optional arguments:
       -b, --bits, --sbits BITS
                        Number of bits to maintain in the mantissa. If
                        not specified computed automatically based on
                        percentage of preserved information (type:
                        Int64, default: 0)
       -p, --percentage PERCENTAGE
                        Percentage of preserved information (type:
                        Float64, default: 99.0)
       -d, --dim, --dimension DIM
                        Dimension in which to estimate preserved
                        information (0 means average over all) (type:
                        Int64, default: 1)
       -s, --shave           Remove false information shaving extra bits
                        (instead of rounding)
       -f, --halfshave       Remove false information halfshaving extra
                        bits (instead of rounding)
       -t, --trim TRIM       Ignore the last TRIM bits when computing
                        preserved information. (type: Int64, default:
                        3)
       -h, --help            show this help message and exit
