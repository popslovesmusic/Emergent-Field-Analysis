module PreRunTemplate

export build_pre_run_suggestion_template

"""
build_pre_run_suggestion_template(run_id::String, engine_type::Symbol, fields::Vector{Symbol}) -> Dict

Creates template dict to request parameter/QC/flag rule suggestions from an LLM.
"""
function build_pre_run_suggestion_template(run_id::String, engine_type::Symbol, fields::Vector{Symbol})
    return Dict(
        :msg_type => "pre_run_suggestion",
        :spec_version => "1.0",
        :session => Dict(
            :run_id => run_id,
            :engine_type => string(engine_type),
            :fields_present => [string(f) for f in fields],
            :time_series => false
        ),
        :context => Dict(),
        :summaries => Dict(),
        :asks => [
            "suggest_parameter_tweaks",
            "suggest_qc_sampling_rate",
            "suggest_flag_rules"
        ]
    )
end

end # module
