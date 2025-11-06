module QCSampler

export qc_sample_flags

using Random

"""
qc_sample_flags(metrics::Dict{Symbol,Dict}; rate=0.05) -> Dict{Symbol,Bool}

Returns Dict mapping each field name to Bool flag:
true = this field should be additionally sampled for LLM QC
false = no QC required by random sample
"""
function qc_sample_flags(metrics::Dict{Symbol,Dict}; rate=0.05)
    flags = Dict{Symbol,Bool}()
    for (fname, _) in metrics
        flags[fname] = rand() < rate
    end
    return flags
end

end # module
