type ApproxPMF <: StreamStat
    cms::CountMinSketch
    n::Int
end

ApproxPMF() = ApproxPMF(CountMinSketch(), 0)

function update!(stat::ApproxPMF, x::Any)
    stat.n += 1

    update!(stat.cms, x)

    return
end

Distributions.pmf(stat::ApproxPMF, x::Any) = estimate(stat.cms, x) / stat.n

state(stat::ApproxPMF) = stat.cms

nobs(stat::ApproxPMF) = stat.n

Base.copy(stat::ApproxPMF) = ApproxPMF(copy(stat.cms), 0)

# function Base.merge(a::ApproxPMF, b::ApproxPMF)
#     TODO
# end

function Base.empty!(stat::ApproxPMF)
    stat.cms = CountMinSketch()
    stat.n = 0
    return
end

function Base.show(io::IO, stat::ApproxPMF)
    n = nobs(stat)
    @printf(io, "Online Approx PMF\n")
    @printf(io, " * N: %d\n", n)
    return
end
