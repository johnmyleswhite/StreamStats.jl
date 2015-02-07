module TestApproxDistinct
    using StreamStats
    using Distributions
    using Base.Test

    for n in rand(1:1_000_000, 100)
        xs = rand(1:n, n)
        stat = StreamStats.ApproxDistinct()
        for x in xs
            update!(stat, x)
        end
        online_d = state(stat)
        online_n = nobs(stat)
        batch_d = length(unique(xs))
        @test abs(online_d - batch_d) / batch_d < 0.03
        @test online_n == n
    end
end
