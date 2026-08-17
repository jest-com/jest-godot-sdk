extends Control

const PROTOCOL_VERSION := 1
const COMMAND_SOURCE := "textclub-sdk-regression"
const SAMPLE_SOURCE := "jest-sdk-sample-regression"
const ENGINE := "godot"

const SCENARIOS: Array[String] = [
	"core",
	"player-data",
	"commerce-read",
	"commerce-errors",
	"notifications",
	"social",
	"referrals-read",
	"referrals-share",
	"internal",
	"legal",
	"guardrails",
]

var _json: JavaScriptObject
var _window: JavaScriptObject
var _message_callback: JavaScriptObject


func _ready() -> void:
	_build_minimal_ui()
	_install_command_listener()
	call_deferred("_boot")


func _build_minimal_ui() -> void:
	var label := Label.new()
	label.text = "Jest Godot SDK regression fixture"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)


func _install_command_listener() -> void:
	if not OS.has_feature("web"):
		return
	_json = JavaScriptBridge.get_interface("JSON")
	_window = JavaScriptBridge.get_interface("window")
	if _window == null or _json == null:
		return
	_message_callback = JavaScriptBridge.create_callback(_on_window_message)
	_window.addEventListener("message", _message_callback)


func _boot() -> void:
	var success := await JestSDK.init_sdk({"auto_login_reminders": false})
	if not success:
		_post_log("error", "JestSDK.init_sdk failed")
		return
	_post_message({
		"source": SAMPLE_SOURCE,
		"protocolVersion": PROTOCOL_VERSION,
		"type": "runnerReady",
		"engine": ENGINE,
		"scenarios": SCENARIOS,
		"sdkVersion": _read_sdk_version(),
	})


func _read_sdk_version() -> String:
	var cfg := ConfigFile.new()
	if cfg.load("res://addons/jest_sdk/plugin.cfg") == OK:
		return "godot-sdk-%s" % str(cfg.get_value("plugin", "version", "unknown"))
	return "godot-sdk-unknown"


func _on_window_message(args: Array) -> void:
	if args.is_empty() or _json == null:
		return
	var event = args[0]
	if event == null:
		return
	var raw = _json.stringify(event.data)
	if not (raw is String):
		return
	var message = JSON.parse_string(raw)
	if not (message is Dictionary):
		return
	if message.get("source") != COMMAND_SOURCE:
		return
	if int(message.get("protocolVersion", 0)) != PROTOCOL_VERSION:
		return
	if message.get("type") != "runScenario":
		return
	if message.get("engine") != ENGINE:
		return
	call_deferred("_run_command", message)


func _run_command(command: Dictionary) -> void:
	var scenario := str(command.get("scenario", ""))
	var run_id := str(command.get("runId", ""))
	var assertions: Array[Dictionary] = []
	var error: Dictionary = {}
	_post_log("info", "Running scenario %s" % scenario, scenario, run_id)

	match scenario:
		"core":
			assertions = await _run_core(command)
		"player-data":
			assertions = await _run_player_data(command)
		"commerce-read":
			assertions = await _run_commerce_read()
		"commerce-errors":
			assertions = await _run_commerce_errors()
		"notifications":
			assertions = await _run_notifications(run_id)
		"social":
			assertions = await _run_social()
		"referrals-read":
			assertions = await _run_referrals_read()
		"referrals-share":
			assertions = await _run_referrals_share(command)
		"internal":
			assertions = await _run_internal(command)
		"legal":
			assertions = await _run_legal()
		"guardrails":
			assertions = await _run_guardrails()
		_:
			assertions.append(_assert_true("known scenario", false, "Unknown scenario: %s" % scenario))

	var status := "pass"
	for assertion in assertions:
		if not bool(assertion.get("pass", false)):
			status = "fail"
			break

	var message := {
		"source": SAMPLE_SOURCE,
		"protocolVersion": PROTOCOL_VERSION,
		"type": "scenarioResult",
		"engine": ENGINE,
		"scenario": scenario,
		"runId": run_id,
		"status": status,
		"assertions": assertions,
	}
	if not error.is_empty():
		message["error"] = error
	_post_message(message)


