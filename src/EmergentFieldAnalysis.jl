module EmergentFieldAnalysis

include("metrics/basic_stats.jl")
include("routing/routing_agent.jl")
include("qc/qc_sampler.jl")
using .BasicStats
using .RoutingAgent
using .QCSampler

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
    return Dict(
        :routing => route,
        :metrics => metrics,
        :qc_sample_flags => qc
    )
end

end # module
