#!/usr/bin/env julia

using BitInformation
using NetCDF
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "infile"
            help = "The input file to shave"
            arg_type = AbstractString
            required = true
        "var"
            help = "Input variable name"
            arg_type = AbstractString
            default = ""
            required = true
        "--bits", "--sbits", "-b"
            help = "Number of bits to maintain in the mantissa. If not specified computed automatically based on percentage of preserved information"
            arg_type = Int
            default = 0
        "--percentage", "-p"
            help = "Percentage of preserved information"
            arg_type = Float64
            default = 99.
        "--dim", "--dimension", "-d"
            help = "Dimension in which to estimate preserved information (0 means average over all)"
            arg_type = Int
            default = 1
        "--shave", "-s"
            help = "Remove false information shaving extra bits (instead of rounding)"
            action = :store_true
        "--halfshave", "-f"
            help = "Remove false information halfshaving extra bits (instead of rounding)"
            action = :store_true
        "--trim", "-t"
            help = "Ignore the last TRIM bits when computing preserved information."
            arg_type = Int
            default = 3
    end

    s.description = "Remove false information setting to fixed value extra bits of mantissa, "
                    "following Klöwer et al. 2021"

    return parse_args(s)
end

args = parse_commandline()
fname = args["infile"]
var = args["var"]
nbits = args["bits"]
fshave = args["shave"]
fhshave = args["halfshave"]
perc = args["percentage"]/100
idim = args["dim"]
ntrim = args["trim"]

a = ncread(fname, var)

atype = typeof(a[1]) 

if atype == Float64
   nexp = 12
   ntotbits = 64
elseif atype == Float32
   nexp = 9
   ntotbits = 32
elseif atype == Float16
   nexp = 6
   ntotbits = 16
else
   print("Cannot work with data of type $atype\n")
   exit(0)
end

if nbits==0
   if idim==0
      ndim = length(size(a))
      I = zeros(ntotbits-ntrim) 
      for idim=1:ndim
         global I = I + bitinformation(a, dim=idim)[1:(ntotbits-ntrim)]
      end
      I = I / ndim
   else
      I = bitinformation(a, dim=idim)[1:(ntotbits-ntrim)]
   end
   nbits = sum(cumsum(I)/sum(I).<=perc)-nexp
   if nbits<0
      nbits = 0
   end
   print("Keeping $nbits mantissa bits\n")
end

if fshave
   shave!(a, nbits)
elseif fhshave
   halfshave!(a, nbits)
else
   round!(a, nbits)
end

ncwrite(a, fname, var)
