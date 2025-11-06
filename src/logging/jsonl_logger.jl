module JSONLLogger

export append_jsonl

using Dates
using JSON

"""
append_jsonl(path::AbstractString, record::Dict) -> Nothing

Appends one compact JSON object to `path` followed by newline.
Adds ISO8601 timestamp if missing.
"""
function append_jsonl(path::AbstractString, record::Dict)
    rec = copy(record)
    if !haskey(rec, :timestamp)
        rec[:timestamp] = Dates.format(Dates.now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
    end
    open(path, "a") do io
        JSON.print(io, rec)   # compact
        write(io, '\n')
    end
    return nothing
end

end # module
