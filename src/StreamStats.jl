module StreamStats
    import StatsBase, Distributions

    export update!, state, nobs

    include("streamstat.jl")
    include("mean.jl")
    include("var.jl")
    include("std.jl")
    include("moments.jl")
    include("cov.jl")
    include("cor.jl")
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
end