func _run_core(command: Dictionary) -> Array[Dictionary]:
	var options: Dictionary = command.get("options", {})
	var expected_payload: Dictionary = options.get("entryPayloadExpected", {})
	var event_name := str(options.get("captureEventName", "sdk_regression_godot_core"))
	var entry_payload := JestSDK.get_entry_payload()
	var assertions: Array[Dictionary] = [
		_assert_true("SDK initialized", JestSDK.is_initialized),
		_assert_true("running in web export", JestSDK.is_web),
		_assert_true("player id present", not JestSDK.player.id.is_empty()),
		_assert_eq("player registered", JestSDK.player.is_registered, true),
		_assert_eq("entry payload sdkRegression", entry_payload.get("sdkRegression"), expected_payload.get("sdkRegression")),
		_assert_eq("entry payload suite", entry_payload.get("suite"), expected_payload.get("suite")),
		_assert_true("player username is string", JestSDK.player.username is String),
		_assert_true("player avatar_url is string", JestSDK.player.avatar_url is String),
	]
	JestSDK.set_loading_progress(5)
	JestSDK.set_loading_progress(100)
	JestSDK.capture_event(event_name, {"engine": ENGINE, "scenario": "core"})
	assertions.append(_assert_true("capture_event completed", true))
	await get_tree().process_frame
	return assertions


func _run_player_data(command: Dictionary) -> Array[Dictionary]:
	var options: Dictionary = command.get("options", {})
	var key := str(options.get("playerDataKey", "sdk-regression:godot"))
	var changed: Array[String] = []
	var on_changed := func(changed_key: String, _value: String) -> void:
		changed.append(changed_key)
	JestSDK.player_data_changed.connect(on_changed)

	JestSDK.player.set_value(key, "godot-value")
	JestSDK.player.set_int(key + ":int", 42)
	JestSDK.player.set_float(key + ":float", 3.5)
	JestSDK.player.set_bool(key + ":bool", true)
	JestSDK.player.set_json(key + ":json", {"engine": ENGINE, "ok": true})
	JestSDK.player.set_bulk({
		key + ":bulk-a": "A",
		key + ":bulk-b": "B",
	})

	var string_value := JestSDK.player.get_value(key)
	var int_value := JestSDK.player.get_int(key + ":int")
	var float_value := JestSDK.player.get_float(key + ":float")
	var bool_value := JestSDK.player.get_bool(key + ":bool")
	var json_value: Variant = JestSDK.player.get_json(key + ":json")
	var has_before_delete := JestSDK.player.has_value(key)
	var default_value := JestSDK.player.get_value_or_default(key + ":missing", "fallback")
	var all_data := JestSDK.player.get_all()
	var raw_player_data := JestSDK.player.get_player_data()
	var signed := await JestSDK.player.get_signed()
	JestSDK.player.delete_value(key)
	var flush_result := await JestSDK.player.flush()
	if JestSDK.player_data_changed.is_connected(on_changed):
		JestSDK.player_data_changed.disconnect(on_changed)

	return [
		_assert_eq("get_value returns string", string_value, "godot-value"),
		_assert_eq("get_int returns int", int_value, 42),
		_assert_true("get_float returns float", absf(float_value - 3.5) < 0.001),
		_assert_eq("get_bool returns bool", bool_value, true),
		_assert_eq("get_json returns object field", json_value.get("engine"), ENGINE),
		_assert_eq("has_value true before delete", has_before_delete, true),
		_assert_eq("get_value_or_default fallback", default_value, "fallback"),
		_assert_eq("get_all bulk value", all_data.get(key + ":bulk-a"), "A"),
		_assert_true("get_player_data returns JSON", raw_player_data.begins_with("{")),
		_assert_true("get_signed ok", signed.ok),
		_assert_true("get_signed player id present", not signed.player_id.is_empty()),
		_assert_true("get_signed token present", not signed.player_signed.is_empty()),
		_assert_eq("has_value false after delete", JestSDK.player.has_value(key), false),
		_assert_true("flush ok", flush_result.ok),
		_assert_true("player_data_changed emitted", changed.has(key)),
	]


