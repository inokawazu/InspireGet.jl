module InspireGet

using HTTP: get
import HTTP

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
             (INSPIRE_API_URL, identifier_type, identifier_value), ','
            )
       )
end

end # module
