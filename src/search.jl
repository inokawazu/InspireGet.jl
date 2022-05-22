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
