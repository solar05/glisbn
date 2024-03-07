import gleeunit
import glisbn
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn is_valid_test() {
  "978-5-12345-678-1"
  |> glisbn.is_valid()
  |> should.be_true()

  "978-5-12345-678"
  |> glisbn.is_valid()
  |> should.be_false()

  "85-359-0277-5"
  |> glisbn.is_valid()
  |> should.be_true()

  "85-359-0277"
  |> glisbn.is_valid()
  |> should.be_false()

  "some-str"
  |> glisbn.is_valid()
  |> should.be_false()

  "123-123-123-123-123"
  |> glisbn.is_valid()
  |> should.be_false()
}

pub fn is_checkdigit_valid_test() {
  "85-359-0277-5"
  |> glisbn.is_checkdigit_valid()
  |> should.be_true()

  "978-5-12345-678-1"
  |> glisbn.is_checkdigit_valid()
  |> should.be_true()

  "978-5-12345-678"
  |> glisbn.is_checkdigit_valid()
  |> should.be_false()

  "978-5-12345-111111111"
  |> glisbn.is_checkdigit_valid()
  |> should.be_false()

  "something"
  |> glisbn.is_checkdigit_valid()
  |> should.be_false()
}

pub fn isbn10_checkdigit_test() {
  "85-359-0277"
  |> glisbn.isbn10_checkdigit()
  |> should.equal(Ok("5"))

  "5-02-013850"
  |> glisbn.isbn10_checkdigit()
  |> should.equal(Ok("9"))

  "0str"
  |> glisbn.isbn10_checkdigit()
  |> should.equal(Error(glisbn.InvalidIsbn))

  "887385107"
  |> glisbn.isbn10_checkdigit()
  |> should.equal(Ok("X"))
}

pub fn isbn13_checkdigit_test() {
  "978-5-12345-678"
  |> glisbn.isbn13_checkdigit()
  |> should.equal(Ok("1"))

  "978-0-306-40615"
  |> glisbn.isbn13_checkdigit()
  |> should.equal(Ok("7"))

  "0str"
  |> glisbn.isbn13_checkdigit()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn isbn10_to_13_test() {
  "85-359-0277-5"
  |> glisbn.isbn10_to_13()
  |> should.equal(Ok("9788535902778"))

  "9788535902778"
  |> glisbn.is_valid()
  |> should.be_true()

  "0306406152"
  |> glisbn.isbn10_to_13()
  |> should.equal(Ok("9780306406157"))

  "9780306406157"
  |> glisbn.is_valid()
  |> should.be_true()

  "0-19-853453123"
  |> glisbn.isbn10_to_13()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn isbn13_to_10_test() {
  "9788535902778"
  |> glisbn.isbn13_to_10()
  |> should.equal(Ok("8535902775"))

  "8535902775"
  |> glisbn.is_valid()
  |> should.be_true()

  "9780306406157"
  |> glisbn.isbn13_to_10()
  |> should.equal(Ok("0306406152"))

  "0306406152"
  |> glisbn.is_valid()
  |> should.be_true()

  "str"
  |> glisbn.isbn13_to_10()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn get_checkdigit_test() {
  "9788535902778"
  |> glisbn.get_checkdigit()
  |> should.equal(Ok("8"))

  "2-1234-5680-2"
  |> glisbn.get_checkdigit()
  |> should.equal(Ok("2"))

  "str"
  |> glisbn.get_checkdigit()
  |> should.equal(Error(glisbn.InvalidIsbn))

  "887385107X"
  |> glisbn.get_checkdigit()
  |> should.equal(Ok("X"))
}

pub fn get_prefix_test() {
  "9788535902778"
  |> glisbn.get_prefix()
  |> should.equal(Ok("978-85"))

  "2-1234-5680-2"
  |> glisbn.get_prefix()
  |> should.equal(Ok("978-2"))

  "str"
  |> glisbn.get_prefix()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn get_publisher_zone_test() {
  "9788535902778"
  |> glisbn.get_publisher_zone()
  |> should.equal(Ok("Brazil"))

  "2-1234-5680-2"
  |> glisbn.get_publisher_zone()
  |> should.equal(Ok("French language"))

  "str"
  |> glisbn.get_publisher_zone()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn get_registrant_element_test() {
  "9788535902778"
  |> glisbn.get_registrant_element()
  |> should.equal(Ok("359"))

  "978-1-86197-876-9"
  |> glisbn.get_registrant_element()
  |> should.equal(Ok("86197"))

  "9789529351787"
  |> glisbn.get_registrant_element()
  |> should.equal(Ok("93"))

  "str"
  |> glisbn.get_registrant_element()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn get_publication_element_test() {
  "978-1-86197-876-9"
  |> glisbn.get_publication_element()
  |> should.equal(Ok("876"))

  "9789529351787"
  |> glisbn.get_publication_element()
  |> should.equal(Ok("5178"))

  "str"
  |> glisbn.get_publication_element()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn hyphenate_test() {
  "9788535902778"
  |> glisbn.hyphenate()
  |> should.equal(Ok("978-85-359-0277-8"))

  "0306406152"
  |> glisbn.hyphenate()
  |> should.equal(Ok("0-306-40615-2"))

  "0-306-40615-2"
  |> glisbn.hyphenate()
  |> should.equal(Ok("0-306-40615-2"))

  "str"
  |> glisbn.hyphenate()
  |> should.equal(Error(glisbn.InvalidIsbn))
}

pub fn is_hyphenate_correct_test() {
  "978-85-359-0277-8"
  |> glisbn.is_hyphens_correct()
  |> should.be_true()

  "0-306-40615-2"
  |> glisbn.is_hyphens_correct()
  |> should.be_true()

  "97-8853590277-8"
  |> glisbn.is_hyphens_correct()
  |> should.be_false()

  "03-064-06152"
  |> glisbn.is_hyphens_correct()
  |> should.be_false()

  "strr"
  |> glisbn.is_hyphens_correct()
  |> should.be_false()
}
