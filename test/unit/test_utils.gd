extends GutTest
## Tests for JestUtils JSON parsing helpers


func test_parse_json_valid_dict():
	var result = JestUtils.parse_json('{"key":"value"}')
	assert_true(result is Dictionary)
	assert_eq(result["key"], "value")


func test_parse_json_valid_array():
	var result = JestUtils.parse_json('[1,2,3]')
	assert_true(result is Array)
	assert_eq(result.size(), 3)


func test_parse_json_empty_returns_default():
	assert_null(JestUtils.parse_json(""))


func test_parse_json_empty_with_custom_default():
	assert_eq(JestUtils.parse_json("", 42), 42)


func test_parse_json_invalid_returns_default():
	assert_null(JestUtils.parse_json("not json"))


func test_parse_json_dict_valid():
	var result := JestUtils.parse_json_dict('{"a":1}')
	assert_eq(result["a"], 1)


func test_parse_json_dict_empty():
	var result := JestUtils.parse_json_dict("")
	assert_true(result.is_empty())


func test_parse_json_dict_non_dict_returns_default():
	var result := JestUtils.parse_json_dict("[1,2]")
	assert_true(result.is_empty())


func test_parse_json_dict_custom_default():
	var result := JestUtils.parse_json_dict("", {"fallback": true})
	assert_true(result.has("fallback"))


func test_parse_json_array_valid():
	var result := JestUtils.parse_json_array('[1,2,3]')
	assert_eq(result.size(), 3)


func test_parse_json_array_empty():
	var result := JestUtils.parse_json_array("")
	assert_eq(result.size(), 0)


func test_parse_json_array_non_array_returns_default():
	var result := JestUtils.parse_json_array('{"not":"array"}')
	assert_eq(result.size(), 0)


func test_parse_json_array_custom_default():
	var result := JestUtils.parse_json_array("", [1, 2])
	assert_eq(result.size(), 2)


# Bot avatar tests — vectors verified against the JS @textclub/common/prng
# implementation so all SDKs produce the same avatar for the same username.

func test_get_bot_avatar_default_size():
	assert_eq(JestUtils.get_bot_avatar("test"), "https://cdn.jest.com/avatars/bot/736.webp")


func test_get_bot_avatar_known_vectors():
	assert_eq(JestUtils.get_bot_avatar(""), "https://cdn.jest.com/avatars/bot/115.webp")
	assert_eq(JestUtils.get_bot_avatar("a"), "https://cdn.jest.com/avatars/bot/748.webp")
	assert_eq(JestUtils.get_bot_avatar("alice"), "https://cdn.jest.com/avatars/bot/982.webp")
	assert_eq(JestUtils.get_bot_avatar("Bob"), "https://cdn.jest.com/avatars/bot/160.webp")
	assert_eq(JestUtils.get_bot_avatar("bot"), "https://cdn.jest.com/avatars/bot/991.webp")
	assert_eq(JestUtils.get_bot_avatar("user_42"), "https://cdn.jest.com/avatars/bot/592.webp")
	assert_eq(JestUtils.get_bot_avatar("hello world"), "https://cdn.jest.com/avatars/bot/256.webp")


func test_get_bot_avatar_with_size_wraps_in_cloudflare_proxy():
	assert_eq(
		JestUtils.get_bot_avatar("test", 128),
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=128%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fbot%2F736.webp",
	)


func test_get_bot_avatar_buckets_down_intermediate_sizes():
	# 999 should bucket to 512, 200 to 128, 1 to 64.
	assert_eq(JestUtils.get_bot_avatar("bot", 999), JestUtils.get_bot_avatar("bot", 512))
	assert_eq(JestUtils.get_bot_avatar("bot", 200), JestUtils.get_bot_avatar("bot", 128))
	assert_eq(JestUtils.get_bot_avatar("bot", 1), JestUtils.get_bot_avatar("bot", 64))


func test_get_bot_avatar_supplementary_plane_username():
	# 🎮 (U+1F3AE) — JS encodes as UTF-16 surrogate pair, so the SDK must too.
	assert_eq(JestUtils.get_bot_avatar("🎮"), "https://cdn.jest.com/avatars/bot/740.webp")


func test_get_bot_avatar_is_deterministic():
	assert_eq(JestUtils.get_bot_avatar("alice"), JestUtils.get_bot_avatar("alice"))


# Player avatar tests — the helper wraps raw avatar URLs through the Cloudflare
# image proxy to mirror the HTML5 SDK's social.getProfile behavior.

func test_get_player_avatar_empty_url_returns_empty():
	assert_eq(JestUtils.get_player_avatar(""), "")


func test_get_player_avatar_wraps_in_cloudflare_proxy():
	var raw := "https://cdn.jest.com/avatars/abc.webp"
	assert_eq(
		JestUtils.get_player_avatar(raw, 256),
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=256%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fabc.webp",
	)


func test_get_player_avatar_wraps_at_default_size():
	# Unlike get_bot_avatar, get_player_avatar always wraps — the underlying file
	# is WebP and we want a portable format even at the largest size.
	var raw := "https://cdn.jest.com/avatars/abc.webp"
	assert_eq(
		JestUtils.get_player_avatar(raw),
		"https://cdn.jestpub.com/cdn-cgi/image/format=webp%2Cfit=cover%2Cwidth=1000%2C/https%3A%2F%2Fcdn.jest.com%2Favatars%2Fabc.webp",
	)


func test_get_player_avatar_buckets_down_intermediate_sizes():
	var raw := "https://cdn.jest.com/avatars/abc.webp"
	assert_eq(JestUtils.get_player_avatar(raw, 999), JestUtils.get_player_avatar(raw, 512))
	assert_eq(JestUtils.get_player_avatar(raw, 200), JestUtils.get_player_avatar(raw, 128))
	assert_eq(JestUtils.get_player_avatar(raw, 1), JestUtils.get_player_avatar(raw, 64))


func test_get_player_avatar_passes_through_localhost_urls():
	assert_eq(
		JestUtils.get_player_avatar("http://localhost:3000/avatars/abc.webp", 256),
		"http://localhost:3000/avatars/abc.webp",
	)
	assert_eq(
		JestUtils.get_player_avatar("https://localhost:3000/avatars/abc.webp", 256),
		"https://localhost:3000/avatars/abc.webp",
	)
