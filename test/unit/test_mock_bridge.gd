extends GutTest
## Tests for JestBridgeMock behavior


var mock: JestBridgeMock


func before_each():
	mock = JestBridgeMock.new()


# --- Player values ---

func test_get_missing_value_returns_empty():
	assert_eq(mock.get_player_value("nonexistent"), "")


func test_set_and_get_value():
	mock.set_player_value("level", "5")
	assert_eq(mock.get_player_value("level"), "5")


func test_delete_value():
	mock.set_player_value("level", "5")
	mock.delete_player_value("level")
	assert_eq(mock.get_player_value("level"), "")


func test_set_overwrites_value():
	mock.set_player_value("score", "100")
	mock.set_player_value("score", "200")
	assert_eq(mock.get_player_value("score"), "200")


# --- Player state ---

func test_default_player_id():
	assert_eq(mock.player_id, "mock-player-id")


func test_default_is_registered():
	assert_true(mock.is_registered)


func test_player_data_json():
	var data := JSON.parse_string(mock.player_data)
	assert_eq(data["playerId"], "mock-player-id")
	assert_true(data["registered"])


func test_player_data_updates_after_login():
	mock.is_registered = false
	var data := JSON.parse_string(mock.player_data)
	assert_false(data["registered"])
	mock.login("")
	data = JSON.parse_string(mock.player_data)
	assert_true(data["registered"])


# --- Entry payload ---

func test_default_entry_payload():
	assert_eq(mock.get_entry_payload(), "{}")


func test_custom_entry_payload():
	mock._entry_payload = '{"source":"test"}'
	assert_eq(mock.get_entry_payload(), '{"source":"test"}')


# --- Products ---

func test_default_products():
	var products := JSON.parse_string(mock.get_products())
	assert_true(products is Array)
	assert_gt(products.size(), 0)
	assert_eq(products[0]["sku"], "gems_100")


func test_custom_products():
	mock.mock_products_json = '[{"sku":"custom","name":"Custom","description":"","price":1.0}]'
	var products := JSON.parse_string(mock.get_products())
	assert_eq(products.size(), 1)
	assert_eq(products[0]["sku"], "custom")


# --- Purchase responses ---

func test_purchase_success():
	mock.mock_purchase_succeeds = true
	var r := JSON.parse_string(mock.get_purchase_response())
	assert_eq(r["result"], "success")
	assert_true(r.has("purchase"))


func test_purchase_cancel():
	mock.mock_purchase_succeeds = false
	var r := JSON.parse_string(mock.get_purchase_response())
	assert_eq(r["result"], "cancel")


func test_complete_purchase():
	var r := JSON.parse_string(mock.get_purchase_complete_response())
	assert_eq(r["result"], "success")


func test_incomplete_purchases():
	var r := JSON.parse_string(mock.get_incomplete_purchase_response())
	assert_false(r["hasMore"])
	assert_true(r["purchases"] is Array)


# --- Signed player ---

func test_signed_player_response():
	var r := JSON.parse_string(mock.get_player_signed_response())
	assert_eq(r["player"]["playerId"], "mock-player-id")
	assert_true(r["player"]["registered"])
	assert_eq(r["playerSigned"], "mock_signed_data")


func test_signed_player_unregistered():
	mock.is_registered = false
	var r := JSON.parse_string(mock.get_player_signed_response())
	assert_false(r["player"]["registered"])


# --- Verbose mode ---

func test_verbose_defaults_off():
	assert_false(mock.verbose)


# --- Notifications ---

func test_schedule_notification():
	mock.schedule_notification_v2('{"body":"test","identifier":"id1"}')
	assert_eq(mock._notifications.size(), 1)
	assert_eq(mock._notifications[0]["identifier"], "id1")
