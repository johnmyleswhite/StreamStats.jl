module TestMin
    using StreamStats
    using Distributions
    using Base.Test

    # Min of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Min()
        for x in xs
            update!(stat, x)
        end
        online_m = minimum(stat)
        online_s = state(stat)
        online_n = nobs(stat)
        batch_m = minimum(xs)
        @test online_m == batch_m
        @test online_n == n
    end
end
