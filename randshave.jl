"""Bitshaving for floats. Sets trailing bits to random digits.
`keepmask` is an unsigned integer with bits being `1` for bits to be kept,
and `0` for those that are shaved off."""
function randshave( x::T,
                keepmask::UIntT
                ) where {T<:Base.IEEEFloat,UIntT<:Unsigned}
    ui = reinterpret(UIntT,x)
    r = reinterpret(UIntT,rand(T))
    r &= ~keepmask
    ui &= keepmask              # set trailing bits to zero
    ui ⊻= r
    return reinterpret(T,ui)
end


"""Random bitshaving of a float `x` given `keepbits` the number of mantissa bits to keep
after shaving."""
function randshave(x::T,keepbits::Integer) where {T<:Base.IEEEFloat}
    return randshave(x,BitInformation.get_keep_mask(T,keepbits))
end


"""In-place version of `randshave` for any array `X` with floats as elements."""
function randshave!(X::AbstractArray{T},            # any array with element type T
                keepbits::Integer               # how many mantissa bits to keep
                ) where {T<:Base.IEEEFloat}     # constrain element type to Float16/32/64

    keep_mask = BitInformation.get_keep_mask(T,keepbits)       # mask to zero trailing mantissa bits

    @inbounds for i in eachindex(X)             # apply rounding to each element
        X[i] = randshave(X[i],keep_mask)
    end

    return X
end
