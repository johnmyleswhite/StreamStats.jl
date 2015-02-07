module TestCor
    using StreamStats
    using Distributions
    using Base.Test

    # Means of uniform draws
    for n in rand(1:1_000_000, 10)
        xs = randn(n)
        ys = rand() * xs + randn(n)
        stat = StreamStats.Cor()
        for (x, y) in zip(xs, ys)
            update!(stat, x, y)
        end
        online_cor = state(stat)
        online_n = nobs(stat)
        batch_cor = cor(xs, ys)
        @test_approx_eq(online_cor, batch_cor)
        @test online_n == n
    end
end
