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
    return Dict(
        :min => mn,
        :max => mx,
        :mean => μ,
        :std => σ
    )
end

end # module
