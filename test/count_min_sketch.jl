module TestCountMinSketch
    using StreamStats
    using StatsBase
    using Distributions
    using Base.Test

    xs = [iceil(abs(rand(Laplace(0, 100)))) for i in 1:1_000_000]
    counts = countmap(xs)
    sketch = StreamStats.CountMinSketch()

    for x in xs
        update!(sketch, x)
    end

    success = 0
    for x in minimum(xs):maximum(xs)
        if haskey(counts, x)
            @test StreamStats.estimate(sketch, x) >= counts[x]
            success += StreamStats.estimate(sketch, x) == counts[x]
        end
    end
    @test success == length(counts)
end
