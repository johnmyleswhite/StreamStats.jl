module TestVariance
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Variance()
        for x in xs
            update!(stat, x)
        end
        online_v = var(stat)
        online_s = std(stat)
        online_vs = state(stat)
        online_n = nobs(stat)
        batch_v = var(xs)
        batch_s = std(xs)
        @test_approx_eq(online_v, batch_v)
        @test_approx_eq(online_vs, batch_v)
        @test_approx_eq(online_s, batch_s)
        @test online_n == n
    end
end
