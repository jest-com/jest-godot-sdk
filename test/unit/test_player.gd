extends GutTest
## Tests for JestPlayer using mock bridge


var bridge: JestBridge
var player: JestPlayer
var changed_keys: Array[String]
var changed_values: Array[String]


func before_each():
	bridge = JestBridge.new()
	# Bridge auto-creates mock when not web
	changed_keys = []
	changed_values = []
	player = JestPlayer.new(bridge, func(k: String, v: String):
		changed_keys.append(k)
		changed_values.append(v)
	)


# --- Basic get/set ---

func test_set_and_get_value():
	player.set_value("name", "Alice")
	assert_eq(player.get_value("name"), "Alice")


func test_get_missing_returns_empty():
	assert_eq(player.get_value("missing"), "")


func test_set_int():
	player.set_int("level", 42)
	assert_eq(player.get_int("level"), 42)


func test_get_int_missing_returns_zero():
	assert_eq(player.get_int("missing"), 0)


func test_set_float():
	player.set_float("score", 3.14)
	assert_almost_eq(player.get_float("score"), 3.14, 0.001)


func test_set_bool_true():
	player.set_bool("vip", true)
	assert_true(player.get_bool("vip"))


func test_set_bool_false():
	player.set_bool("vip", false)
	assert_false(player.get_bool("vip"))


func test_get_bool_missing_returns_false():
	assert_false(player.get_bool("missing"))


func test_set_json():
	player.set_json("config", {"a": 1, "b": "two"})
	var val = player.get_json("config")
	assert_true(val is Dictionary)
	assert_eq(val["a"], 1)
	assert_eq(val["b"], "two")


func test_get_json_missing_returns_null():
	assert_null(player.get_json("missing"))


# --- has_value / get_value_or_default ---

func test_has_value_true():
	player.set_value("key", "val")
	assert_true(player.has_value("key"))


func test_has_value_false():
	assert_false(player.has_value("missing"))


func test_get_value_or_default():
	assert_eq(player.get_value_or_default("missing", "fallback"), "fallback")


func test_get_value_or_default_returns_actual():
	player.set_value("key", "actual")
	assert_eq(player.get_value_or_default("key", "fallback"), "actual")


# --- delete ---

func test_delete_value():
	player.set_value("key", "val")
	player.delete_value("key")
	assert_false(player.has_value("key"))


# --- set_bulk ---

func test_set_bulk():
	player.set_bulk({"a": "1", "b": "2", "c": "3"})
	assert_eq(player.get_value("a"), "1")
	assert_eq(player.get_value("b"), "2")
	assert_eq(player.get_value("c"), "3")


func test_set_bulk_empty_is_noop():
	player.set_bulk({})
	assert_eq(changed_keys.size(), 0)


# --- get_all ---

func test_get_all():
	player.set_value("x", "1")
	player.set_value("y", "2")
	var all := player.get_all()
	assert_true(all is Dictionary)
	assert_eq(all.get("x", ""), "1")
	assert_eq(all.get("y", ""), "2")


# --- Data change callbacks ---

func test_set_value_emits_change():
	player.set_value("key", "val")
	assert_eq(changed_keys.size(), 1)
	assert_eq(changed_keys[0], "key")
	assert_eq(changed_values[0], "val")


func test_delete_emits_change():
	player.set_value("key", "val")
	changed_keys.clear()
	player.delete_value("key")
	assert_eq(changed_keys.size(), 1)
	assert_eq(changed_keys[0], "key")
	assert_eq(changed_values[0], "")


func test_set_bulk_emits_changes():
	player.set_bulk({"a": "1", "b": "2"})
	assert_eq(changed_keys.size(), 2)


# --- Empty key validation ---

func test_get_value_empty_key():
	assert_eq(player.get_value(""), "")


func test_set_value_empty_key():
	player.set_value("", "val")
	# Should not have emitted a change
	assert_eq(changed_keys.size(), 0)


func test_has_value_empty_key():
	assert_false(player.has_value(""))


func test_delete_empty_key():
	player.delete_value("")
	assert_eq(changed_keys.size(), 0)


# --- Cache ---

func test_id_is_cached():
	var id1 := player.id
	var id2 := player.id
	assert_eq(id1, id2)
	assert_eq(id1, "mock-player-id")


func test_is_registered_cached():
	assert_true(player.is_registered)


func test_cache_invalidation():
	# Access to populate cache
	var _id := player.id
	assert_true(player._cache_valid)
	player.invalidate_cache()
	assert_false(player._cache_valid)
