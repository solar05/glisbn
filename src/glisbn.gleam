//// A ISBN utility library.

import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import regions

pub type IsbnError {
  InvalidIsbn
  RegistrantNotFound
}

/// Takes an ISBN (10 or 13) and checks its validity by checking the checkdigit, length and characters.
///
/// ## Examples
///
/// ```gleam
/// is_valid("978-5-12345-678-1")
/// // -> True
/// ```
///
/// ```gleam
/// is_valid("85-359-0277-5")
/// // -> True
/// ```
///
/// ```gleam
/// is_valid("85-359-0277")
/// // -> False
/// ```
///
/// ```gleam
/// is_valid("str")
/// // -> False
/// ```
///
pub fn is_valid(isbn: String) -> Bool {
  is_chars_correct(isbn) && is_checkdigit_valid(isbn)
}

/// Takes an ISBN (10 or 13) and checks its validity by its checkdigit.
///
/// ## Examples
///
/// ```gleam
/// is_checkdigit_valid("85-359-0277-5")
/// // -> True
/// ```
///
/// ```gleam
/// is_checkdigit_valid("978-5-12345-678-1")
/// // -> True
/// ```
///
/// ```gleam
/// is_checkdigit_valid("978-5-12345-678")
/// // -> False
/// ```
///
pub fn is_checkdigit_valid(isbn: String) -> Bool {
  let normalized_isbn = normalize(isbn)
  let length: Int = string.length(normalized_isbn)
  use <- bool.guard(when: length != 10 && length != 13, return: False)

  let assert Ok(digit) = case length {
    10 -> isbn10_checkdigit(normalized_isbn)
    _ -> isbn13_checkdigit(normalized_isbn)
  }

  let assert Ok(last_digit) = string.last(normalized_isbn)

  digit == last_digit
}

/// Takes an ISBN 10 code as string, returns its check digit.
///
/// ## Examples
///
/// ```gleam
/// isbn10_checkdigit("85-359-0277")
/// // -> Ok("5")
/// ```
///
/// ```gleam
/// isbn10_checkdigit("5-02-013850")
/// // -> Ok("9")
/// ```
///
/// ```gleam
/// isbn10_checkdigit("0str")
/// // -> Error(InvalidIsbn)
/// ```
///
/// ```gleam
/// isbn10_checkdigit("887385107")
/// // -> Ok("X")
/// ```
///
pub fn isbn10_checkdigit(isbn: String) -> Result(String, IsbnError) {
  let normalized_isbn: String = normalize(isbn)
  let length: Int = string.length(normalized_isbn)
  use <- bool.guard(when: length < 8 || length > 10, return: Error(InvalidIsbn))

  let assert Ok(nsum) =
    normalized_isbn
    |> string.slice(0, 9)
    |> string.split("")
    |> list.map(fn(num) {
      let assert Ok(res) = int.parse(num)
      res
    })
    |> list.index_map(fn(digit, pos) { { 10 - pos } * digit })
    |> list.reduce(fn(acc, x) { acc + x })

  let assert Ok(first_part) = int.modulo(nsum, 11)
  let assert Ok(final_part) = int.modulo(11 - first_part, 11)

  case final_part {
    10 -> Ok("X")
    _ -> Ok(int.to_string(final_part))
  }
}

