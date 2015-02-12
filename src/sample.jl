# Construct a sample using Reservoir sampling

type Sample{T} <: StreamStat
    sample::Vector{T}
    n::Int
end

Sample(T::DataType, k::Integer) = Sample(Array(T, k), 0)

function update!(stat::Sample, x::Any)
    k = length(stat.sample)

    stat.n += 1

    if stat.n <= k
        stat.sample[stat.n] = x
    else
       i = rand(1:stat.n)
       if i <= k
           stat.sample[i] = x
       end
    end

    return
end

# This should really return a Nullable
function state{T}(stat::Sample{T})
   if stat.n < length(stat.sample)
       return T[]
   else
       return stat.sample
   end
end

StatsBase.sample{T}(stat::Sample{T}) = state(stat)

nobs(stat::Sample) = stat.n

Base.copy(stat::Sample) = Sample(stat.sample, stat.n)

# TODO: Implement random mixture
# Base.merge(a::Std, b::Std) = Std(merge(a.var, b.var))

function Base.empty!(stat::Sample)
    empty!(stat.sample)
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Sample)
    @printf(io, "Online Random Sample\n")
    @printf(io, " * K: %d\n", length(stat.sample))
    @printf(io, " * N: %d\n", stat.n)
    return
end
