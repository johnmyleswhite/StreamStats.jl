immutable ImmMean <: ContinuousUnivariateStreamStat
    m::Float64
    n::Int
end

ImmMean() = ImmMean(0.0, 0)

function update(stat::ImmMean, x::Real)
    α = 1 / (stat.n + 1)
    return ImmMean((1 - α) * stat.m + α * x, stat.n + 1)
end

Base.mean(stat::ImmMean) = stat.m

state(stat::ImmMean) = Base.mean(stat)

nobs(stat::ImmMean) = stat.n

Base.copy(stat::ImmMean) = ImmMean(stat.m, stat.n)

function Base.merge(a::ImmMean, b::ImmMean)
    m1, m2 = a.m, b.m
    n1, n2 = a.n, b.n
    m = (n1 / (n1 + n2)) * m1 + (n2 / (n1 + n2)) * m2
    n = n1 + n2
    return ImmMean(m, n)
end

# function Base.empty!(stat::ImmMean)
#     stat.m = 0.0
#     stat.n = 0
#     return
# end

function Base.show(io::IO, stat::ImmMean)
    m = mean(stat)
    n = nobs(stat)
    @printf(io, "Online ImmMean\n")
    @printf(io, " * ImmMean: %f\n", m)
    @printf(io, " * N:    %d\n", n)
    return
end
