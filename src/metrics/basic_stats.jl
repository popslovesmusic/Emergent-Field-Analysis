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
    peak_count = 0
    cluster_count = 0
    in_cluster = false
    @inbounds for i in eachindex(arr)
        val = arr[i] > μ
        if val && !in_cluster
            cluster_count += 1
            in_cluster = true
        elseif !val
            in_cluster = false
        end
    end
    if N >= 3
        @inbounds for i in 2:(N - 1)
            if arr[i] > arr[i - 1] && arr[i] > arr[i + 1] && arr[i] > μ
                peak_count += 1
            end
        end
    end
    edge_count = 0
    if N >= 3
        @inbounds for i in 2:(N - 1)
            if abs(arr[i + 1] - arr[i]) > σ
                edge_count += 1
            end
        end
    end
    edge_density = edge_count / max(1, N - 2)
    return Dict(
        :min => mn,
        :max => mx,
        :mean => μ,
        :std => σ,
        :skew => skew,
        :kurtosis => kurtosis,
        :peak_count => peak_count,
        :cluster_count => cluster_count,
        :edge_density => edge_density
    )
end

end # module
