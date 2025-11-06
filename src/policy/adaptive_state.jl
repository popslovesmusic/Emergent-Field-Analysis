module AdaptiveState

export Thresholds, AdaptiveStateModel, default_policy, load_policy, save_policy, to_dict

using JSON, Dates

struct Thresholds
    kurtosis::Float64
    abs_skew::Float64
    peak_count::Int
end

struct AdaptiveStateModel
    version::String
    thresholds::Thresholds
    qc_rate::Float64
    last_updated::String
end

function default_policy()
    ts = Dates.format(Dates.now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
    AdaptiveStateModel(
        "1.0",
        Thresholds(5.0, 2.0, 50),
        0.05,
        ts
    )
end

function to_dict(st::AdaptiveStateModel)
    return Dict(
        :version => st.version,
        :thresholds => Dict(
            :kurtosis => st.thresholds.kurtosis,
            :abs_skew => st.thresholds.abs_skew,
            :peak_count => st.thresholds.peak_count
        ),
        :qc_rate => st.qc_rate,
        :last_updated => st.last_updated
    )
end

function from_dict(d::Dict)
    thr = d[:thresholds]
    AdaptiveStateModel(
        String(d[:version]),
        Thresholds(
            Float64(thr[:kurtosis]),
            Float64(thr[:abs_skew]),
            Int(thr[:peak_count])
        ),
        Float64(d[:qc_rate]),
        String(d[:last_updated])
    )
end

"""
load_policy(path::AbstractString) -> AdaptiveStateModel
If file missing or parse fails, returns default policy.
"""
function load_policy(path::AbstractString)
    try
        text = read(path, String)
        d = JSON.parse(text; dicttype=Dict, inttype=Int, use_mmap=false)
        # Normalize keys to Symbols if they arrived as Strings
        d_sym = Dict(Symbol(k)=>v for (k,v) in d)
        if haskey(d_sym, :thresholds)
            th = d_sym[:thresholds]
            d_sym[:thresholds] = Dict(Symbol(k)=>v for (k,v) in th)
        end
        return from_dict(d_sym)
    catch
        return default_policy()
    end
end

"""
save_policy(path::AbstractString, st::AdaptiveStateModel) -> Nothing
Writes compact JSON to disk.
"""
function save_policy(path::AbstractString, st::AdaptiveStateModel)
    obj = to_dict(st)
    open(path, "w") do io
        JSON.print(io, obj)
    end
    return nothing
end

end # module

