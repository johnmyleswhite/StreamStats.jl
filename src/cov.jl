type Covariance <: ContinuousUnivariateStreamStat
    x::Variance
    y::Variance
    sum_sqs::Float64
    n::Int
end

Covariance() = Covariance(Variance(), Variance(), 0.0, 0)

function update!(stat::Covariance, x::Real, y::Real)
    m_x = mean(stat.x)
    m_y = mean(stat.y)

    stat.n += 1
    stat.sum_sqs += (x - m_x) * (y - m_y) * ((stat.n - 1) / stat.n)

    update!(stat.x, x)
    update!(stat.y, y)

    return
end

nobs(stat::Covariance) = stat.n

Base.cov(stat::Covariance) = stat.sum_sqs / (stat.n - 1)
Base.cor(stat::Covariance) = cov(stat) / (std(stat.x) * std(stat.y))

state(stat::Covariance) = Base.cov(stat)

Base.copy(stat::Covariance) = Covariance(copy(stat.x), copy(stat.y), stat.sum_sqs, stat.n)

function Base.merge(a::Covariance, b::Covariance)
    merged = Covariance()

    merged.x = merge(a.x, b.x)
    merged.y = merge(a.y, b.y)
    merged.n = a.n + b.n

    δ_x = mean(b.x) - mean(a.x)
    δ_y = mean(b.y) - mean(a.y)

    merged.sum_sqs = a.sum_sqs + b.sum_sqs + (a.n * b.n * δ_x * δ_y) / merged.n

    return merged
end

function Base.empty!(stat::Covariance)
    empty!(stat.x)
    empty!(stat.y)
    stat.sum_sqs = 0.0
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Covariance)
    cov = cov(stat)
    cor = cor(stat)
    n = nobs(stat)
    @printf(io, "Online Covariance\n")
    @printf(io, " * Covariance: %f\n", cov)
    @printf(io, " * Correlation: %f\n", cor)
    @printf(io, " * N:          %d\n", n)
    return
end
