module LLMContract

export build_post_run_review_payload

using JSON

"""
build_post_run_review_payload(run_id::String, engine_type::Symbol, metrics::Dict, routing::Symbol; time_series=false)

Returns Dict that matches baseline post_run_review JSON contract fields.
"""
function build_post_run_review_payload(run_id::String, engine_type::Symbol, metrics::Dict, routing::Symbol; time_series=false)
    return Dict(
        :msg_type => "post_run_review",
        :spec_version => "1.0",
        :session => Dict(
            :run_id => run_id,
            :engine_type => string(engine_type),
            :fields_present => collect(keys(metrics)),
            :time_series => time_series
        ),
        :script_result => Dict(
            :routing_decision => routing,
        ),
        :metrics => metrics
    )
end

end # module
