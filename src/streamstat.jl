abstract StreamStat{
    F <: Distributions.VariateForm,
    S <: Distributions.ValueSupport
}

typealias DiscreteUnivariateStreamStat StreamStat{
    Distributions.Univariate,
    Distributions.Discrete
}

typealias ContinuousUnivariateStreamStat StreamStat{
    Distributions.Univariate,
    Distributions.Continuous
}

typealias DiscreteMultivariateStreamStat StreamStat{
    Distributions.Multivariate,
    Distributions.Discrete
}

typealias ContinuousMultivariateStreamStat StreamStat{
    Distributions.Multivariate,
    Distributions.Continuous
}
