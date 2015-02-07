type ApproxDistinct <: ContinuousUnivariateStreamStat
    counter::HyperLogLog
    n::Int
end

ApproxDistinct() = ApproxDistinct(HyperLogLog(16), 0)

function update!(stat::ApproxDistinct, x::Any)
    stat.n += 1

    update!(stat.counter, x)

    return
end

state(stat::ApproxDistinct) = state(stat.counter)

nobs(stat::ApproxDistinct) = stat.n

Base.copy(stat::ApproxDistinct) = ApproxDistinct(copy(stat.counter), 0)

# function Base.merge(a::ApproxDistinct, b::ApproxDistinct)
#     TODO
# end

function Base.empty!(stat::ApproxDistinct)
    stat.counter = HyperLogLog(16)
    stat.n = 0
    return
end

function Base.show(io::IO, stat::ApproxDistinct)
    d = state(stat)
    n = nobs(stat)
    @printf(io, "Online Count Distinct\n")
    @printf(io, " * Approx Count Distinct: %f\n", d)
    @printf(io, " * N:                     %d\n", n)
    return
end
