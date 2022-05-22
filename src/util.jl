function parse_inspire_timestamp(ts::AbstractString)
    no_ns_ts = replace(ts, r"\.\d*\+"=>"+")
    return ZonedDateTime(no_ns_ts, Dates.dateformat"y-m-dTH:M:S+z")
end
