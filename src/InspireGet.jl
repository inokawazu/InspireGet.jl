module InspireGet

using HTTP: get
import HTTP
import JSON
import Dates
import TimeZones: ZonedDateTime

const INSPIRE_API_URL = "https://inspirehep.net/api"

const IDENTIFIERS = ("literature", 
                     "authors", 
                     "institutions", 
                     "conferences", 
                     "seminars", 
                     "journals", 
                     "jobs", 
                     "experiments", 
                     "data",
                     "doi",
                     "arxiv",
                     "orcid")

function get_record(identifier_type::AbstractString, identifier_value::AbstractString)::HTTP.Messages.Response
    if !(identifier_type in IDENTIFIERS)
        throw(DomainError(identifier_type, 
                          "Not a valid identifier type. \
                          Valid types are the following: $(join(IDENTIFIERS, " "))."))
    end

    return get(
        join(
             (INSPIRE_API_URL, identifier_type, identifier_value), '/'
            )
       )
end

function parse_inspire_timestamp(ts::AbstractString)
    no_ns_ts = replace(ts, r"\.\d*\+"=>"+")
    return ZonedDateTime(no_ns_ts, Dates.dateformat"y-m-dTH:M:Ss+z")
end

struct Record
    id::Int
    created
    updated
    links::Dict{String,String}
    metadata::Dict
end

function Record(identifier_type::AbstractString, identifier_value::AbstractString)
    resp = get_record(identifier_type, identifier_value)
    return Record(resp)
end

function Record(resp::HTTP.Messages.Response)
    json = JSON.parse(String(resp.body))

    id = parse(Int,json["id"])
    created = parse_inspire_timestamp(json["created"])
    updated = parse_inspire_timestamp(json["updated"])
    links = Dict{String, String}(json["links"])
    metadata = json["metadata"]

    return Record(id, created, updated, links, metadata)

end

end # module
