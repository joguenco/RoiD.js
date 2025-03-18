# HTTP methods
* GET - return a resource
* POST - create a new resources
* PUT - create or replaces a resource
* PATCH - partially update a resource
* DELETE - delete a resource

# HTTP Semantics & Status codes
* GET
  * 200 (OK), 404 (Not Found)
* POST
  * 201 (Created), 400 (Bad Request)
* PUT
  * 201 (Created), 204 (No Content) or 200 (OK), 409 (Conflict)
* PATCH
  * 204 (No Content) or 400/409
* DELETE
  * 204 (No Content) or 404 (Not Found)

1xx - Informational messages
2xx - Success messages
3xx - Redirection messages
4xx - Client Error messages
5xx - Server Error messages

