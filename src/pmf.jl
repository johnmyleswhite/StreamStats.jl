type PMF <: StreamStat
    counts::Dict{Any, Int}
    n::Int
end

PMF() = PMF(Dict{Any, Int}(), 0)

function update!(stat::PMF, x::Any)
    stat.n += 1

    if haskey(stat.counts, x)
        stat.counts[x] += 1
    else
        stat.counts[x] = 1
    end

    return
end

Distributions.pmf(stat::PMF, x::Any) = stat.counts[x] / stat.n

state(stat::PMF) = stat.counts

nobs(stat::PMF) = stat.n

Base.copy(stat::PMF) = PMF(copy(stat.counts), stat.n)

# function Base.merge(a::PMF, b::PMF)
#     TODO
# end

function Base.empty!(stat::PMF)
    stat.counts = Dict{Any, Any}()
    return
end

function Base.show(io::IO, stat::PMF)
    n = nobs(stat)
    @printf(io, "Online  PMF\n")
    @printf(io, " * N: %d\n", n)
    return
end
