# AdaGrad + Analytic Gradient
if VERSION < v"0.4.0-"
    const tofloat64 = float64
else
    const tofloat64 = Float64
end

type ApproxRidge <: StreamStat
    λ::Float64
    α::Float64
    β₀::Float64
    β::Vector{Float64}
    sum_gr₀_sq::Float64
    sum_gr_sq::Vector{Float64}
    n::Int
end

function ApproxRidge(p::Integer, λ::Real, α::Real = 0.1)
    return ApproxRidge(
        tofloat64(λ),
        tofloat64(α),
        0.0,
        fill(0.0, p),
        0.0,
        fill(0.0, p),
        0,
    )
end

function update!(stat::ApproxRidge, x::Vector{Float64}, y::Real)
    stat.n += 1

    y_pred = stat.β₀ + dot(stat.β, x)

    ε = y - y_pred

    # Intercept
    gr₀ = -2.0 * ε + stat.λ * stat.β₀
    stat.sum_gr₀_sq += gr₀^2
    α₀ = stat.α / sqrt(stat.sum_gr₀_sq)
    stat.β₀ -= α₀ * gr₀

    # Non-constant predictors
    for i in 1:length(x)
        grᵢ = -2.0 * ε * x[i] + stat.λ * stat.β[i]
        stat.sum_gr_sq[i] += grᵢ^2
        αᵢ = stat.α / sqrt(stat.sum_gr_sq[i])
        stat.β[i] -= αᵢ * grᵢ
    end

    return
end

state(stat::ApproxRidge) = vcat(stat.β₀, stat.β)

nobs(stat::ApproxRidge) = stat.n

function Base.show(io::IO, stat::ApproxRidge)
    p = length(state(stat))
    n = nobs(stat)
    @printf(io, "Online Ridge Regression\n")
    @printf(io, " * λ: %f\n", stat.λ)
    @printf(io, " * P: %d\n", p)
    @printf(io, " * N: %d\n", n)
    return
end

function Base.empty!(stat::ApproxRidge)
    stat.β₀ = 0
    fill!(stat.β, 0)
    stat.sum_gr₀_sq = 0
    fill!(stat.sum_gr_sq, 0)
    stat.n = 0
    return
end

# Base.merge
