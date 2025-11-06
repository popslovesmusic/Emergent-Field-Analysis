#!/usr/bin/env julia

using EmergentFieldAnalysis
using JSON

if length(ARGS) < 3
    println("usage: efa_cli.jl <run_id> <engine_type> <data_file.jl> [adaptive_state_path] [log_path]")
    exit(1)
end

run_id = ARGS[1]
engine_type = Symbol(ARGS[2])
datafile = ARGS[3]

adaptive_state_path = length(ARGS) >= 4 ? ARGS[4] : nothing
log_path = length(ARGS) >= 5 ? ARGS[5] : nothing

fields = read(datafile)  # expects Vector{Tuple{Symbol,AbstractArray}}

meta = Dict(
    "run_id" => run_id,
    "engine_type" => engine_type
)

if adaptive_state_path !== nothing
    meta["adaptive_state_path"] = adaptive_state_path
end

if log_path !== nothing
    meta["log_path"] = log_path
end

res = EmergentFieldAnalysis.run_analysis(fields, meta)

println(JSON.json(res))
