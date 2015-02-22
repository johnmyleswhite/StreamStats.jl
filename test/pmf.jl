module TestPMF
    using StreamStats
    using StatsBase
    using Distributions
    using Base.Test

    xs = [iceil(abs(rand(Laplace(0, 1000)))) for i in 1:1_000_000]
    counts = countmap(xs)
    n = length(xs)
    stat = StreamStats.PMF()

    for x in xs
        update!(stat, x)
    end

    for (x, c) in counts
        @test_approx_eq(c / n, pmf(stat, x))
    end
end
