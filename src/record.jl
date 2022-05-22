struct Record
    type::String
    id::Int
    created
    updated
    links::Dict{String,String}
    metadata::Dict
end

function Record(identifier_type::AbstractString, identifier_value)
    resp = get_record(identifier_type, string(identifier_value))
    return Record(identifier_type, resp)
end

function Record(type::String, resp::HTTP.Messages.Response)
    json = JSON.parse(String(resp.body))
    return Record(type, json)
end

function Record(type::String, json::Dict)
    id = parse(Int,json["id"])
    created = parse_inspire_timestamp(json["created"])
    updated = parse_inspire_timestamp(json["updated"])
    links = Dict{String, String}(json["links"])
    metadata = json["metadata"]

    return Record(type, id, created, updated, links, metadata)
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

function get_if_key_and_not_empty_or_missing(r::Record, key::String)
    md = r.metadata
    haskey(md, key) || return missing
    mdn = md[key]

    isempty(mdn) && return missing

    return mdn
end

for (entry_name, getter) in [
                          ("name", :name), 
                          ("citation_count", :citation_count), 
                         ]
    @eval function $getter(r::Record)
        mdn = get_if_key_and_not_empty_or_missing(r, $entry_name)
        ismissing(mdn) && return missing
        return last(first(mdn))
    end
end

function keywords(r::Record)
    mdn = get_if_key_and_not_empty_or_missing(r, "keywords")
    ismissing(mdn) && return missing
    return [kywd["value"] for kywd in mdn]
end

function title(r::Record)
    mdn = get_if_key_and_not_empty_or_missing(r, "titles")
    ismissing(mdn) && return missing
    return first(mdn)["title"]
end

function Base.show(io::IO, r::Record)
    ucft = uppercasefirst(r.type)

    println("Inspire Record ($(ucft))")
    println(io, "\tId:", r.id)
    println(io, "\tCreated:", r.created)
    println(io, "\tUpdated:", r.created)

    metadatas = [
                 ("Name", name(r)),
                 ("Title", title(r)),
                 ("Keywords", keywords(r)),
                 # ("Citations", citation_count(r)),
                ]

    foreach(metadatas) do (lbl, val)
        ismissing(val) && return 
        isa(val, Vector) && (val = join(val, ", "))
        println(io, "\t",lbl,":", val)
    end
end
