type Cov <: ContinuousUnivariateStreamStat
    x::Std
    y::Std
    sum_sqs::Float64
    n::Int
end

Cov() = Cov(Std(), Std(), 0.0, 0)

function update!(stat::Cov, x::Real, y::Real)
    m_x = mean(stat.x)
    m_y = mean(stat.y)

    stat.n += 1
    stat.sum_sqs += (x - m_x) * (y - m_y) * ((stat.n - 1) / stat.n)

    update!(stat.x, x)
    update!(stat.y, y)

    return
end

nobs(stat::Cov) = stat.n

state(stat::Cov) = stat.sum_sqs / (stat.n - 1)

Base.copy(stat::Cov) = Cov(copy(stat.x), copy(stat.y), stat.sum_sqs, stat.n)

function Base.merge(a::Cov, b::Cov)
    merged = Cov()

    merged.x = merge(a.x, b.x)
    merged.y = merge(a.y, b.y)
    merged.n = a.n + b.n

    δ_x = mean(b.x) - mean(a.x)
    δ_y = mean(b.y) - mean(a.y)

    merged.sum_sqs = a.sum_sqs + b.sum_sqs + (a.n * b.n * δ_x * δ_y) / merged.n

    return merged
end

function Base.empty!(stat::Cov)
    empty!(stat.x)
    empty!(stat.y)
    stat.sum_sqs = 0.0
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Cov)
    cov = state(stat)
    n = nobs(stat)
    @printf(io, "Online Covariance\n")
    @printf(io, " * Covariance: %f\n", cov)
    @printf(io, " * N:          %d\n", n)
    return
end
