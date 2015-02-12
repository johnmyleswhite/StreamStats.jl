module TestMax
    using StreamStats
    using Distributions
    using Base.Test

    # Max of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Max()
        for x in xs
            update!(stat, x)
        end
        online_m = maximum(stat)
        online_ms = state(stat)
        online_n = nobs(stat)
        batch_m = maximum(xs)
        @test online_m == batch_m
        @test online_n == n
    end
end
