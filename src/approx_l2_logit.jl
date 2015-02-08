# AdaGrad + Analytic Gradient

invlogit(z::Real) = 1 / (1 + exp(-z))

type ApproxL2Logit <: StreamStat
    λ::Float64
    α::Float64
    β₀::Float64
    β::Vector{Float64}
    sum_gr₀_sq::Float64
    sum_gr_sq::Vector{Float64}
    n::Int
end

function ApproxL2Logit(p::Integer, λ::Real, α::Real = 0.1)
    return ApproxL2Logit(
        float64(λ),
        float64(α),
        0.0,
        fill(0.0, p),
        0.0,
        fill(0.0, p),
        0,
    )
end

function update!(stat::ApproxL2Logit, x::Vector{Float64}, y::Real)
    stat.n += 1

    y_pred = invlogit(stat.β₀ + dot(stat.β, x))

    ε = y - y_pred

    # Intercept
    gr₀ = ε - stat.λ * stat.β₀
    stat.sum_gr₀_sq += gr₀^2
    α₀ = stat.α / sqrt(stat.sum_gr₀_sq)
    stat.β₀ += α₀ * gr₀

    # Non-constant predictors
    for i in 1:length(x)
        grᵢ = ε * x[i] - stat.λ * stat.β[i]
        stat.sum_gr_sq[i] += grᵢ^2
        αᵢ = stat.α / sqrt(stat.sum_gr_sq[i])
        stat.β[i] += αᵢ * grᵢ
    end

    return
end

state(stat::ApproxL2Logit) = vcat(stat.β₀, stat.β)

nobs(stat::ApproxL2Logit) = stat.n

function Base.show(io::IO, stat::ApproxL2Logit)
    p = length(state(stat))
    n = nobs(stat)
    @printf(io, "Online L2-Regularized Logistic Regression\n")
    @printf(io, " * λ: %f\n", stat.λ)
    @printf(io, " * P: %d\n", p)
    @printf(io, " * N: %d\n", n)
    return
end

function Base.empty!(stat::ApproxL2Logit)
    stat.β₀ = 0
    fill!(stat.β, 0)
    stat.sum_gr₀_sq = 0
    fill!(stat.sum_gr_sq, 0)
    stat.n = 0
    return
end

# Base.merge
