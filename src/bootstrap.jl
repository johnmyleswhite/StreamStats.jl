abstract Bootstrap <: StreamStat

## Double-or-nothing online bootstrap
type BernoulliBootstrap{S <: ContinuousUnivariateStreamStat} <: Bootstrap
    replicates::Vector{S}           # replicates of base stat
    cached_state::Vector{Float64}  # cache of replicate states
    n::Int                          # number of observations
    cache_is_dirty::Bool
end

## Poisson weighted online bootstrap
type PoissonBootstrap{S <: ContinuousUnivariateStreamStat} <: Bootstrap
    replicates::Vector{S}           # replicates of base stat
    cached_state::Vector{Float64}  # cache of replicate states
    n::Int                          # number of observations
    cache_is_dirty::Bool
end

# Frozen bootstrap object are generated when two bootstrap distributions
# are combined, e.g., if they are differenced. 
immutable FrozenBootstrap <: Bootstrap
    cached_state::Vector{Float64}  # cache of replicate states
    n::Int                          # number of observations
end

# Double or nothing bootstrap
function BernoulliBootstrap{S <: ContinuousUnivariateStreamStat}(
    stat::S,
    R::Int = 1_000,
    α::Real = 0.05,
)
    replicates = S[copy(stat) for i in 1:R]
    cached_state = Array(Float64, R)
    return BernoulliBootstrap(replicates, cached_state, 0, true)
end

function PoissonBootstrap{S <: ContinuousUnivariateStreamStat}(
    stat::S,
    R::Int = 1_000,
    α::Float64 = 0.05,
)
    replicates = S[copy(stat) for i in 1:R]
    cached_state = Array(Float64, R)
    return PoissonBootstrap(replicates, cached_state, 0, true)
end

function update!(stat::BernoulliBootstrap, args::Any...)
    stat.n += 1

    for replicate in stat.replicates
        if rand() > 0.5
            update!(replicate, args...)
            update!(replicate, args...)
        end
    end
    stat.cache_is_dirty = true
    return
end

function update!(stat::PoissonBootstrap, args::Any...)
    stat.n += 1

    for replicate in stat.replicates
        repetitions = rand(Distributions.Poisson(1))
        for repetition in 1:repetitions
            update!(replicate, args...)
        end
    end
    stat.cache_is_dirty = true

    return
end

function update!(stat::FrozenBootstrap, args::Any...)
    error("Cannot update a FrozenBootstrap object")
    return
end

# TODO: Make this work with non-univariate statistics by taking marginal
#       quantiles
function state(stat::Bootstrap)
    return stat.replicates
end

function state(stat::FrozenBootstrap)
    return stat.cached_state
end

# update cached_state' states if necessary and return their values
function cached_state(stat::Bootstrap)
    if stat.cache_is_dirty
        for (i, replicate) in enumerate(stat.replicates)
            stat.cached_state[i] = state(replicate)
        end
        stat.cache_is_dirty = false
    end
    return stat.cached_state
end

function cached_state(stat::FrozenBootstrap)
    return stat.cached_state
end

function ci(stat::Bootstrap, α=0.05, method=:quantile)
    states = cached_state(stat)

    # If any NaN, return NaN, NaN
    if any(isnan, states)
        return (NaN, NaN)
    else
        if method == :quantile
            return (
                quantile(states, α / 2),
                quantile(states, 1 - α / 2),
            )
        elseif method == :normal
            norm_approx = Distributions.Normal(
                mean(states),
                std(states)
            )
            return (
                quantile(norm_approx, α / 2),
                quantile(norm_approx, 1 - α / 2)
            )
        else
            error("Unrecognized confidence interval type: ", ci)
        end
    end
end

nobs(stat::Bootstrap) = stat.n

# Assumes a and b are independent.
function Base.(:-)(a::Bootstrap, b::Bootstrap)
    return FrozenBootstrap(
        cached_state(a) - cached_state(b),
        nobs(a) + nobs(b)
    )
end

# Base.copy(stat::Bootstrap)

# function Base.merge(stat1::Bootstrap, stat2::Bootstrap)

# function Base.empty!(stat::Bootstrap)

function Base.rand(stat::Bootstrap)
    cs = cached_state(stat)
    cs[rand(1:length(cs))]
end

function Base.show(io::IO, stat::Bootstrap)
    @printf("%s:\n", typeof(stat))
    @printf(" * Replicates: %d\n", length(stat.cached_state))
    lower, upper = ci(stat, 0.05)
    @printf(" * Confidence Interval: [%f, %f]", lower, upper)
end
