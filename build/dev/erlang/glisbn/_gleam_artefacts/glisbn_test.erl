-module(glisbn_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([main/0, is_valid_test/0, is_checkdigit_valid_test/0, isbn10_checkdigit_test/0, isbn13_checkdigit_test/0, isbn10_to_13_test/0, isbn13_to_10_test/0, get_checkdigit_test/0, get_prefix_test/0, get_publisher_zone_test/0, get_registrant_element_test/0, get_publication_element_test/0, hyphenate_test/0, is_hyphenate_correct_test/0]).

-spec main() -> nil.
main() ->
    gleeunit:main().

-spec is_valid_test() -> nil.
is_valid_test() ->
    _pipe = <<"978-5-12345-678-1"/utf8>>,
    _pipe@1 = glisbn:is_valid(_pipe),
    gleeunit@should:be_true(_pipe@1),
    _pipe@2 = <<"978-5-12345-678"/utf8>>,
    _pipe@3 = glisbn:is_valid(_pipe@2),
    gleeunit@should:be_false(_pipe@3),
    _pipe@4 = <<"85-359-0277-5"/utf8>>,
    _pipe@5 = glisbn:is_valid(_pipe@4),
    gleeunit@should:be_true(_pipe@5),
    _pipe@6 = <<"85-359-0277"/utf8>>,
    _pipe@7 = glisbn:is_valid(_pipe@6),
    gleeunit@should:be_false(_pipe@7),
    _pipe@8 = <<"some-str"/utf8>>,
    _pipe@9 = glisbn:is_valid(_pipe@8),
    gleeunit@should:be_false(_pipe@9),
    _pipe@10 = <<"123-123-123-123-123"/utf8>>,
    _pipe@11 = glisbn:is_valid(_pipe@10),
    gleeunit@should:be_false(_pipe@11).

-spec is_checkdigit_valid_test() -> nil.
is_checkdigit_valid_test() ->
    _pipe = <<"85-359-0277-5"/utf8>>,
    _pipe@1 = glisbn:is_checkdigit_valid(_pipe),
    gleeunit@should:be_true(_pipe@1),
    _pipe@2 = <<"978-5-12345-678-1"/utf8>>,
    _pipe@3 = glisbn:is_checkdigit_valid(_pipe@2),
    gleeunit@should:be_true(_pipe@3),
    _pipe@4 = <<"978-5-12345-678"/utf8>>,
    _pipe@5 = glisbn:is_checkdigit_valid(_pipe@4),
    gleeunit@should:be_false(_pipe@5),
    _pipe@6 = <<"978-5-12345-111111111"/utf8>>,
    _pipe@7 = glisbn:is_checkdigit_valid(_pipe@6),
    gleeunit@should:be_false(_pipe@7),
    _pipe@8 = <<"something"/utf8>>,
    _pipe@9 = glisbn:is_checkdigit_valid(_pipe@8),
    gleeunit@should:be_false(_pipe@9).

-spec isbn10_checkdigit_test() -> nil.
isbn10_checkdigit_test() ->
    _pipe = <<"85-359-0277"/utf8>>,
    _pipe@1 = glisbn:isbn10_checkdigit(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"5"/utf8>>}),
    _pipe@2 = <<"5-02-013850"/utf8>>,
    _pipe@3 = glisbn:isbn10_checkdigit(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"9"/utf8>>}),
    _pipe@4 = <<"0str"/utf8>>,
    _pipe@5 = glisbn:isbn10_checkdigit(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}),
    _pipe@6 = <<"887385107"/utf8>>,
    _pipe@7 = glisbn:isbn10_checkdigit(_pipe@6),
    gleeunit_ffi:should_equal(_pipe@7, {ok, <<"X"/utf8>>}).

-spec isbn13_checkdigit_test() -> nil.
isbn13_checkdigit_test() ->
    _pipe = <<"978-5-12345-678"/utf8>>,
    _pipe@1 = glisbn:isbn13_checkdigit(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"1"/utf8>>}),
    _pipe@2 = <<"978-0-306-40615"/utf8>>,
    _pipe@3 = glisbn:isbn13_checkdigit(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"7"/utf8>>}),
    _pipe@4 = <<"0str"/utf8>>,
    _pipe@5 = glisbn:isbn13_checkdigit(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}).

-spec isbn10_to_13_test() -> nil.
isbn10_to_13_test() ->
    _pipe = <<"85-359-0277-5"/utf8>>,
    _pipe@1 = glisbn:isbn10_to_13(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"9788535902778"/utf8>>}),
    _pipe@2 = <<"9788535902778"/utf8>>,
    _pipe@3 = glisbn:is_valid(_pipe@2),
    gleeunit@should:be_true(_pipe@3),
    _pipe@4 = <<"0306406152"/utf8>>,
    _pipe@5 = glisbn:isbn10_to_13(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {ok, <<"9780306406157"/utf8>>}),
    _pipe@6 = <<"9780306406157"/utf8>>,
    _pipe@7 = glisbn:is_valid(_pipe@6),
    gleeunit@should:be_true(_pipe@7),
    _pipe@8 = <<"0-19-853453123"/utf8>>,
    _pipe@9 = glisbn:isbn10_to_13(_pipe@8),
    gleeunit_ffi:should_equal(_pipe@9, {error, invalid_isbn}).

