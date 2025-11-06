module EmergentFieldAnalysis

include("metrics/basic_stats.jl")
include("routing/routing_agent.jl")
using .BasicStats
using .RoutingAgent

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
    return Dict(
        :routing => route,
        :metrics => metrics
    )
end

end # module
