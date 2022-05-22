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
