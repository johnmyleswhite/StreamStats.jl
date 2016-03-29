module TestApproxPMF
    using StreamStats
    using StatsBase
    using Distributions
    using Base.Test

    xs = [iceil(abs(rand(Laplace(0, 1000)))) for i in 1:1_000_000]
    counts = countmap(xs)
    stat = StreamStats.ApproxPMF()

    for x in xs
        update!(stat, x)
    end

    err = 0.0
    for x in minimum(xs):maximum(xs)
        if haskey(counts, x)
            err += abs(counts[x] / length(xs) - pmf(stat, x))
        end
    end
    @test err / length(counts) <= 0.0001
end
