module RoutingAgent

export routing_decision

"""
routing_decision(metrics::Dict{Symbol,Dict}) -> Symbol

Returns:
- :llm_review_needed if anomaly threshold exceeded
- :deterministic_ok otherwise
"""
function routing_decision(metrics::Dict{Symbol,Dict})
    for (fname, stats) in metrics
        if stats[:kurtosis] > 5.0
            return :llm_review_needed
        end
        if abs(stats[:skew]) > 2.0
            return :llm_review_needed
        end
        if stats[:peak_count] > 50
            return :llm_review_needed
        end
    end
    return :deterministic_ok
end

end # module
