type Variance <: ContinuousUnivariateStreamStat
    m::Float64
    sum_sqs::Float64
    v_hat::Float64
    n::Int
end

Variance() = Variance(0.0, 0.0, NaN, 0)

function update!(stat::Variance, x::Real)
    stat.n += 1

    if stat.n == 1
        stat.m = x
        stat.sum_sqs = 0.0
        stat.v_hat = NaN
    else
        m_new = stat.m + (x - stat.m) / stat.n
        stat.sum_sqs += (x - stat.m) * (x - m_new)
        stat.m = m_new
        stat.v_hat = stat.sum_sqs / (stat.n - 1)
    end

    return
end

Base.var(stat::Variance) = stat.v_hat

Base.std(stat::Variance) = sqrt(var(stat))

Base.mean(stat::Variance) = stat.m

state(stat::Variance) = var(stat)

nobs(stat::Variance) = stat.n

function Base.copy(stat::Variance)
    return Variance(stat.m, stat.sum_sqs, stat.v_hat, stat.n)
end

function Base.merge(a::Variance, b::Variance)
    n = a.n + b.n
    m = (a.n / n) * a.m + (b.n / n) * b.m
    sum_sqs = a.sum_sqs + b.sum_sqs
    v_hat = (a.n / n) * a.v_hat + (b.n / n) * b.v_hat
    return Variance(m, sum_sqs, v_hat, n)
end

function Base.empty!(stat::Variance)
    stat.m = 0.0
    stat.sum_sqs = 0.0
    stat.v_hat = NaN
    stat.n = 0
    return
end

function Base.show(io::IO, stat::Variance)
    v = var(stat)
    s = std(stat)
    n = nobs(stat)
    @printf(io, "Online Variance\n")
    @printf(io, " * Variance:  %f\n", v)
    @printf(io, " * Std. Dev.: %f\n", v)
    @printf(io, " * N:         %d\n", n)
    return
end