module TestApproxLogit
    using StreamStats
    using Distributions
    using Base.Test

    invlogit(z::Real) = 1 / (1 + exp(-z))

    for n in rand(100_000:1_000_000, 10)
        p = rand(1:100)
        β₀ = randn()
        β = randn(p)
        xs = randn(p, n)
        ps = Float64[invlogit(β₀ + dot(β, xs[:, i])) for i in 1:n]
        ys = [rand(Bernoulli(pᵢ)) for pᵢ in ps]
        stat = StreamStats.ApproxLogit(p)
        for i in 1:n
            update!(stat, xs[:, i], ys[i])
        end
        l2_err = norm(vcat(β₀, β) - state(stat))
        @test l2_err < 0.10 * p
        @test nobs(stat) == n
    end

end
