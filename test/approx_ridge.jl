module TestApproxRidge
    using StreamStats
    using Distributions
    using Base.Test

    for n in rand(100_000:1_000_000, 10)
        p = rand(1:100)
        β₀ = randn()
        β = randn(p)
        xs = randn(p, n)
        ys = Float64[β₀ + dot(β, xs[:, i]) + randn() for i in 1:n]
        stat = StreamStats.ApproxRidge(p, 1.0)
        for i in 1:n
            update!(stat, xs[:, i], ys[i])
        end
        @test cor(vcat(β₀, β), state(stat)) > 0.99
        # TODO: Add real tests
        # l2_err = norm(vcat(β₀, β) - state(stat))
        # @test l2_err < 0.05 * p
        # @test nobs(stat) == n
    end
end
