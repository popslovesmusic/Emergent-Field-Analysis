module EmergentFieldAnalysis

include("metrics/basic_stats.jl")
include("routing/routing_agent.jl")
include("qc/qc_sampler.jl")
include("llm/llm_contract.jl")
include("llm/pre_run_template.jl")
include("logging/jsonl_logger.jl")
include("policy/adaptive_state.jl")
include("llm/llm_reply.jl")
using Dates
using .BasicStats
using .RoutingAgent
using .QCSampler
using .LLMContract
using .PreRunTemplate
using .JSONLLogger
using .AdaptiveState
using .LLMReply

"""
update_policy_from_llm!(resp::Dict, meta::Dict) -> Dict

Loads adaptive policy (if meta["adaptive_state_path"] provided),
merges overrides from a pre_run_suggestion_response, saves,
and returns the updated policy Dict form.
Non-fatal on missing path or malformed response.
"""
function update_policy_from_llm!(resp::Dict, meta::Dict)
    path = haskey(meta, "adaptive_state_path") ? String(meta["adaptive_state_path"]) : ""
    st = path == "" ? AdaptiveState.default_policy() : AdaptiveState.load_policy(path)

    ov = LLMReply.extract_policy_overrides(resp)
    if haskey(ov, :qc_rate)
        st = AdaptiveState.AdaptiveStateModel(
            st.version,
            st.thresholds,
            Float64(ov[:qc_rate]),
            st.last_updated
        )
    end
    if haskey(ov, :thresholds)
        thr = ov[:thresholds]
        new_thr = AdaptiveState.Thresholds(
            haskey(thr, :kurtosis) ? Float64(thr[:kurtosis]) : st.thresholds.kurtosis,
            haskey(thr, :abs_skew) ? Float64(thr[:abs_skew]) : st.thresholds.abs_skew,
            haskey(thr, :peak_count) ? Int(thr[:peak_count]) : st.thresholds.peak_count
        )
        st = AdaptiveState.AdaptiveStateModel(st.version, new_thr, st.qc_rate, st.last_updated)
    end

    st = AdaptiveState.AdaptiveStateModel(
        st.version,
        st.thresholds,
        st.qc_rate,
        Dates.format(Dates.now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
    )

    if path != ""
        try
            AdaptiveState.save_policy(path, st)
        catch
        end
    end

    return AdaptiveState.to_dict(st)
end

"""
run_analysis(fields::Vector{Tuple{Symbol,AbstractArray}}, meta::Dict) -> Dict

Primary entry point for routing evaluation.

fields: Vector of (Symbol, array) field data
meta: dictionary of metadata (engine_type, run_id, etc)

Returns: Dict summarizing routing decision + deterministic metrics
"""
function run_analysis(fields::Vector{Tuple{Symbol,AbstractArray}}, meta::Dict)
    policy = haskey(meta, "adaptive_state_path") ?
        AdaptiveState.load_policy(String(meta["adaptive_state_path"])) :
        AdaptiveState.default_policy()
    metrics = Dict{Symbol,Dict{Symbol,Any}}()
    for (name, arr) in fields
        metrics[name] = Dict{Symbol,Any}(field_basic_stats(arr))
    end
    route = routing_decision(
        metrics;
        kurtosis_thr = policy.thresholds.kurtosis,
        abs_skew_thr = policy.thresholds.abs_skew,
        peak_thr = policy.thresholds.peak_count
    )
    qc = qc_sample_flags(metrics; rate = policy.qc_rate)
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
