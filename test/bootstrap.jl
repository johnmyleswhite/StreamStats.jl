module TestBootstrap
    using StreamStats
    using Distributions
    using Base.Test

    # CI's for mean of uniform draws
    for n in rand(1:10_000, 10)
        xs = rand(n)
        inner_stat = StreamStats.Mean()
        stat1 = StreamStats.BootstrapBernoulli(inner_stat)
        stat2 = StreamStats.BootstrapPoisson(inner_stat)
        for x in xs
            update!(stat1, x)
            update!(stat2, x)
        end
        lower1, upper1 = state(stat1)
        lower2, upper2 = state(stat2)
        m, sem = mean(xs), std(xs) / sqrt(n)
        @test m - 3 * sem <= lower1 <= m - 1 * sem
        @test m + 1 * sem <= upper1 <= m + 3 * sem
        @test m - 3 * sem <= lower2 <= m - 1 * sem
        @test m + 1 * sem <= upper2 <= m + 3 * sem
    end

    # CI's for standard deviation of uniform draws
    for n in rand(1:10_000, 10)
        xs = rand(n)
        inner_stat = StreamStats.Std()
        stat1 = StreamStats.BootstrapBernoulli(inner_stat)
        stat2 = StreamStats.BootstrapPoisson(inner_stat)
        for x in xs
            update!(stat1, x)
            update!(stat2, x)
        end
        lower1, upper1 = state(stat1)
        lower2, upper2 = state(stat2)
        @test lower1 <= std(xs) <= upper1
        @test lower2 <= std(xs) <= upper2
    end
end
