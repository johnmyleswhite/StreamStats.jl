module TestBootstrap
    using StreamStats
    using Distributions
    using Base.Test

    # CI's for mean of uniform draws
    for n in rand(1:10_000, 10)
        xs = rand(n)
        inner_stat = StreamStats.Mean()
        stat1 = StreamStats.BernoulliBootstrap(inner_stat)
        stat2 = StreamStats.PoissonBootstrap(inner_stat)
        for x in xs
            update!(stat1, x)
            update!(stat2, x)
        end

        # test using quantiles to generate bootstrap CIs
        lower1, upper1 = ci(stat1, 0.05)
        lower2, upper2 = ci(stat2, 0.05)
        m, sem = mean(xs), std(xs) / sqrt(n) 
        @test m - 3 * sem <= lower1 <= m - 1 * sem
        @test m + 1 * sem <= upper1 <= m + 3 * sem
        @test m - 3 * sem <= lower2 <= m - 1 * sem
        @test m + 1 * sem <= upper2 <= m + 3 * sem

        # test normal approximation of the bootstrap CIs
        lower1, upper1 = ci(stat1, 0.05, :normal)
        lower2, upper2 = ci(stat2, 0.05, :normal)
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
        stat1 = StreamStats.BernoulliBootstrap(inner_stat)
        stat2 = StreamStats.PoissonBootstrap(inner_stat)
        for x in xs
            update!(stat1, x)
            update!(stat2, x)
        end
        lower1, upper1 = ci(stat1, 0.05, :quantile)
        lower2, upper2 = ci(stat2, 0.05, :quantile)
        @test lower1 <= std(xs) <= upper1
        @test lower2 <= std(xs) <= upper2

        n_lower1, n_upper1 = ci(stat1, 0.05, :normal)
        n_lower2, n_upper2 = ci(stat2 , 0.05, :normal)
        @test n_lower1 <= std(xs) <= n_upper1
        @test n_lower2 <= std(xs) <= n_upper2
    end

    # test rand() method
    n = 1_000
    b1 = StreamStats.BernoulliBootstrap(StreamStats.Mean(), 10_000)
    b2 = StreamStats.BernoulliBootstrap(StreamStats.Mean(), 10_000)
    xs = rand(n)
    for i in xs
        update!(b1, i)
        update!(b2, i / 2.0)
    end
    xb = [rand(b1) for i in 1:1_000]

    # test -() method
    @test mean(state(b2 - b1)) < 0

end
