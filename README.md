# InspireHEP.jl

A small interface between Julia and HEP API.

## Guide

**Getting a record**

Using `get_record`.

```julia
    type = "authors"
    id = "999108"
    get_record(identifier_type, id) # returns a Record struct.
```

where the following are possible record types.

- literature 
- authors 
- institutions 
- conferences 
- seminars 
- journals 
- jobs 
- experiments 

## Sources

[HEP API Documentation](https://github.com/inspirehep/rest-api-doc)