-spec isbn13_to_10_test() -> nil.
isbn13_to_10_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:isbn13_to_10(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"8535902775"/utf8>>}),
    _pipe@2 = <<"8535902775"/utf8>>,
    _pipe@3 = glisbn:is_valid(_pipe@2),
    gleeunit@should:be_true(_pipe@3),
    _pipe@4 = <<"9780306406157"/utf8>>,
    _pipe@5 = glisbn:isbn13_to_10(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {ok, <<"0306406152"/utf8>>}),
    _pipe@6 = <<"0306406152"/utf8>>,
    _pipe@7 = glisbn:is_valid(_pipe@6),
    gleeunit@should:be_true(_pipe@7),
    _pipe@8 = <<"str"/utf8>>,
    _pipe@9 = glisbn:isbn13_to_10(_pipe@8),
    gleeunit_ffi:should_equal(_pipe@9, {error, invalid_isbn}).

-spec get_checkdigit_test() -> nil.
get_checkdigit_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:get_checkdigit(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"8"/utf8>>}),
    _pipe@2 = <<"2-1234-5680-2"/utf8>>,
    _pipe@3 = glisbn:get_checkdigit(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"2"/utf8>>}),
    _pipe@4 = <<"str"/utf8>>,
    _pipe@5 = glisbn:get_checkdigit(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}),
    _pipe@6 = <<"887385107X"/utf8>>,
    _pipe@7 = glisbn:get_checkdigit(_pipe@6),
    gleeunit_ffi:should_equal(_pipe@7, {ok, <<"X"/utf8>>}).

-spec get_prefix_test() -> nil.
get_prefix_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:get_prefix(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"978-85"/utf8>>}),
    _pipe@2 = <<"2-1234-5680-2"/utf8>>,
    _pipe@3 = glisbn:get_prefix(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"978-2"/utf8>>}),
    _pipe@4 = <<"str"/utf8>>,
    _pipe@5 = glisbn:get_prefix(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}).

-spec get_publisher_zone_test() -> nil.
get_publisher_zone_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:get_publisher_zone(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"Brazil"/utf8>>}),
    _pipe@2 = <<"2-1234-5680-2"/utf8>>,
    _pipe@3 = glisbn:get_publisher_zone(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"French language"/utf8>>}),
    _pipe@4 = <<"str"/utf8>>,
    _pipe@5 = glisbn:get_publisher_zone(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}).

-spec get_registrant_element_test() -> nil.
get_registrant_element_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:get_registrant_element(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"359"/utf8>>}),
    _pipe@2 = <<"978-1-86197-876-9"/utf8>>,
    _pipe@3 = glisbn:get_registrant_element(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"86197"/utf8>>}),
    _pipe@4 = <<"9789529351787"/utf8>>,
    _pipe@5 = glisbn:get_registrant_element(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {ok, <<"93"/utf8>>}),
    _pipe@6 = <<"str"/utf8>>,
    _pipe@7 = glisbn:get_registrant_element(_pipe@6),
    gleeunit_ffi:should_equal(_pipe@7, {error, invalid_isbn}).

-spec get_publication_element_test() -> nil.
get_publication_element_test() ->
    _pipe = <<"978-1-86197-876-9"/utf8>>,
    _pipe@1 = glisbn:get_publication_element(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"876"/utf8>>}),
    _pipe@2 = <<"9789529351787"/utf8>>,
    _pipe@3 = glisbn:get_publication_element(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"5178"/utf8>>}),
    _pipe@4 = <<"str"/utf8>>,
    _pipe@5 = glisbn:get_publication_element(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {error, invalid_isbn}).

-spec hyphenate_test() -> nil.
hyphenate_test() ->
    _pipe = <<"9788535902778"/utf8>>,
    _pipe@1 = glisbn:hyphenate(_pipe),
    gleeunit_ffi:should_equal(_pipe@1, {ok, <<"978-85-359-0277-8"/utf8>>}),
    _pipe@2 = <<"0306406152"/utf8>>,
    _pipe@3 = glisbn:hyphenate(_pipe@2),
    gleeunit_ffi:should_equal(_pipe@3, {ok, <<"0-306-40615-2"/utf8>>}),
    _pipe@4 = <<"0-306-40615-2"/utf8>>,
    _pipe@5 = glisbn:hyphenate(_pipe@4),
    gleeunit_ffi:should_equal(_pipe@5, {ok, <<"0-306-40615-2"/utf8>>}),
    _pipe@6 = <<"str"/utf8>>,
    _pipe@7 = glisbn:hyphenate(_pipe@6),
    gleeunit_ffi:should_equal(_pipe@7, {error, invalid_isbn}).

-spec is_hyphenate_correct_test() -> nil.
is_hyphenate_correct_test() ->
    _pipe = <<"978-85-359-0277-8"/utf8>>,
    _pipe@1 = glisbn:is_hyphens_correct(_pipe),
    gleeunit@should:be_true(_pipe@1),
    _pipe@2 = <<"0-306-40615-2"/utf8>>,
    _pipe@3 = glisbn:is_hyphens_correct(_pipe@2),
    gleeunit@should:be_true(_pipe@3),
    _pipe@4 = <<"97-8853590277-8"/utf8>>,
    _pipe@5 = glisbn:is_hyphens_correct(_pipe@4),
    gleeunit@should:be_false(_pipe@5),
    _pipe@6 = <<"03-064-06152"/utf8>>,
    _pipe@7 = glisbn:is_hyphens_correct(_pipe@6),
    gleeunit@should:be_false(_pipe@7),
    _pipe@8 = <<"strr"/utf8>>,
    _pipe@9 = glisbn:is_hyphens_correct(_pipe@8),
    gleeunit@should:be_false(_pipe@9).
