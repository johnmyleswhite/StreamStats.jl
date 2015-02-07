module TestVar
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 100)
        xs = rand(n)
        stat = StreamStats.Var()
        for x in xs
            update!(stat, x)
        end
        online_v = state(stat)
        online_n = nobs(stat)
        batch_v = var(xs)
        @test_approx_eq(online_v, batch_v)
        @test online_n == n
    end
end
