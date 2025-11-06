module BasicStats

using Statistics

export field_basic_stats

"""
field_basic_stats(arr::AbstractArray) -> Dict

Compute basic deterministic statistics for a field:
- min
- max
- mean
- std

Returns Dict with Symbol keys:
:min, :max, :mean, :std
"""
function field_basic_stats(arr::AbstractArray)
    mn = minimum(arr)
    mx = maximum(arr)
    μ = mean(arr)
    σ = std(arr)
    N = length(arr)
    if N > 1
        centered = arr .- μ
        m3 = sum(centered .^ 3) / N
        m4 = sum(centered .^ 4) / N
        skew = m3 / (σ^3 + eps())
        kurtosis = m4 / (σ^4 + eps())
    else
        skew = 0.0
        kurtosis = 0.0
    end
    return Dict(
        :min => mn,
        :max => mx,
        :mean => μ,
        :std => σ,
        :skew => skew,
        :kurtosis => kurtosis
    )
end

end # module
