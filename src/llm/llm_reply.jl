module LLMReply

export extract_policy_overrides

using Dates

"""
extract_policy_overrides(resp::Dict) -> Dict
Reads a pre_run_suggestion_response Dict and returns a Dict of overrides:
- :qc_rate => Float64 (optional)
- :thresholds => Dict(:kurtosis, :abs_skew, :peak_count) (optional)
Non-fatal if keys are missing or malformed; returns empty Dict().
"""
function extract_policy_overrides(resp::Dict)
    out = Dict{Symbol,Any}()

    # msg_type gate (ignore other response types)
    mt = get(resp, :msg_type, get(resp, "msg_type", ""))
    if mt != "pre_run_suggestion_response"
        return out
    end

    proposed = get(resp, :proposed, get(resp, "proposed", nothing))
    if proposed === nothing
        return out
    end

    # qc rate
    qc = get(proposed, :qc_policy, get(proposed, "qc_policy", nothing))
    if qc !== nothing
        rate = get(qc, :qc_sampling_rate, get(qc, "qc_sampling_rate", nothing))
        if rate !== nothing
            try
                out[:qc_rate] = Float64(rate)
            catch
            end
        end
    end

    # optional thresholds block (preferred explicit form)
    thr = get(proposed, :thresholds, get(proposed, "thresholds", nothing))
    if thr !== nothing
        t = Dict{Symbol,Any}()
        if haskey(thr, :kurtosis) || haskey(thr, "kurtosis")
            t[:kurtosis] = Float64(get(thr, :kurtosis, get(thr, "kurtosis", 5.0)))
        end
        if haskey(thr, :abs_skew) || haskey(thr, "abs_skew")
            t[:abs_skew] = Float64(get(thr, :abs_skew, get(thr, "abs_skew", 2.0)))
        end
        if haskey(thr, :peak_count) || haskey(thr, "peak_count")
            t[:peak_count] = Int(get(thr, :peak_count, get(thr, "peak_count", 50)))
        end
        if !isempty(t)
            out[:thresholds] = t
        end
    end

    return out
end

end # module

