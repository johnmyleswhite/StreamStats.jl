# AdaGrad + Analytic Gradient
if VERSION < v"0.4.0-"
    const tofloat64 = float64
else
    const tofloat64 = Float64
end

invlogit(z::Real) = 1 / (1 + exp(-z))

type ApproxLogit <: StreamStat
    α::Float64
    β₀::Float64
    β::Vector{Float64}
    sum_gr₀_sq::Float64
    sum_gr_sq::Vector{Float64}
    n::Int
end

function ApproxLogit(p::Integer, α::Real = 0.1)
    return ApproxLogit(tofloat64(α), 0.0, fill(0.0, p), 0.0, fill(0.0, p), 0)
end

function update!(stat::ApproxLogit, x::Vector{Float64}, y::Real)
    stat.n += 1

    y_pred = invlogit(stat.β₀ + dot(stat.β, x))

    ε = y - y_pred

    # Intercept
    gr₀ = ε
    stat.sum_gr₀_sq += gr₀^2
    α₀ = stat.α / sqrt(stat.sum_gr₀_sq)
    stat.β₀ += α₀ * gr₀

    # Non-constant predictors
    for i in 1:length(x)
        grᵢ = ε * x[i]
        stat.sum_gr_sq[i] += grᵢ^2
        αᵢ = stat.α / sqrt(stat.sum_gr_sq[i])
        stat.β[i] += αᵢ * grᵢ
    end

    return
end

state(stat::ApproxLogit) = vcat(stat.β₀, stat.β)

nobs(stat::ApproxLogit) = stat.n

function Base.show(io::IO, stat::ApproxLogit)
    p = length(state(stat))
    n = nobs(stat)
    @printf(io, "Online Logistic Regression\n")
    @printf(io, " * P: %d\n", p)
    @printf(io, " * N: %d\n", n)
    return
end

function Base.empty!(stat::ApproxLogit)
    stat.β₀ = 0
    fill!(stat.β, 0)
    stat.sum_gr₀_sq = 0
    fill!(stat.sum_gr_sq, 0)
    stat.n = 0
    return
end

# Base.merge
