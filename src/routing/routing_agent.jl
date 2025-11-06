module RoutingAgent

export routing_decision

"""
routing_decision(metrics::Dict{Symbol,Dict}; kurtosis_thr=5.0, abs_skew_thr=2.0, peak_thr=50) -> Symbol

Returns:
- :llm_review_needed if anomaly threshold exceeded
- :deterministic_ok otherwise
"""
function routing_decision(metrics::Dict{Symbol,Dict}; kurtosis_thr=5.0, abs_skew_thr=2.0, peak_thr=50)
    for (_, stats) in metrics
        if get(stats, :kurtosis, 0.0) > kurtosis_thr
            return :llm_review_needed
        end
        if abs(get(stats, :skew, 0.0)) > abs_skew_thr
            return :llm_review_needed
        end
        if get(stats, :peak_count, 0) > peak_thr
            return :llm_review_needed
        end
    end
    return :deterministic_ok
end

end # module
