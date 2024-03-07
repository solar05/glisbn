# glisbn

[![Package Version](https://img.shields.io/hexpm/v/glisbn)](https://hex.pm/packages/glisbn)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glisbn/)

A ISBN utility library for the Gleam.

```sh
gleam add glisbn
```
```gleam
import glisbn

pub fn main() {
  let isbn10 = "9788535902778"
  glisbn.is_valid(isbn10) // -> true

  glisbn.hyphenate(isbn10) // -> Ok("978-85-359-0277-8")

  glisbn.isbn10_to_13(isbn10) // -> Ok("9789788535904")

  glisbn.get_publisher_zone(isbn10) // -> Ok("Brazil")

  // for more other usage examples see docs
}
```

Further documentation can be found at <https://hexdocs.pm/glisbn>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
