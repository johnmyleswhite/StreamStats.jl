module TestStd
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Std()
        for x in xs
            update!(stat, x)
        end
        online_s = state(stat)
        online_n = nobs(stat)
        batch_s = std(xs)
        @test_approx_eq(online_s, batch_s)
        @test online_n == n
    end
end
