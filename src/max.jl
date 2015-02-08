type Max <: ContinuousUnivariateStreamStat
    m::Float64
    n::Int
end

Max() = Max(-Inf, 0)

function update!(stat::Max, x::Real)
    stat.n += 1
    stat.m = max(stat.m, x)
    return
end

state(stat::Max) = stat.m

nobs(stat::Max) = stat.n

Base.copy(stat::Max) = Max(stat.m, stat.n)

function Base.merge(a::Max, b::Max)
    m = max(a.m, b.m)
    n = a.n + b.n
    return Max(m, n)
end

function Base.empty!(stat::Max)
    stat.m = -Inf
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Max)
    m = state(stat)
    n = nobs(stat)
    @printf(io, "Online Max\n")
    @printf(io, " * Max:  %f\n", m)
    @printf(io, " * N:    %d\n", n)
    return
end
