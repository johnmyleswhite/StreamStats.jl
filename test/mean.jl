module TestMean
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Mean()
        for x in xs
            update!(stat, x)
        end
        online_m = mean(stat)
        online_ms = state(stat)
        online_n = nobs(stat)
        batch_m = mean(xs)
        @test_approx_eq(online_m, batch_m)
        @test_approx_eq(online_ms, batch_m)
        @test online_n == n
    end

    # Means of non-uniform draws
    ds = [Normal(0, 1), Normal(1e5, 1e8), LogNormal(10, 10), Cauchy(0.0, 1e-8)]
    for d in ds
        for n in rand(1:1_000_000, 10)
            xs = rand(d, n)
            stat = StreamStats.Mean()
            for x in xs
                update!(stat, x)
            end
            online_m = mean(stat)
            online_n = nobs(stat)
            batch_m = mean(xs)
            @test abs(online_m - batch_m) < 1e-8 * abs(batch_m)
            @test online_n == n
        end
    end
end
