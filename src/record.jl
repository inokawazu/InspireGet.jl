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

macro get_metadata_or_return_missing(mdn, r, kywd)    
    return quote
        $(esc(mdn)) = get_if_key_and_not_empty_or_missing($(esc(r)), $kywd)
        ismissing($(esc(mdn))) && return missing
    end
end

function name(r::Record)
    @get_metadata_or_return_missing(mdn,r,"name")
    if haskey(mdn, "preferred_name")
        return mdn["preferred_name"]
    end
    return get(mdn, "value", missing)
end

# simple getters
for getter in [:citation_count, :citation_count_without_self_citations]
    @eval function $getter(r::Record)
        key = string($getter)
        @get_metadata_or_return_missing(mdn,r,key)
        return mdn
    end
end

function keywords(r::Record)
    @get_metadata_or_return_missing(mdn,r,"keywords")
    return [kywd["value"] for kywd in mdn]
end

function title(r::Record)
    @get_metadata_or_return_missing(mdn,r,"titles")
    return first(mdn)["title"]
end

function author_full_names(r::Record)
    @get_metadata_or_return_missing(mdn,r,"authors")
    return map(x -> x["full_name"], mdn)
end

function emails(r::Record; current=true)
    @get_metadata_or_return_missing(mdn,r,"email_addresses")
    fmdn = filter(x -> !(current) || x["current"], mdn)
    return get.(fmdn, "value", missing)
end

function inspire_identifier(r::Record)
    @get_metadata_or_return_missing(ids, r, "ids")

    identifier = missing
    for id in ids
        if id["schema"] == "INSPIRE BAI"
            identifier = id["value"]
        end
    end
    return identifier
end

function articles(r::Record)
    iid = inspire_identifier(r)
    ismissing(iid) && return missing
    
    resp = InspireGet.search("literature", iid)
    my_articles = JSON.parse(String(resp.body))["hits"]["hits"]

    return Record.("literature", my_articles)
end

function Base.show(io::IO, r::Record)
    ucft = uppercasefirst(r.type)

    println("Inspire Record ($(ucft))")
    println(io, "\tId:", r.id)
    println(io, "\tCreated:", r.created)
    println(io, "\tUpdated:", r.created)

    metadatas = [
                 ("Name",    name(r)),
                 ("Title",   title(r)),
                 ("Authors", author_full_names(r)),
                ]

    foreach(metadatas) do (lbl, val)
        ismissing(val) && return 
        isa(val, Vector) && (val = join(val, "; "))
        println(io, "\t",lbl,":", val)
    end
end
