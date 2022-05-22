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

const CONTENT_FORMATS = Dict(
                             "json"     => "application/json",
                             "bibtex"   => "application/x-bibtex",
                             "latex-eu" => "application/vnd+inspire.latex.eu+x-latex",
                             "latex-us" => "application/vnd+inspire.latex.us+x-latex"
                            )

include("util.jl")
include("error_checking.jl")
include("search.jl")
include("record.jl")

end # module
