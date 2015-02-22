module StreamStats
    import StatsBase, Distributions

    export update!, state, nobs, replicates

    include("streamstat.jl")
    include("mean.jl")
    include("imm_mean.jl")
    include("var.jl")
    include("moments.jl")
    include("cov.jl")
    include("min.jl")
    include("max.jl")
    # include("approx_quantile.jl")
    # include("approx_cdf.jl")
    # include("approx_pmf.jl")
    include("hyper_log_log.jl")
    include("approx_distinct.jl")
    include("bootstrap.jl")
    include("sample.jl")
    include("approx_ols.jl")
    include("approx_logit.jl")
    include("approx_ridge.jl")
    include("approx_l2_logit.jl")
end
