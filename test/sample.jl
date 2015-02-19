module TestSample
    using StreamStats
    using Base.Test

    n = 10
    k = 3
    xs = rand(1:100_000, n)
    @assert length(unique(xs)) == n
    counts = Dict(zip(unique(xs), fill(0, n)))

    for itr in 1:100_000
        stat = StreamStats.Sample(Int, k)
        for x in xs
            update!(stat, x)
        end
        for sample in state(stat)
            @test sample in xs
            counts[sample] += 1
        end
    end
    for (elt, count) in counts
        # TODO: Write a sharper test based on SEM's
        @test 29_500 <= count <= 30_500
    end
end
