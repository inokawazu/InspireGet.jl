struct Record
    id::Int
    created
    updated
    links::Dict{String,String}
    metadata::Dict
end

function Record(identifier_type::AbstractString, identifier_value)
    resp = get_record(identifier_type, string(identifier_value))
    return Record(resp)
end

function Record(resp::HTTP.Messages.Response)
    json = JSON.parse(String(resp.body))
    return Record(json)
end

function Record(json::Dict)
    id = parse(Int,json["id"])
    created = parse_inspire_timestamp(json["created"])
    updated = parse_inspire_timestamp(json["updated"])
    links = Dict{String, String}(json["links"])
    metadata = json["metadata"]

    return Record(id, created, updated, links, metadata)
end

function get_record(identifier_type::AbstractString, identifier_value::AbstractString; 
        content_format = "json"
    )::HTTP.Messages.Response


    check_identifier_type(identifier_type)
    check_format(content_format)

    url = join((INSPIRE_API_URL, identifier_type, identifier_value), '/')
    headers = ["Accept" => CONTENT_FORMATS[content_format]]

    return HTTP.get(url, headers)
end

const StringMissing = Union{String,Missing}

function record_type(r::Record)::StringMissing
    mch = match(r"([^/]*)\.[^\.]*$", r.metadata["\$schema"])

    isnothing(mch) && return missing

    return mch[1]
end

function name(r::Record)::StringMissing
    md = r.metadata
    
    haskey(md, "name") || return missing
    mdn = md["name"]

    isempty(mdn) && return missing
    
    return last(first(mdn))
end

function Base.show(io::IO, r::Record)
    ucft = uppercasefirst(record_type(r))

    println("Inspire Record ($(ucft))")
    println(io, "\tId:", r.id)
    println(io, "\tCreated:", r.created)
    println(io, "\tUpdated:", r.created)

    metadatas = [
                 ("Name", name(r)),
                ]

    foreach(metadatas) do (lbl, val)
        ismissing(val) && return 
        println(io, "\t",lbl,":", val)
    end
end
