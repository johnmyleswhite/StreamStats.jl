module TestCov
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 10)
        xs = randn(n)
        ys = rand() * xs + randn(n)
        stat = StreamStats.Cov()
        for (x, y) in zip(xs, ys)
            update!(stat, x, y)
        end
        online_cov = state(stat)
        online_n = nobs(stat)
        batch_cov = cov(xs, ys)
        @test_approx_eq(online_cov, batch_cov)
        @test online_n == n
    end
end
