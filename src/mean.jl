type Mean <: ContinuousUnivariateStreamStat
    m::Float64
    n::Int
end

Mean() = Mean(0.0, 0)

function update!(stat::Mean, x::Real)
    stat.n += 1
    α = 1 / stat.n
    stat.m = (1 - α) * stat.m + α * x
    return
end

Base.mean(stat::Mean) = stat.m

state(stat::Mean) = Base.mean(stat)

nobs(stat::Mean) = stat.n

Base.copy(stat::Mean) = Mean(stat.m, stat.n)

function Base.merge(a::Mean, b::Mean)
    m1, m2 = a.m, b.m
    n1, n2 = a.n, b.n
    m = (n1 / (n1 + n2)) * m1 + (n2 / (n1 + n2)) * m2
    n = n1 + n2
    return Mean(m, n)
end

function Base.empty!(stat::Mean)
    stat.m = 0.0
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Mean)
    m = mean(stat)
    n = nobs(stat)
    @printf(io, "Online Mean\n")
    @printf(io, " * Mean: %f\n", m)
    @printf(io, " * N:    %d\n", n)
    return
end
