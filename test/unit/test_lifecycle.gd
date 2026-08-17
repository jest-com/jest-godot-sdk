extends GutTest
## Tests for app lifecycle events.

var _hidden_count := 0
var _shown_count := 0
var _exit_requested_count := 0


func before_each():
	_hidden_count = 0
	_shown_count = 0
	_exit_requested_count = 0


func _count_hidden():
	_hidden_count += 1


func _count_shown():
	_shown_count += 1


func _count_exit_requested():
	_exit_requested_count += 1


func test_hidden_signal_forwards_from_bridge():
	var bridge := JestBridge.new()
	var lifecycle := JestLifecycle.new(bridge)
	lifecycle.hidden.connect(_count_hidden)

	bridge._lifecycle_hidden.emit()

	assert_eq(_hidden_count, 1)


func test_shown_signal_forwards_from_bridge():
	var bridge := JestBridge.new()
	var lifecycle := JestLifecycle.new(bridge)
	lifecycle.shown.connect(_count_shown)

	bridge._lifecycle_shown.emit()

	assert_eq(_shown_count, 1)


func test_exit_requested_signal_forwards_from_bridge():
	var bridge := JestBridge.new()
	var lifecycle := JestLifecycle.new(bridge)
	lifecycle.exit_requested.connect(_count_exit_requested)

	bridge._lifecycle_exit_requested.emit()

	assert_eq(_exit_requested_count, 1)
