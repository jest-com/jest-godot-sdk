extends GutTest
## Tests for JestBridge.login() async resolution in mock mode.
## In mock mode the login promise resolves immediately so awaiting it never hangs.


func test_login_resolves_in_mock_mode():
	var bridge := JestBridge.new()
	var result = await bridge.login("")
	assert_true(result is Dictionary)
	assert_false(result["timed_out"])
	assert_eq(result["error"], "")


func test_login_with_payload_resolves_in_mock_mode():
	var bridge := JestBridge.new()
	var result = await bridge.login('{"source":"test"}')
	assert_false(result["timed_out"])
	assert_eq(result["error"], "")


func test_login_marks_player_registered_in_mock():
	var bridge := JestBridge.new()
	bridge._mock.is_registered = false
	await bridge.login("")
	assert_true(bridge._mock.is_registered)