/// Takes an ISBN 13 code as string, returns its check digit.
///
/// ## Examples
///
/// ```gleam
/// isbn13_checkdigit("978-5-12345-678")
/// // -> Ok("1")
/// ```
///
/// ```gleam
/// isbn13_checkdigit("978-0-306-40615")
/// // -> Ok("7")
/// ```
///
/// ```gleam
/// isbn13_checkdigit("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn isbn13_checkdigit(isbn: String) -> Result(String, IsbnError) {
  let normalized_isbn: String = normalize(isbn)
  let length: Int = string.length(normalized_isbn)
  use <- bool.guard(
    when: length < 11 || length > 13,
    return: Error(InvalidIsbn),
  )

  let assert Ok(nsum) =
    normalized_isbn
    |> string.slice(0, 12)
    |> string.split("")
    |> list.map(fn(num) {
      let assert Ok(res) = int.parse(num)
      res
    })
    |> list.index_map(fn(digit, pos) {
      case int.is_odd(pos) {
        True -> digit * 3
        False -> digit
      }
    })
    |> list.reduce(fn(acc, x) { acc + x })

  let assert Ok(first_part) = int.modulo(nsum, 10)
  let final_part: Int = 10 - first_part

  case final_part {
    10 -> Ok("0")
    _ -> Ok(int.to_string(final_part))
  }
}

