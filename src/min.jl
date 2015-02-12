type Min <: ContinuousUnivariateStreamStat
    m::Float64
    n::Int
end

Min() = Min(Inf, 0)

function update!(stat::Min, x::Real)
    stat.n += 1
    stat.m = min(stat.m, x)
    return
end

Base.minimum(stat::Min) = stat.m

state(stat::Min) = Base.minimum(stat)

nobs(stat::Min) = stat.n

Base.copy(stat::Min) = Min(stat.m, stat.n)

function Base.merge(a::Min, b::Min)
    m = min(a.m, b.m)
    n = a.n + b.n
    return Min(m, n)
end

function Base.empty!(stat::Min)
    stat.m = Inf
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Min)
    m = minimum(stat)
    n = nobs(stat)
    @printf(io, "Online Min\n")
    @printf(io, " * Min:  %f\n", m)
    @printf(io, " * N:    %d\n", n)
    return
end
