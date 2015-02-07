type Std <: ContinuousUnivariateStreamStat
    var::Var
end

Std() = Std(Var())

update!(stat::Std, x::Real) = update!(stat.var, x)

state(stat::Std) = sqrt(state(stat.var))

nobs(stat::Std) = nobs(stat.var)

Base.copy(stat::Std) = Std(copy(stat.var))

Base.merge(a::Std, b::Std) = Std(merge(a.var, b.var))

Base.empty!(stat::Std) = empty!(stat.var)

function Base.show(io::IO, stat::Std)
    s = state(stat)
    n = nobs(stat)
    @printf(io, "Online Standard Deviation\n")
    @printf(io, " * Standard Deviation: %f\n", s)
    @printf(io, " * N:                  %d\n", n)
    return
end

Base.mean(stat::Std) = mean(stat.var)
