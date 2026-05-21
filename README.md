# glisbn

[![Package Version](https://img.shields.io/hexpm/v/glisbn)](https://hex.pm/packages/glisbn)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glisbn/)

A ISBN utility library for Gleam. Supports both ISBN-10 and ISBN-13.

```sh
gleam add glisbn
```

```gleam
import glisbn

pub fn main() {
  // Validation
  glisbn.is_valid("978-85-359-0277-8")      // -> True
  glisbn.is_valid("85-359-0277-5")          // -> True
  glisbn.is_valid("85-359-0277")            // -> False

  glisbn.is_checkdigit_valid("85-359-0277-5")  // -> True

  glisbn.is_hyphens_correct("978-85-359-0277-8")  // -> True
  glisbn.is_hyphens_correct("97-8853590277-8")    // -> False

  // Check digits
  glisbn.isbn10_checkdigit("85-359-0277")   // -> Ok("5")
  glisbn.isbn13_checkdigit("978-5-12345-678")  // -> Ok("1")
  glisbn.get_checkdigit("9788535902778")    // -> Ok("8")

  // Conversion
  glisbn.isbn10_to_13("85-359-0277-5")     // -> Ok("9788535902778")
  glisbn.isbn13_to_10("9788535902778")     // -> Ok("8535902775")

  // Hyphenation
  glisbn.hyphenate("9788535902778")        // -> Ok("978-85-359-0277-8")
  glisbn.hyphenate("0306406152")           // -> Ok("0-306-40615-2")

  // Metadata
  glisbn.get_prefix("9788535902778")            // -> Ok("978-85")
  glisbn.get_publisher_zone("9788535902778")    // -> Ok("Brazil")
  glisbn.get_registrant_element("9788535902778") // -> Ok("359")
  glisbn.get_publication_element("9788535902778") // -> Ok("0277")
}
```

## API

| Function | Description |
|---|---|
| `is_valid(isbn)` | Validates an ISBN-10 or ISBN-13 (length, characters, check digit) |
| `is_checkdigit_valid(isbn)` | Checks only the check digit of an ISBN |
| `is_hyphens_correct(isbn)` | Checks whether an ISBN is correctly hyphenated |
| `isbn10_checkdigit(isbn)` | Computes the check digit for an ISBN-10 |
| `isbn13_checkdigit(isbn)` | Computes the check digit for an ISBN-13 |
| `get_checkdigit(isbn)` | Returns the last (check) digit of a valid ISBN |
| `isbn10_to_13(isbn)` | Converts an ISBN-10 to ISBN-13 |
| `isbn13_to_10(isbn)` | Converts an ISBN-13 (978-prefix only) to ISBN-10 |
| `hyphenate(isbn)` | Returns a correctly hyphenated ISBN |
| `get_prefix(isbn)` | Returns the group prefix (e.g. `"978-85"`) |
| `get_publisher_zone(isbn)` | Returns the publisher language/region name |
| `get_registrant_element(isbn)` | Returns the registrant (publisher) element |
| `get_publication_element(isbn)` | Returns the publication element |

Errors are returned as `Result(_, IsbnError)` where `IsbnError` is either `InvalidIsbn` or `RegistrantNotFound`.

Further documentation can be found at <https://hexdocs.pm/glisbn>.

## Development

```sh
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