func _run_commerce_read() -> Array[Dictionary]:
	var products := await JestSDK.payment.get_products()
	var incomplete := await JestSDK.payment.get_incomplete_purchases()
	var subscriptions := await JestSDK.payment.get_subscriptions()
	return [
		_assert_true("products returns array", products is Array),
		_assert_true("incomplete purchases ok", incomplete.ok),
		_assert_true("incomplete purchases list", incomplete.purchases is Array),
		_assert_true("subscriptions ok", subscriptions.ok),
		_assert_true("subscriptions list", subscriptions.subscriptions is Array),
	]


func _run_commerce_errors() -> Array[Dictionary]:
	var purchase := await JestSDK.payment.begin_purchase("")
	var complete := await JestSDK.payment.complete_purchase("")
	var subscription := await JestSDK.payment.begin_subscription("")
	var cancel := await JestSDK.payment.cancel_subscription("")
	var claim_retention := await JestSDK.payment.claim_retention_offer("")
	return [
		_assert_eq("begin_purchase empty sku rejected", purchase.error, "invalid_sku"),
		_assert_eq("complete_purchase empty token rejected", complete.error, "invalid_token"),
		_assert_eq("begin_subscription empty sku rejected", subscription.error, "invalid_sku"),
		_assert_eq("cancel_subscription empty sku rejected", cancel.error, "invalid_sku"),
		_assert_eq("claim_retention_offer empty sku rejected", claim_retention.error, "invalid_sku"),
	]


func _run_notifications(run_id: String) -> Array[Dictionary]:
	var identifier := "godot-regression-%s" % run_id
	var options := JestNotificationOptions.new()
	options.body = "Godot regression notification"
	options.title = "Regression"
	options.cta_text = "Play"
	options.identifier = identifier
	options.priority = "medium"
	options.asset_reference = "regression-asset"
	options.entry_payload = {"engine": ENGINE, "runId": run_id}
	options.scheduled_in_days = 1
	JestSDK.notifications.schedule(options)
	JestSDK.notifications.unschedule(identifier)

	var invalid := JestNotificationOptions.new()
	return [
		_assert_eq("valid notification options", options.validate(), ""),
		_assert_eq("invalid notification options rejected", invalid.validate(), "body is required"),
	]


func _run_social() -> Array[Dictionary]:
	var bot_avatar := JestSDK.get_bot_avatar("sdk-regression-godot", 128)
	var profile := JestSDK.get_profile(128)
	var legacy_avatar := JestSDK.get_player_avatar(128)
	return [
		_assert_true("bot avatar URL present", bot_avatar.begins_with("https://")),
		_assert_true("profile username is string", profile.username is String),
		_assert_true("profile avatar is string", profile.avatar_url is String),
		_assert_true("legacy player avatar is string", legacy_avatar is String),
	]


func _run_referrals_read() -> Array[Dictionary]:
	var result := await JestSDK.referrals.list_referrals()
	return [
		_assert_true("list_referrals ok", result.ok),
		_assert_true("referrals array", result.referrals is Array),
		_assert_true("referrals signed is string", result.referrals_signed is String),
	]


func _run_referrals_share(command: Dictionary) -> Array[Dictionary]:
	var options: Dictionary = command.get("options", {})
	var run_id := str(command.get("runId", "godot-referral"))
	var referral := JestReferralOptions.new()
	referral.reference = "godot-regression-%s" % run_id
	referral.entry_payload = options.get("entryPayloadExpected", {})
	referral.share_title = "Godot regression"
	referral.share_text = "Join this Godot regression run"
	referral.notification_templates = [
		{
			"minConversionCount": 1,
			"variants": [
				{"body": "A friend joined", "ctaText": "Play", "title": "Referral"}
			],
		}
	]
	var result := await JestSDK.referrals.open_referral_dialog(referral)
	return [
		_assert_true("referral options valid", referral.validate().is_empty()),
		_assert_true("share result ok", result.ok),
		_assert_true("share canceled flag is bool", result.canceled is bool),
	]


func _run_internal(command: Dictionary) -> Array[Dictionary]:
	var options: Dictionary = command.get("options", {})
	var event_name := str(options.get("captureEventName", "sdk_regression_godot_internal"))
	var flag := await JestSDK.get_feature_flag("sdk-regression-flag")
	var name_result := await JestSDK.validate_name("sdk_regression_godot")
	JestSDK.internal_api.capture_onboarding_event("game_load_complete", {
		"engine": ENGINE,
		"eventName": event_name,
	})
	return [
		_assert_true("feature flag result returned", flag is JestFeatureFlagResult),
		_assert_true("name validation ok", name_result.ok),
		_assert_true("name validation status present", not name_result.status.is_empty()),
	]


