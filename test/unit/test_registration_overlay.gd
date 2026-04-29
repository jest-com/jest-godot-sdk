extends GutTest
## Tests for the custom registration overlay API.

var _closed := false
var _closed_count := 0


func before_each():
	_closed = false
	_closed_count = 0


func _mark_closed():
	_closed = true


func _count_closed():
	_closed_count += 1


func test_options_defaults_match_html5_api():
	var opts := JestRegistrationOverlayOptions.new()
	assert_eq(opts.theme, "dark")
	assert_true(opts.entry_payload.is_empty())
	assert_false(opts.on_close.is_valid())


func test_overlay_show_returns_handle():
	var bridge := JestBridge.new()
	var overlay := JestRegistrationOverlay.new(bridge)

	var handle := overlay.show()

	assert_not_null(handle)
	assert_true(handle is JestRegistrationOverlayHandle)


func test_overlay_show_invokes_on_close_option():
	var bridge := JestBridge.new()
	var overlay := JestRegistrationOverlay.new(bridge)
	var opts := JestRegistrationOverlayOptions.new()
	opts.on_close = _mark_closed

	overlay.show(opts)

	assert_true(_closed)


func test_handle_close_marks_closed_once():
	var bridge := JestBridge.new()
	var handle := JestRegistrationOverlayHandle.new(bridge, "conversation-id")
	handle.closed.connect(_count_closed)

	handle._on_closed()
	handle._on_closed()

	assert_true(handle.is_closed)
	assert_eq(_closed_count, 1)
