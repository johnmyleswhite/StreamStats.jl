type Cor <: ContinuousUnivariateStreamStat
    cov::Cov
end

Cor() = Cor(Cov())

update!(stat::Cor, x::Real, y::Real) = update!(stat.cov, x, y)

state(stat::Cor) = state(stat.cov) / (state(stat.cov.x) * state(stat.cov.y))

nobs(stat::Cor) = nobs(stat.cov)

Base.copy(stat::Cor) = Cor(copy(stat.cov))

Base.merge(a::Cor, b::Cor) = Cor(merge(a.cov, b.cov))

Base.empty!(stat::Cor) = empty!(stat.cov)

function Base.show(io::IO, stat::Cor)
    ρ = state(stat)
    n = nobs(stat)
    @printf(io, "Online Correlation\n")
    @printf(io, " * Correlation: %f\n", ρ)
    @printf(io, " * N:           %d\n", n)
    return
end