/// Takes an ISBN 10 and converts it to ISBN 13.
///
/// ## Examples
///
/// ```gleam
/// isbn10_to_13("85-359-0277-5")
/// // -> Ok("9788535902778")
/// ```
///
/// ```gleam
/// isbn10_to_13("0306406152")
/// // -> Ok("9780306406157")
/// ```
///
/// ```gleam
/// isbn10_to_13("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn isbn10_to_13(isbn: String) -> Result(String, IsbnError) {
  let normalized = normalize(isbn)
  case string.length(normalized) == 10 && is_valid(normalized) {
    True -> {
      let first_chars = "978" <> string.slice(normalized, 0, 9)
      let assert Ok(checkdigit) = isbn13_checkdigit(first_chars)
      Ok(first_chars <> checkdigit)
    }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN 13 and converts it to ISBN 10.
/// Only ISBNs with the 978 prefix can be converted;
/// 979-prefixed ISBNs have no ISBN-10 equivalent.
///
/// ## Examples
///
/// ```gleam
/// isbn13_to_10("9788535902778")
/// // -> Ok("8535902775")
/// ```
///
/// ```gleam
/// isbn13_to_10("9780306406157")
/// // -> Ok("0306406152")
/// ```
///
/// ```gleam
/// isbn13_to_10("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn isbn13_to_10(isbn: String) -> Result(String, IsbnError) {
  let normalized = normalize(isbn)
  case
    string.length(normalized) == 13
    && string.starts_with(normalized, "978")
    && is_valid(normalized)
  {
    True -> {
      let first_chars = string.slice(normalized, 3, 9)
      let assert Ok(checkdigit) = isbn10_checkdigit(first_chars)
      Ok(first_chars <> checkdigit)
    }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN and returns its prefix.
///
/// ## Examples
///
/// ```gleam
/// get_prefix("9788535902778")
/// // -> Ok("978-85")
/// ```
///
/// ```gleam
/// get_prefix("2-1234-5680-2")
/// // -> Ok("978-2")
/// ```
///
/// ```gleam
/// get_prefix("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn get_prefix(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True -> {
      let prepared_isbn = to_isbn13(isbn)
      search_prefix(
        string.slice(prepared_isbn, 0, 3),
        drop_chars(prepared_isbn, 3),
        0,
      )
    }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN and returns its checkdigit.
///
/// ## Examples
///
/// ```gleam
/// get_checkdigit("9788535902778")
/// // -> Ok("8")
/// ```
///
/// ```gleam
/// get_checkdigit("2-1234-5680-2")
/// // -> Ok("2")
/// ```
///
/// ```gleam
/// get_checkdigit("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
/// ```gleam
/// get_checkdigit("887385107X")
/// // -> Ok("X")
/// ```
///
pub fn get_checkdigit(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True -> {
      let assert Ok(result) = string.last(isbn)
      Ok(result)
    }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN and returns its publisher zone.
///
/// ## Examples
///
/// ```gleam
/// get_publisher_zone("9788535902778")
/// // -> Ok("Brazil")
/// ```
///
/// ```gleam
/// get_publisher_zone("2-1234-5680-2")
/// // -> Ok("French language")
/// ```
///
/// ```gleam
/// get_publisher_zone("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn get_publisher_zone(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True ->
      case get_info(to_isbn13(isbn)) {
        Ok(region) -> Ok(region.name)
        Error(e) -> Error(e)
      }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN and returns its registrant element.
///
/// ## Examples
///
/// ```gleam
/// get_registrant_element("9788535902778")
/// // -> Ok("359")
/// ```
///
/// ```gleam
/// get_registrant_element("978-1-86197-876-9")
/// // -> Ok("86197")
/// ```
///
/// ```gleam
/// get_registrant_element("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn get_registrant_element(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True ->
      case find_elements(to_isbn13(isbn)) {
        Ok(#(registrant, _)) -> Ok(registrant)
        Error(e) -> Error(e)
      }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN and returns its publication element.
///
/// ## Examples
///
/// ```gleam
/// get_publication_element("978-1-86197-876-9")
/// // -> Ok("876")
/// ```
///
/// ```gleam
/// get_publication_element("9789529351787")
/// // -> Ok("5178")
/// ```
///
/// ```gleam
/// get_publication_element("1str")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn get_publication_element(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True ->
      case find_elements(to_isbn13(isbn)) {
        Ok(#(_, publication)) -> Ok(publication)
        Error(e) -> Error(e)
      }
    False -> Error(InvalidIsbn)
  }
}

/// Takes an ISBN (10 or 13) and hyphenates it.
///
/// ## Examples
///
/// ```gleam
/// hyphenate("9788535902778")
/// // -> Ok("978-85-359-0277-8")
/// ```
///
/// ```gleam
/// hyphenate("0306406152")
/// // -> Ok("0-306-40615-2")
/// ```
///
/// ```gleam
/// hyphenate("978-5-12345-678")
/// // -> Error(InvalidIsbn)
/// ```
///
pub fn hyphenate(isbn: String) -> Result(String, IsbnError) {
  case is_correct(isbn) {
    True ->
      case is_isbn10(isbn) {
        True -> hyphenate_isbn10(isbn)
        False -> hyphenate_isbn13(isbn)
      }
    False -> Error(InvalidIsbn)
  }
}

/// Checks if an ISBN (10 or 13) code is correctly hyphenated. If ISBN incorrect, that count as no.
///
/// ## Examples
///
/// ```gleam
/// is_hyphens_correct("978-85-359-0277-8")
/// // -> True
/// ```
///
/// ```gleam
/// is_hyphens_correct("0-306-40615-2")
/// // -> True
/// ```
///
/// ```gleam
/// is_hyphens_correct("97-8853590277-8")
/// // -> False
/// ```
///
/// ```gleam
/// is_hyphens_correct("03-064-06152")
/// // -> False
/// ```
///
/// ```gleam
/// is_hyphens_correct("str")
/// // -> False
/// ```
///
pub fn is_hyphens_correct(isbn: String) -> Bool {
  case is_correct(isbn) {
    True ->
      case hyphenate(isbn) {
        Ok(result) -> isbn == result
        Error(_) -> False
      }
    False -> False
  }
}

fn is_length_correct(isbn: String) -> Bool {
  let length: Int = string.length(isbn)
  length == 10 || length == 13
}

fn drop_chars(str: String, amount: Int) -> String {
  string.slice(from: str, at_index: amount, length: string.length(str))
}

fn is_digit(ch: String) -> Bool {
  "0123456789"
  |> string.contains(ch)
}

fn normalize(isbn: String) -> String {
  isbn
  |> string.split("")
  |> list.filter(fn(ch) { is_digit(ch) || ch == "X" })
  |> string.join("")
}

fn is_chars_correct(isbn: String) -> Bool {
  isbn
  |> normalize()
  |> is_length_correct()
}

fn is_isbn10(isbn: String) -> Bool {
  let length: Int =
    isbn
    |> normalize()
    |> string.length()
  length == 10
}

fn is_correct(isbn: String) -> Bool {
  isbn
  |> normalize()
  |> is_valid()
}

fn to_isbn13(isbn: String) -> String {
  case is_isbn10(isbn) {
    True -> {
      let assert Ok(result) = isbn10_to_13(isbn)
      result
    }
    False -> normalize(isbn)
  }
}

fn search_prefix(
  prefix: String,
  body: String,
  search_length: Int,
) -> Result(String, IsbnError) {
  use <- bool.guard(
    when: search_length > string.length(body),
    return: Error(InvalidIsbn),
  )
  let search_candidate: String =
    prefix <> "-" <> string.slice(body, 0, search_length)

  case list.find(regions.dataset, fn(x) { x.code == search_candidate }) {
    Ok(_) -> Ok(search_candidate)
    Error(Nil) -> search_prefix(prefix, body, search_length + 1)
  }
}

fn get_body(isbn: String, prefix: String) -> String {
  let start = string.length(prefix) - 1
  string.slice(isbn, start, string.length(isbn) - start - 1)
}

fn get_info(isbn: String) -> Result(regions.Dataset, IsbnError) {
  case get_prefix(isbn) {
    Ok(prefix) ->
      case list.find(regions.dataset, fn(x) { x.code == prefix }) {
        Ok(region) -> Ok(region)
        Error(_) -> Error(InvalidIsbn)
      }
    Error(e) -> Error(e)
  }
}

fn find_elements(
  prepared_isbn: String,
) -> Result(#(String, String), IsbnError) {
  case get_prefix(prepared_isbn) {
    Error(e) -> Error(e)
    Ok(prefix) -> {
      let body = get_body(prepared_isbn, prefix)
      case list.find(regions.dataset, fn(x) { x.code == prefix }) {
        Error(_) -> Error(InvalidIsbn)
        Ok(region) ->
          case
            list.find(region.ranges, fn(range) {
              let assert Ok(first_part) = list.first(range)
              let assert Ok(begin) = int.parse(first_part)
              let assert Ok(last_part) = list.last(range)
              let assert Ok(end) = int.parse(last_part)
              let length = string.length(last_part)
              let range_part = string.slice(body, 0, length)
              let assert Ok(area) = int.parse(range_part)
              begin <= area && area <= end
            })
          {
            Ok(range) -> {
              let assert Ok(last_part) = list.last(range)
              let length = string.length(last_part)
              let registrant = string.slice(body, 0, length)
              let publication = drop_chars(body, length)
              Ok(#(registrant, publication))
            }
            Error(_) -> Error(RegistrantNotFound)
          }
      }
    }
  }
}

fn hyphenate_isbn13(isbn: String) -> Result(String, IsbnError) {
  let normalized = normalize(isbn)
  case get_prefix(normalized) {
    Error(e) -> Error(e)
    Ok(prefix) -> {
      let assert Ok(checkdigit) = string.last(normalized)
      case find_elements(normalized) {
        Ok(#(registrant, publication)) ->
          Ok(string.join([prefix, registrant, publication, checkdigit], "-"))
        Error(e) -> Error(e)
      }
    }
  }
}

fn hyphenate_isbn10(isbn: String) -> Result(String, IsbnError) {
  case isbn10_to_13(isbn) {
    Error(e) -> Error(e)
    Ok(isbn13) ->
      case get_prefix(isbn13) {
        Error(e) -> Error(e)
        Ok(fullprefix) -> {
          let assert Ok(isbn10_prefix) =
            string.split(fullprefix, "-")
            |> list.last()
          let assert Ok(checkdigit) = string.last(normalize(isbn))
          case find_elements(isbn13) {
            Ok(#(registrant, publication)) ->
              Ok(string.join(
                [isbn10_prefix, registrant, publication, checkdigit],
                "-",
              ))
            Error(e) -> Error(e)
          }
        }
      }
  }
}
