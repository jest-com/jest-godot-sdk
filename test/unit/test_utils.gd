extends GutTest
## Tests for JestUtils JSON parsing helpers


func test_parse_json_valid_dict():
	var result = JestUtils.parse_json('{"key":"value"}')
	assert_true(result is Dictionary)
	assert_eq(result["key"], "value")


func test_parse_json_valid_array():
	var result = JestUtils.parse_json('[1,2,3]')
	assert_true(result is Array)
	assert_eq(result.size(), 3)


func test_parse_json_empty_returns_default():
	assert_null(JestUtils.parse_json(""))


func test_parse_json_empty_with_custom_default():
	assert_eq(JestUtils.parse_json("", 42), 42)


func test_parse_json_invalid_returns_default():
	assert_null(JestUtils.parse_json("not json"))


func test_parse_json_dict_valid():
	var result := JestUtils.parse_json_dict('{"a":1}')
	assert_eq(result["a"], 1)


func test_parse_json_dict_empty():
	var result := JestUtils.parse_json_dict("")
	assert_true(result.is_empty())


func test_parse_json_dict_non_dict_returns_default():
	var result := JestUtils.parse_json_dict("[1,2]")
	assert_true(result.is_empty())


func test_parse_json_dict_custom_default():
	var result := JestUtils.parse_json_dict("", {"fallback": true})
	assert_true(result.has("fallback"))


func test_parse_json_array_valid():
	var result := JestUtils.parse_json_array('[1,2,3]')
	assert_eq(result.size(), 3)


func test_parse_json_array_empty():
	var result := JestUtils.parse_json_array("")
	assert_eq(result.size(), 0)


func test_parse_json_array_non_array_returns_default():
	var result := JestUtils.parse_json_array('{"not":"array"}')
	assert_eq(result.size(), 0)


func test_parse_json_array_custom_default():
	var result := JestUtils.parse_json_array("", [1, 2])
	assert_eq(result.size(), 2)