func _run_legal() -> Array[Dictionary]:
	JestSDK.open_privacy_policy()
	JestSDK.open_terms_of_service()
	JestSDK.open_copyright()
	await get_tree().process_frame
	return [_assert_true("legal openers completed", true)]


func _run_guardrails() -> Array[Dictionary]:
	var bad_flag := await JestSDK.get_feature_flag("")
	var bad_name := await JestSDK.validate_name("")
	var bad_purchase := await JestSDK.payment.begin_purchase("")
	var bad_complete := await JestSDK.payment.complete_purchase("")
	var bad_subscription := await JestSDK.payment.begin_subscription("")
	var bad_cancel := await JestSDK.payment.cancel_subscription("")
	var bad_claim_retention := await JestSDK.payment.claim_retention_offer("")
	var bad_referral := JestReferralOptions.new()
	var bad_share := await JestSDK.referrals.open_referral_dialog(bad_referral)
	var bad_notification := JestNotificationOptions.new()
	JestSDK.player.set_value("", "nope")
	JestSDK.player.delete_value("")
	JestSDK.player.has_value("")
	JestSDK.login({"from": "guardrails"})
	JestSDK.navigation.redirect_to_game("")
	JestSDK.notifications.schedule(bad_notification)
	JestSDK.notifications.unschedule("")
	JestSDK.capture_event("", {})
	JestSDK.internal_api.capture_onboarding_event("not_a_real_event", {})
	JestSDK.internal_api.send_reserved_login_message({})
	await get_tree().process_frame
	return [
		_assert_eq("empty feature flag key rejected", bad_flag.error, "key cannot be empty"),
		_assert_eq("empty validate_name rejected", bad_name.error, "name cannot be empty"),
		_assert_eq("empty purchase sku rejected", bad_purchase.error, "invalid_sku"),
		_assert_eq("empty purchase token rejected", bad_complete.error, "invalid_token"),
		_assert_eq("empty subscription sku rejected", bad_subscription.error, "invalid_sku"),
		_assert_eq("empty cancel subscription sku rejected", bad_cancel.error, "invalid_sku"),
		_assert_eq("empty claim retention offer sku rejected", bad_claim_retention.error, "invalid_sku"),
		_assert_eq("empty referral rejected", bad_share.error, "reference cannot be empty"),
		_assert_eq("empty notification rejected", bad_notification.validate(), "body is required"),
	]


func _assert_true(name: String, condition: bool, details: String = "") -> Dictionary:
	var assertion := {"name": name, "pass": condition}
	if not details.is_empty():
		assertion["details"] = details
	return assertion


func _assert_eq(name: String, actual: Variant, expected: Variant) -> Dictionary:
	return {
		"name": name,
		"pass": actual == expected,
		"actual": actual,
		"expected": expected,
	}


func _post_log(level: String, message: String, scenario: String = "", run_id: String = "") -> void:
	var payload := {
		"source": SAMPLE_SOURCE,
		"protocolVersion": PROTOCOL_VERSION,
		"type": "scenarioLog",
		"engine": ENGINE,
		"level": level,
		"message": message,
	}
	if not scenario.is_empty():
		payload["scenario"] = scenario
	if not run_id.is_empty():
		payload["runId"] = run_id
	_post_message(payload)


func _post_message(payload: Dictionary) -> void:
	if not OS.has_feature("web"):
		print("[JestSDK Regression] %s" % JSON.stringify(payload))
		return
	if _window == null:
		_window = JavaScriptBridge.get_interface("window")
	if _json == null:
		_json = JavaScriptBridge.get_interface("JSON")
	if _window == null or _json == null:
		push_error("[JestSDK Regression] JavaScript bridge unavailable")
		return
	var js_payload = _json.parse(JSON.stringify(payload))
	if js_payload == null:
		push_error("[JestSDK Regression] Failed to encode message payload")
		return
	_window.parent.postMessage(js_payload, "*")
