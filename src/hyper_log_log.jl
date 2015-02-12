if VERSION < v"0.4.0-"
    hash32(d::Any) = uint32(hash(d))
else
    hash32(d::Any) = hash(d) % Uint32
end

ρ(s::Uint32) = uint32(uint32(leading_zeros(s)) + 0x00000001)

function α(m::Uint32)
    if m == 0x00000010
        return 0.673
    elseif m == 0x00000020
        return 0.697
    elseif m == 0x00000040
        return 0.709
    else # if m >= uint32(128)
        return 0.7213 / (1 + 1.079 / m)
    end
end

type HyperLogLog
    m::Uint32
    M::Vector{Uint32}
    mask::Uint32
    altmask::Uint32
end

function HyperLogLog(b::Integer)
    if !(4 <= b <= 16)
        throw(ArgumentError("b must be an integer between 4 and 16"))
    end

    m = 0x00000001 << b

    M = zeros(Uint32, m)

    mask = 0x00000000
    for i in 1:(b - 1)
        mask |= 0x00000001
        mask <<= 1
    end
    mask |= 0x00000001

    altmask = ~mask

    return HyperLogLog(m, M, mask, altmask)
end

function Base.show(io::IO, counter::HyperLogLog)
    @printf(io, "A HyperLogLog counter w/ %d registers", int(counter.m))
    return
end

function update!(counter::HyperLogLog, v::Any)
    x = hash32(v)
    j = uint32((x & counter.mask) + 0x00000001)
    w = x & counter.altmask
    counter.M[j] = max(counter.M[j], ρ(w))
    return
end

function state(counter::HyperLogLog)
    S = 0.0

    for j in 1:counter.m
        S += 1 / (2^counter.M[j])
    end

    Z = 1 / S

    E = α(counter.m) * uint(counter.m)^2 * Z

    if E <= 5//2 * counter.m
        V = 0
        for j in 1:counter.m
            V += int(counter.M[j] == 0x00000000)
        end
        if V != 0
            E_star = counter.m * log(counter.m / V)
        else
            E_star = E
        end
    elseif E <= 1//30 * 2^32
        E_star = E
    else
        E_star = -2^32 * log(1 - E / (2^32))
    end

    return E_star
end

# TODO: Figure out details here
# function confint(counter::HyperLogLog)
#     e = estimate(counter)
#     delta = e * 1.04 / sqrt(counter.m)
#     return e - delta, e + delta
# end

function Base.copy(counter::HyperLogLog)
    return HyperLogLog(
        counter.m,
        copy(counter.M),
        counter.mask,
        counter.altmask,
    )
end
