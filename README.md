StreamStats.jl
==============

# Intro

Compute statistics from a stream of data. Useful when:

* Interim statistics must be available before the stream is fully processed
* Analysis of data must use no more than O(1) memory
* Many streams of data must be processed in parallel and results later merged

# Example Usage

Every statistic is constructed as a mutable object that updates state with
each new observation:

```jl
using StreamStats

var_x = StreamStats.Var()
var_y = StreamStats.Var()
cov_xy = StreamStats.Cov()

xs = randn(10)
ys = 3.1 * xs + randn(10)

for (x, y) in zip(xs, ys)
    update!(var_x, x)
    update!(var_y, y)
    update!(cov_xy, x, y)
    @printf("Estimated covariance: %f\n", state(cov_xy))
end

state(var_x), state(var_y), state(cov_xy)
```

As you can see, you update statistics using the `update!` function and
extract the current estimate using the `state` function.

# Available Statistics

* StreamStats.Mean
* StreamStats.Var
* StreamStats.Std
* StreamStats.Moments
* StreamStats.Min
* StreamStats.Max
* StreamStats.ApproxDistinct

# Available Bivariate Statistics

* StreamStats.Cov
* StreamStats.Cor

# Available Multivariate Statistics

* StreamStats.Sample
* StreamStats.ApproxOLS
* StreamStats.ApproxLogit

# Bootstrapping

It is also possible to estimate confidence intervals for online statistics
using online bootstrap methods:

```jl
using StreamStats

stat = StreamStats.Cor()
ci1 = StreamStats.BootstrapBernoulli(stat, 1_000, 0.05)
ci2 = StreamStats.BootstrapPoisson(stat, 1_000, 0.05)

xs = randn(100)
ys = randn(100)

for (x, y) in zip(xs, ys)
    update!(stat, x, y)
    update!(ci1, x, y)
    update!(ci2, x, y)
end

state(stat), state(ci1), state(ci2)
```

Given any other statistic object, you can use the `BootstrapBernoulli` or
`BootstrapPoisson` types to estimate a confidence interval. These types require
that you specify the number of bootstrap repliates (i.e. `1_000`) and the error
rate for nominal coverage of the confidence interval (i.e. `0.05`).

# Thanks

The code for computing moments from a stream is derived from John D. Cook's
[code](http://www.johndcook.com/blog/skewness_kurtosis/) for computing the
skewness and kurtosis of a data stream online.
