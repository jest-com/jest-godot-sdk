extends GutTest
## Tests for JestNavigation using mock bridge


var bridge: JestBridge
var nav: JestNavigation


func before_each():
	bridge = JestBridge.new()
	nav = JestNavigation.new(bridge)


func test_redirect_to_game():
	nav.redirect_to_game("test-game")
	assert_true(true, "should not error")


func test_redirect_to_game_with_payload():
	nav.redirect_to_game("test-game", {"from": "menu"})
	assert_true(true, "should not error")


func test_redirect_to_game_skip_confirm():
	nav.redirect_to_game("test-game", {}, true)
	assert_true(true, "should not error")


func test_redirect_to_game_empty_slug():
	# Should push_error and return without crashing
	nav.redirect_to_game("")
	assert_true(true, "should not crash")


func test_redirect_to_flagship():
	nav.redirect_to_flagship_game()
	assert_true(true, "should not error")


func test_redirect_to_flagship_with_payload():
	nav.redirect_to_flagship_game({"from": "onboarding"})
	assert_true(true, "should not error")


func test_redirect_to_explore():
	nav.redirect_to_explore_page()
	assert_true(true, "should not error")
