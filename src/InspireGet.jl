module InspireGet

import HTTP
import HTTP
import JSON
import Dates
import TimeZones: ZonedDateTime

const INSPIRE_API_URL = "https://inspirehep.net/api"

const RECORD_TYPES = (
                      "literature", 
                      "authors", 
                      "institutions", 
                      "conferences", 
                      "seminars", 
                      "journals", 
                      "jobs", 
                      "experiments", 
                      "data"
                     )

const IDENTIFIERS  = (
                      RECORD_TYPES...,
                      "doi",
                      "arxiv",
                      "orcid"
                     )

function check_format(content_format::String)
    if !(haskey(CONTENT_FORMATS, content_format))
        throw(DomainError(content_format, 
                          "Not a valid content format. \
                          Valid formats are the following: \
                          $(join(keys(CONTENT_FORMATS), ", ", ", and "))."))
    end
end

function check_identifier_type(identifier_type::String)
    if !(identifier_type in IDENTIFIERS)
        throw(DomainError(identifier_type, 
                          "Not a valid identifier type. \
                          Valid types are the following: \
                          $(join(IDENTIFIERS, ", ", ", and "))."))
    end
end

function search(identifier_type::String, query::String; content_format = "json"
    )::HTTP.Messages.Response

    return search(identifier_type, Dict("q" => query); content_format = content_format)
    
end

function search(identifier_type::String, search_params::Dict; 
        content_format = "json"
    )::HTTP.Messages.Response

    check_identifier_type(identifier_type)
    check_format(content_format)

    url = join((INSPIRE_API_URL, identifier_type), '/')
    headers = ["Accept" => CONTENT_FORMATS[content_format]]
    
    return HTTP.get(url, headers; query = search_params)
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

function parse_inspire_timestamp(ts::AbstractString)
    no_ns_ts = replace(ts, r"\.\d*\+"=>"+")
    return ZonedDateTime(no_ns_ts, Dates.dateformat"y-m-dTH:M:S+z")
end

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

const CONTENT_FORMATS = Dict("json" => "application/json",
                            "bibtex" => "application/x-bibtex",
                            "latex-eu" => "application/vnd+inspire.latex.eu+x-latex",
                            "latex-us" => "application/vnd+inspire.latex.us+x-latex")

end # module
