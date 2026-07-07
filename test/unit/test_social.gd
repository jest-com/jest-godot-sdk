extends GutTest
## Tests for JestSocial using mock bridge


var bridge: JestBridge
var player: JestPlayer
var social: JestSocial


func before_each():
	bridge = JestBridge.new()
	player = JestPlayer.new(bridge)
	social = JestSocial.new(player, bridge)


func test_get_profile_returns_username_and_sized_avatar():
	bridge._mock.username = "Ada"
	bridge._mock.avatar_url = "https://cdn.jest.com/avatars/abc.webp"
	var profile := social.get_profile(128)
	assert_eq(profile["username"], "Ada")
	assert_eq(
		profile["avatar_url"],
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=128%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fabc.webp",
	)


func test_get_profile_returns_empty_strings_when_profile_fields_missing():
	var profile := social.get_profile()
	assert_eq(profile["username"], "")
	assert_eq(profile["avatar_url"], "")


func test_get_bot_avatar_delegates_to_avatar_helper():
	assert_eq(
		social.get_bot_avatar("test", 128),
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=128%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fbot%2F736.webp",
	)


func test_get_player_avatar_returns_empty_when_no_avatar():
	assert_eq(social.get_player_avatar(), "")


func test_get_player_avatar_wraps_raw_avatar_url():
	bridge._mock.avatar_url = "https://cdn.jest.com/avatars/abc.webp"
	assert_eq(
		social.get_player_avatar(256),
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=256%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fabc.webp",
	)


func test_set_screenshot_provider_delegates_to_bridge():
	var provider := func(): return "abc123"
	social.set_screenshot_provider(provider)
	assert_true(bridge._mock.screenshot_provider.is_valid())
	assert_eq(bridge._mock.screenshot_provider.call(), "abc123")


func test_set_screenshot_provider_can_unregister():
	social.set_screenshot_provider(func(): return "abc123")
	social.set_screenshot_provider(Callable())
	assert_false(bridge._mock.screenshot_provider.is_valid())
