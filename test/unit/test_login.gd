extends GutTest
## Tests for login() flow on JestBridge (mock mode)


var bridge: JestBridge


func before_each():
	bridge = JestBridge.new()


func test_login_unregistered_resolves_without_error():
	bridge._mock.is_registered = false
	var result: Dictionary = await bridge.login("")
	assert_false(result["timed_out"])
	assert_eq(result["error"], "")


func test_login_sets_registered_on_mock():
	bridge._mock.is_registered = false
	await bridge.login("")
	assert_true(bridge._mock.is_registered)


func test_login_already_registered_resolves_without_error():
	bridge._mock.is_registered = true
	var result: Dictionary = await bridge.login("")
	assert_false(result["timed_out"])
	assert_eq(result["error"], "")
	assert_true(bridge._mock.is_registered)


func test_login_with_payload_resolves():
	bridge._mock.is_registered = false
	var result: Dictionary = await bridge.login('{"source":"test"}')
	assert_false(result["timed_out"])
	assert_eq(result["error"], "")
	assert_true(bridge._mock.is_registered)
