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
	opts.cta_text = "This CTA text is way too long for the limit"
	opts.identifier = "test"
	opts.scheduled_in_days = 1
	assert_eq(opts.validate(), "cta_text must be 25 characters or fewer")


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


# --- JestLoginMessageOptions ---

func test_login_message_valid():
	var opts := JestLoginMessageOptions.new()
	opts.message = "Join the game"
	assert_eq(opts.validate(), "")


func test_login_message_missing():
	var opts := JestLoginMessageOptions.new()
	assert_eq(opts.validate(), "message is required")
