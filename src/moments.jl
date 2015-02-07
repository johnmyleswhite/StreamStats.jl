type Moments <: ContinuousMultivariateStreamStat
    m1::Float64
    m2::Float64
    m3::Float64
    m4::Float64
    n::Int
end

Moments() = Moments(0.0, 0.0, 0.0, 0.0, 0)

function update!(stat::Moments, x::Real)
    stat.n += 1

    n = stat.n

    δ = x - stat.m1
    δ_n = δ / stat.n
    δ_n_sq = δ_n * δ_n
    term1 = δ * δ_n * (n - 1)

    stat.m1 += δ_n
    stat.m4 += term1 * δ_n_sq * (n * n - 3 * n + 3) +
               6 * δ_n_sq * stat.m2 - 4 * δ_n * stat.m3
    stat.m3 += term1 * δ_n * (n - 2) - 3 * δ_n * stat.m2
    stat.m2 += term1

    return
end

function state(stat::Moments)
    m = stat.m1
    v = stat.m2 / (stat.n - 1)
    s = sqrt(stat.n) * stat.m3 / stat.m2^1.5
    k = stat.n * stat.m4 / (stat.m2 * stat.m2) - 3.0

    return (m, v, s, k)
end

nobs(stat::Moments) = stat.n

Base.copy(stat::Moments) = Moments(stat.m1, stat.m2, stat.m3, stat.m4, stat.n)

function Base.merge(a::Moments, b::Moments)
    merged = Moments()

    merged.n = a.n + b.n

    δ = b.m1 - a.m1
    δ2 = δ * δ
    δ3 = δ * δ2
    δ4 = δ2 * δ2

    merged.m1 = (a.n * a.m1 + b.n * b.m1) / merged.n

    merged.m2 = a.m2 + b.m2 + δ2 * a.n * b.n / merged.n

    merged.m3 = a.m3 + b.m3 +
                  δ3 * a.n * b.n * (a.n - b.n) / (merged.n * merged.n)
    merged.m3 += 3.0 * δ * (a.n * b.m2 - b.n * a.m2) / merged.n

    merged.m4 = a.m4 + b.m4 + δ4 * a.n * b.n *
                  (a.n * a.n - a.n * b.n + b.n * b.n) /
                  (merged.n * merged.n * merged.n)
    merged.m4 += 6.0 * δ2 * (a.n * a.n * b.m2 + b.n * b.n * a.m2) /
                   (merged.n * merged.n) +
                   4.0 * δ * (a.n * b.m3 - b.n * a.m3) / merged.n

    return merged
end

function Base.empty!(stat::Moments)
    stat.n = 0
    stat.m1 = 0.0
    stat.m2 = 0.0
    stat.m3 = 0.0
    stat.m4 = 0.0
    return
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
