extends GutTest
## Tests for JestNavigation using mock bridge


var bridge: JestBridge
var nav: JestNavigation


func before_each():
	bridge = JestBridge.new()
	nav = JestNavigation.new(bridge)


func test_redirect_to_game():
	# Should not error
	nav.redirect_to_game("test-game")


func test_redirect_to_game_with_payload():
	nav.redirect_to_game("test-game", {"from": "menu"})


func test_redirect_to_game_skip_confirm():
	nav.redirect_to_game("test-game", {}, true)


func test_redirect_to_game_empty_slug():
	# Should push_error and return without crashing
	nav.redirect_to_game("")


func test_redirect_to_flagship():
	nav.redirect_to_flagship_game()


func test_redirect_to_flagship_with_payload():
	nav.redirect_to_flagship_game({"from": "onboarding"})


func test_redirect_to_explore():
	nav.redirect_to_explore_page()
