module TestMoments
    using StreamStats
    using Distributions
    using Base.Test

    # Moments of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Moments()
        for x in xs
            update!(stat, x)
        end
        online_m, online_v, online_s, online_k = state(stat)
        online_n = nobs(stat)
        batch_m = mean(xs)
        batch_v = var(xs)
        batch_s = skewness(xs)
        batch_k = kurtosis(xs)

        @test_approx_eq(online_m, batch_m)
        @test_approx_eq(online_v, batch_v)
        @test abs(online_s - batch_s) < 1e-8 * abs(batch_s)
        @test abs(online_k - batch_k) < 1e-8 * abs(batch_k)
        @test online_n == n
    end
end
