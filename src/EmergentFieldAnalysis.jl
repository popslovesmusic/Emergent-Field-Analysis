module EmergentFieldAnalysis

include("metrics/basic_stats.jl")
include("routing/routing_agent.jl")
include("qc/qc_sampler.jl")
include("llm/llm_contract.jl")
include("logging/jsonl_logger.jl")
using .BasicStats
using .RoutingAgent
using .QCSampler
using .LLMContract
using .JSONLLogger

"""
run_analysis(fields::Vector{Tuple{Symbol,AbstractArray}}, meta::Dict) -> Dict

Primary entry point for routing evaluation.

fields: Vector of (Symbol, array) field data
meta: dictionary of metadata (engine_type, run_id, etc)

Returns: Dict summarizing routing decision + deterministic metrics
"""
function run_analysis(fields::Vector{Tuple{Symbol,AbstractArray}}, meta::Dict)
    metrics = Dict{Symbol,Dict{Symbol,Any}}()
    for (name, arr) in fields
        metrics[name] = Dict{Symbol,Any}(field_basic_stats(arr))
    end
    route = routing_decision(metrics)
    qc = qc_sample_flags(metrics)
    payload = build_post_run_review_payload(meta["run_id"], meta["engine_type"], metrics, route)
    result = Dict(
        :routing => route,
        :metrics => metrics,
        :qc_sample_flags => qc,
        :llm_payload => payload
    )

    if haskey(meta, "log_path")
        logrec = Dict(
            :run_id => get(meta, "run_id", "unknown"),
            :engine_type => get(meta, "engine_type", "unknown"),
            :script_version => "efa-0.1.0",
            :result => result
        )
        try
            append_jsonl(String(meta["log_path"]), logrec)
        catch err
            # Non-fatal: logging should never crash analysis
            # (Optional) Could stash an :log_error field for introspection
        end
    end

    return result
end

end # module
