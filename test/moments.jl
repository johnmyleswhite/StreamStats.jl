module TestMoments
    using Distributions
    using StatsBase
    using StreamStats
    using Base.Test


    # Moments of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Moments()
        for x in xs
            update!(stat, x)
        end
        online_ms, online_vs, online_ss, online_ks = state(stat)
        online_m = mean(stat)
        online_v = var(stat)
        online_d = std(stat)
        online_e = sem(stat)
        online_s = skewness(stat)
        online_k = kurtosis(stat)
        online_n = nobs(stat)
        batch_m = mean(xs)
        batch_v = var(xs)
        batch_d = std(xs)
        batch_e = sem(xs)
        batch_s = skewness(xs)
        batch_k = kurtosis(xs)

        @test_approx_eq(online_m, batch_m)
        @test_approx_eq(online_ms, batch_m)
        @test_approx_eq(online_v, batch_v)
        @test_approx_eq(online_vs, batch_v)
        @test_approx_eq(online_d, batch_d)
        @test_approx_eq(online_e, batch_e)
        @test abs(online_s - batch_s) < 1e-8 * abs(batch_s)
        @test abs(online_ss - batch_s) < 1e-8 * abs(batch_s)
        @test abs(online_k - batch_k) < 1e-8 * abs(batch_k)
        @test abs(online_ks - batch_k) < 1e-8 * abs(batch_k)
        @test online_n == n
    end
end
