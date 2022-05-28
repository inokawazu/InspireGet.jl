using InspireGet

import InspireGet as IG

author_id = 1778034
author_record = IG.Record("authors", author_id)

println(author_record)
println("Retrived author record")

author_articles = IG.articles(author_record)
println("Retrived $(IG.name(author_record))'s articles")
