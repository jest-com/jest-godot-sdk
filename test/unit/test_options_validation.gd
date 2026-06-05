extends GutTest
## Tests for Resource option validation


# --- JestNotificationOptions ---

func test_notification_valid_with_days():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "")


func test_notification_valid_with_date():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	# Use a date 1 day from now
	var tomorrow := Time.get_unix_time_from_system() + 86400
	opts.date = Time.get_datetime_string_from_unix_time(int(tomorrow))
	assert_eq(opts.validate(), "")


func test_notification_missing_body():
	var opts := JestNotificationOptions.new()
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "body is required")


func test_notification_missing_cta():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "cta_text is required")


func test_notification_cta_too_long():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "x".repeat(JestNotificationOptions.CTA_CHAR_LIMIT + 1)
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "cta_text must be 50 characters or fewer")


func test_notification_cta_at_limit_is_valid():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "x".repeat(JestNotificationOptions.CTA_CHAR_LIMIT)
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "")


func test_notification_body_too_long():
	var opts := JestNotificationOptions.new()
	opts.body = "x".repeat(JestNotificationOptions.BODY_CHAR_LIMIT + 1)
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "body must be 2000 characters or fewer")


func test_notification_body_at_limit_is_valid():
	var opts := JestNotificationOptions.new()
	opts.body = "x".repeat(JestNotificationOptions.BODY_CHAR_LIMIT)
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "")


func test_notification_title_too_long():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.title = "x".repeat(JestNotificationOptions.TITLE_CHAR_LIMIT + 1)
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "title must be 200 characters or fewer")


func test_notification_title_at_limit_is_valid():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.title = "x".repeat(JestNotificationOptions.TITLE_CHAR_LIMIT)
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "")


func test_notification_missing_identifier():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "identifier is required")


func test_notification_no_schedule():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	assert_eq(opts.validate(), "Either date or scheduled_in_days must be provided")


func test_notification_both_date_and_days():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	opts.date = "2025-01-01T00:00:00Z"
	assert_eq(opts.validate(), "date and scheduled_in_days are mutually exclusive")


func test_notification_days_out_of_range():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.scheduled_in_days = 10
	assert_eq(opts.validate(), "scheduled_in_days must be between 1 and 7")


func test_notification_date_in_past():
	var opts := JestNotificationOptions.new()
	opts.body = "Hello"
	opts.cta_text = "Play"
	opts.identifier = "test"
	opts.date = "2020-01-01T00:00:00Z"
	assert_eq(opts.validate(), "Notification date must be in the future")


# --- JestReferralOptions ---

func test_referral_valid():
	var opts := JestReferralOptions.new()
	opts.reference = "campaign_1"
	assert_eq(opts.validate(), "")


func test_referral_missing_reference():
	var opts := JestReferralOptions.new()
	assert_eq(opts.validate(), "reference cannot be empty")


func test_referral_with_share_image():
	var opts := JestReferralOptions.new()
	opts.reference = "campaign_1"
	opts.share_image = "data:image/png;base64,iVBORw0KGgo="
	assert_eq(opts.validate(), "")


func test_referral_share_image_defaults_empty():
	var opts := JestReferralOptions.new()
	assert_eq(opts.share_image, "")


# --- JestLoginMessageOptions ---

func test_login_message_valid():
	var opts := JestLoginMessageOptions.new()
	opts.message = "Join the game"
	assert_eq(opts.validate(), "")


func test_login_message_missing():
	var opts := JestLoginMessageOptions.new()
	assert_eq(opts.validate(), "message is required")


# --- JestInteractiveNotificationOptions ---

func _make_interactive_opts() -> JestInteractiveNotificationOptions:
	var opts := JestInteractiveNotificationOptions.new()
	opts.messages = [
		{"key": "q1", "body": "Which do you prefer?", "options": [
			{"key": "a", "label": "Option A"},
			{"key": "b", "label": "Option B"},
		]},
		{"key": "done", "body": "Thanks for playing", "ctaText": "Play"},
	]
	opts.scheduled_in_days = 1
	return opts


func test_interactive_valid_with_days():
	var opts := _make_interactive_opts()
	assert_eq(opts.validate(), "")


func test_interactive_valid_with_date():
	var opts := _make_interactive_opts()
	opts.scheduled_in_days = 0
	var tomorrow := Time.get_unix_time_from_system() + 86400
	opts.date = Time.get_datetime_string_from_unix_time(int(tomorrow))
	assert_eq(opts.validate(), "")


func test_interactive_missing_messages():
	var opts := _make_interactive_opts()
	opts.messages = []
	assert_eq(opts.validate(), "at least one message is required")


func test_interactive_too_many_messages():
	var opts := _make_interactive_opts()
	opts.messages = []
	for i in JestInteractiveNotificationOptions.MAX_MESSAGES + 1:
		opts.messages.append({"key": "m%d" % i, "body": "body", "ctaText": "Play"})
	assert_eq(opts.validate(), "messages must have at most %d entries" % JestInteractiveNotificationOptions.MAX_MESSAGES)


func test_interactive_message_empty_key():
	var opts := _make_interactive_opts()
	opts.messages[0]["key"] = ""
	assert_eq(opts.validate(), "message 0 key: key cannot be empty")


func test_interactive_message_invalid_key_chars():
	var opts := _make_interactive_opts()
	opts.messages[0]["key"] = "invalid key!"
	assert_eq(opts.validate(), "message 0 key: keys may only contain letters, digits, - and _")


func test_interactive_message_empty_body():
	var opts := _make_interactive_opts()
	opts.messages[0]["body"] = ""
	assert_eq(opts.validate(), "message 0 body cannot be empty")


func test_interactive_step_no_options():
	var opts := _make_interactive_opts()
	opts.messages[0]["options"] = []
	assert_eq(opts.validate(), "message 0 needs at least one option")


func test_interactive_step_too_many_options():
	var opts := _make_interactive_opts()
	var many_opts := []
	for i in JestInteractiveNotificationOptions.MAX_OPTIONS_PER_MESSAGE + 1:
		many_opts.append({"key": "o%d" % i, "label": "Label"})
	opts.messages[0]["options"] = many_opts
	assert_eq(opts.validate(), "message 0 options must have at most %d entries" % JestInteractiveNotificationOptions.MAX_OPTIONS_PER_MESSAGE)


func test_interactive_option_empty_label():
	var opts := _make_interactive_opts()
	opts.messages[0]["options"][0]["label"] = ""
	assert_eq(opts.validate(), "message 0 option 0 label cannot be empty")


func test_interactive_terminal_empty_cta():
	var opts := _make_interactive_opts()
	opts.messages[1]["ctaText"] = ""
	assert_eq(opts.validate(), "message 1 ctaText cannot be empty")


func test_interactive_message_missing_type():
	var opts := _make_interactive_opts()
	opts.messages[0] = {"key": "q1", "body": "What now?"}
	assert_eq(opts.validate(), "message 0 must have either options (step) or ctaText (terminal)")


func test_interactive_no_schedule():
	var opts := _make_interactive_opts()
	opts.scheduled_in_days = 0
	assert_eq(opts.validate(), "Either date or scheduled_in_days must be provided")


func test_interactive_both_date_and_days():
	var opts := _make_interactive_opts()
	opts.date = "2025-01-01T00:00:00Z"
	assert_eq(opts.validate(), "date and scheduled_in_days are mutually exclusive")
