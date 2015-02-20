#
# Correctness Tests
#

fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
anyerrors = false

using Base.Test

my_tests = [
    "mean.jl",
    "var.jl",
    "moments.jl",
    "cov.jl",
    "min.jl",
    "max.jl",
    "approx_quantile.jl",
    "hyper_log_log.jl",
    "approx_distinct.jl",
    "bootstrap.jl",
    "sample.jl",
    "approx_ols.jl",
    "approx_logit.jl",
    "approx_ridge.jl",
    "approx_l2_logit.jl",
]

println("Running tests:")

for my_test in my_tests
    try
        include(my_test)
        println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
    catch e
        anyerrors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
        if fatalerrors
            rethrow(e)
        elseif !quiet
            showerror(STDOUT, e, backtrace())
            println()
        end
    end
end

if anyerrors
    throw("Tests failed")
end
