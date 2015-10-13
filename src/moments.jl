immutable Moments <: ContinuousMultivariateStreamStat
    m1::Float64
    m2::Float64
    m3::Float64
    m4::Float64
    n::Int64
end

Base.zero(::Type{Moments}) = Moments(0.0, 0.0, 0.0, 0.0, 0)

function Base.(:+)(stat::Moments, x::Real)
    n = stat.n + 1

    δ = x - stat.m1
    δ_n = δ / n
    δ_n_sq = δ_n * δ_n
    term1 = δ * δ_n * (n - 1)

    m1 = stat.m1 + δ_n
    m2 = stat.m2 + term1
    m3 = stat.m3 + term1 * δ_n * (n - 2) - 3 * δ_n * stat.m2
    m4 = stat.m4 + term1 * δ_n_sq * (n * n - 3 * n + 3) +
         6 * δ_n_sq * stat.m2 - 4 * δ_n * stat.m3

    return Moments(m1, m2, m3, m4, n)
end

nobs(stat::Moments) = stat.n

function state(stat::Moments)
    return (mean(stat), var(stat), StatsBase.skewness(stat), StatsBase.kurtosis(stat))
end

Base.copy(stat::Moments) = Moments(stat.m1, stat.m2, stat.m3, stat.m4, stat.n)

function Base.(:+)(a::Moments, b::Moments)
    n = a.n + b.n

    δ = b.m1 - a.m1
    δ2 = δ * δ
    δ3 = δ * δ2
    δ4 = δ2 * δ2

    m1 = (a.n * a.m1 + b.n * b.m1) / n

    m2 = a.m2 + b.m2 + δ2 * a.n * b.n / n

    m3 = a.m3 + b.m3 +
                  δ3 * a.n * b.n * (a.n - b.n) / (n * n)
    m3 += 3.0 * δ * (a.n * b.m2 - b.n * a.m2) / n

    m4 = a.m4 + b.m4 + δ4 * a.n * b.n *
                  (a.n * a.n - a.n * b.n + b.n * b.n) /
                  (n * n * n)
    m4 += 6.0 * δ2 * (a.n * a.n * b.m2 + b.n * b.n * a.m2) /
                   (n * n) +
                   4.0 * δ * (a.n * b.m3 - b.n * a.m3) / n

    return Moments(m1, m2, m3, m4, n)
end

function Base.show(io::IO, stat::Moments)
    m, v, s, k = state(stat)
    @printf(io, "Online Moments\n")
    @printf(io, " * Mean:     %f\n", m)
    @printf(io, " * Variance: %f\n", v)
    @printf(io, " * Skewness: %f\n", s)
    @printf(io, " * Kurtosis: %f\n", k)
    @printf(io, " * N:        %d\n", nobs(stat))
    return
end

Base.mean(stat::Moments) = stat.m1

Base.var(stat::Moments) = stat.m2 / (stat.n - 1)

Base.std(stat::Moments) = sqrt(var(stat))

StatsBase.skewness(stat::Moments) = sqrt(stat.n) * stat.m3 / stat.m2^1.5

StatsBase.kurtosis(stat::Moments) = stat.n * stat.m4 / (stat.m2 * stat.m2) - 3.0
