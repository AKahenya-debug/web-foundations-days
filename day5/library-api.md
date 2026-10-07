# Library Books REST API

This API manages books in a library system.

## Endpoints

### 1. List all books

- **Method:** GET
- **Path:** `/books`
- **Description:** Returns a list of all books.
- **Success status:** 200 OK

Example request:
get one book

```http
GET /books/xyz

Create a Book
{
  "title": "The River Between",
  "author": "Ngugi wa Thing'o",
  "year": 1965
}

Update a book
{
  "title": "The River Between",
  "author": "Ngugi wa Thing'o",
  "year": 1965
}

delete a book
DELETE/books/123

List books by author
GET /books?author=Ngugi%20Thing'o

400 Bad Request
This happens when the request contains invalid or missing data.


404 Not Found
This happens when the requested book does not exist.

```
