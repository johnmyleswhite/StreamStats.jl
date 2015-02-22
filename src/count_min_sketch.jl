# counts: An Int matrix of size (d, w). counts[i, j] stores the approximate
#         count of the element with hashed index j according to the hash
#         function i. An important invariant is that the row sum of the i-th
#         row is always equal to the total number of observed values.
#
# ε: The idealized relative error in any given item's frequency count
# δ: The probability that any given error is less than ε
type CountMinSketch
    counts::Matrix{Int}

    function CountMinSketch(δ::Real = 0.999, ε::Real = 0.001)
        depth = iceil(log(1 - δ) / log(0.5))
        width = iceil(2 / ε)
        counts = fill(0, depth, width)
        return new(counts)
    end
end

get_j(i::Integer, w::Integer, x::Any) = int(rem1(hash(x, uint(i)), w))

function update!(sketch::CountMinSketch, x::Any)
    d, w = size(sketch.counts)

    for i in 1:d
        j = get_j(i, w, x)
        sketch.counts[i, j] += 1
    end

    return
end

# TODO: Decide on the name for this
#       ESTIMATE is the name used in the original research paper
function estimate(sketch::CountMinSketch, x::Any)
    d, w = size(sketch.counts)

    n = typemax(Int)
    for i in 1:d
        j = get_j(i, w, x)
        n = min(n, sketch.counts[i, j])
    end

    return n
end
