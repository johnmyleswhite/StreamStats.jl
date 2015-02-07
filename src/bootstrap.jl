abstract Bootstrap <: StreamStat

type BootstrapBernoulli{S <: ContinuousUnivariateStreamStat} <: Bootstrap
    replicates::Vector{S}
    replicate_states::Vector{Float64}
    α::Float64
    n::Int
    # TODO: Force vectors to both have size R
end

function BootstrapBernoulli{S <: ContinuousUnivariateStreamStat}(
    stat::S,
    R::Int = 1_000,
    α::Real = 0.05,
)
    replicates = S[copy(stat) for i in 1:R]
    replicate_states = Array(Float64, R)
    return BootstrapBernoulli(replicates, replicate_states, α, 0)
end

type BootstrapPoisson{S <: ContinuousUnivariateStreamStat} <: Bootstrap
    replicates::Vector{S}
    replicate_states::Vector{Float64}
    α::Float64
    n::Int
    # TODO: Force vectors to both have size R
end

function BootstrapPoisson{S <: ContinuousUnivariateStreamStat}(
    stat::S,
    R::Int = 1_000,
    α::Float64 = 0.05,
)
    replicates = S[copy(stat) for i in 1:R]
    replicate_states = Array(Float64, R)
    return BootstrapPoisson(replicates, replicate_states, α, 0)
end

function update!(stat::BootstrapBernoulli, args::Any...)
    stat.n += 1

    for replicate in stat.replicates
        if rand() > 0.5
            update!(replicate, args...)
            update!(replicate, args...)
        end
    end

    return
end

function update!(stat::BootstrapPoisson, args::Any...)
    stat.n += 1

    for replicate in stat.replicates
        repetitions = rand(Distributions.Poisson(1))
        for repetition in 1:repetitions
            update!(replicate, args...)
        end
    end

    return
end

# TODO: Make this work with non-univariate statistics by taking marginal
#       quantiles
function state(stat::Bootstrap)
    R = length(stat.replicates)

    for (i, replicate) in enumerate(stat.replicates)
        stat.replicate_states[i] = state(replicate)
    end

    # If any NaN, return NaN, NaN
    if any(isnan, stat.replicate_states)
        return (NaN, NaN)
    else
        return (
            quantile(stat.replicate_states, stat.α / 2),
            quantile(stat.replicate_states, 1 - stat.α / 2),
        )
    end
end

nobs(stat::Bootstrap) = stat.n

# Base.copy(stat::Bootstrap)

# function Base.merge(stat1::Bootstrap, stat2::Bootstrap)

# function Base.empty!(stat::Bootstrap)

function Base.show(io::IO, stat::Bootstrap)
    @printf("%s:\n", typeof(stat))
    @printf(" * Replicates: %d\n", length(stat.replicates))
    @printf(" * Confidence Level: %f\n", 1 - stat.α)
    lower, upper = state(stat)
    @printf(" * Confidence Interval: [%f, %f]", lower, upper)
end
