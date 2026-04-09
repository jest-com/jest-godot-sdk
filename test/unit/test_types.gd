extends GutTest
## Tests for all type system classes in types/


# --- JestResult ---

func test_result_success():
	var r := JestResult.success()
	assert_true(r.ok)
	assert_eq(r.error, "")


func test_result_failure():
	var r := JestResult.failure("something broke")
	assert_false(r.ok)
	assert_eq(r.error, "something broke")


func test_result_default_is_failure():
	var r := JestResult.new()
	assert_false(r.ok)


# --- JestProduct ---

func test_product_from_dict():
	var d := {"sku": "gems_100", "name": "100 Gems", "description": "A pack", "price": 99.0}
	var p := JestProduct.from_dict(d)
	assert_eq(p.sku, "gems_100")
	assert_eq(p.name, "100 Gems")
	assert_eq(p.description, "A pack")
	assert_eq(p.price, 99.0)


func test_product_from_dict_with_missing_fields():
	var p := JestProduct.from_dict({})
	assert_eq(p.sku, "")
	assert_eq(p.name, "")
	assert_eq(p.price, 0.0)


func test_product_from_array():
	var arr: Array = [
		{"sku": "a", "name": "A", "description": "", "price": 1.0},
		{"sku": "b", "name": "B", "description": "", "price": 2.0},
	]
	var products := JestProduct.from_array(arr)
	assert_eq(products.size(), 2)
	assert_eq(products[0].sku, "a")
	assert_eq(products[1].sku, "b")


func test_product_from_array_skips_non_dicts():
	var arr: Array = [{"sku": "a"}, "not a dict", 42]
	var products := JestProduct.from_array(arr)
	assert_eq(products.size(), 1)


# --- JestPurchase ---

func test_purchase_from_dict():
	var d := {
		"purchaseToken": "tok_123",
		"productSku": "gems_100",
		"credits": 99.0,
		"createdAt": 1700000000,
		"completedAt": 1700000100,
		"estimatedRevenue": 69.30
	}
	var p := JestPurchase.from_dict(d)
	assert_eq(p.purchase_token, "tok_123")
	assert_eq(p.product_sku, "gems_100")
	assert_eq(p.credits, 99.0)
	assert_eq(p.created_at, 1700000000)
	assert_eq(p.completed_at, 1700000100)
	assert_eq(p.estimated_revenue, 69.30)


func test_purchase_decimal_credits():
	var p := JestPurchase.from_dict({"credits": 1.50, "estimatedRevenue": 0.75})
	assert_eq(p.credits, 1.50)
	assert_eq(p.estimated_revenue, 0.75)


func test_purchase_null_completed_at():
	var p := JestPurchase.from_dict({"completedAt": null})
	assert_eq(p.completed_at, 0)


# --- JestPurchaseResult ---

func test_purchase_result_success():
	var d := {
		"result": "success",
		"purchase": {"purchaseToken": "tok", "productSku": "gems"},
		"purchaseSigned": "jwt_here"
	}
	var r := JestPurchaseResult.from_dict(d)
	assert_true(r.ok)
	assert_eq(r.status, JestPurchaseResult.Status.SUCCESS)
	assert_eq(r.purchase.purchase_token, "tok")
	assert_eq(r.purchase_signed, "jwt_here")


func test_purchase_result_cancel():
	var r := JestPurchaseResult.from_dict({"result": "cancel"})
	assert_false(r.ok)
	assert_eq(r.status, JestPurchaseResult.Status.CANCELED)
	assert_eq(r.error, "purchase_canceled")


func test_purchase_result_error():
	var r := JestPurchaseResult.from_dict({"result": "error", "error": "insufficient_credits"})
	assert_false(r.ok)
	assert_eq(r.status, JestPurchaseResult.Status.ERROR)
	assert_eq(r.error, "insufficient_credits")


func test_purchase_result_make_error():
	var r := JestPurchaseResult.make_error("timeout")
	assert_false(r.ok)
	assert_eq(r.error, "timeout")


# --- JestSignedPlayer ---

func test_signed_player_from_dict():
	var d := {
		"player": {"playerId": "p123", "registered": true},
		"playerSigned": "jwt"
	}
	var r := JestSignedPlayer.from_dict(d)
	assert_true(r.ok)
	assert_eq(r.player_id, "p123")
	assert_true(r.registered)
	assert_eq(r.player_signed, "jwt")


func test_signed_player_error():
	var r := JestSignedPlayer.make_error("timeout")
	assert_false(r.ok)
	assert_eq(r.error, "timeout")


# --- JestFeatureFlagResult ---

func test_feature_flag_string():
	var r := JestFeatureFlagResult.make_success("hello")
	assert_true(r.ok)
	assert_eq(r.as_string, "hello")


func test_feature_flag_bool_true():
	var r := JestFeatureFlagResult.make_success(true)
	assert_true(r.as_bool)


func test_feature_flag_bool_from_string():
	var r := JestFeatureFlagResult.make_success("TRUE")
	assert_true(r.as_bool)


func test_feature_flag_int():
	var r := JestFeatureFlagResult.make_success(42)
	assert_eq(r.as_int, 42)


func test_feature_flag_float():
	var r := JestFeatureFlagResult.make_success(3.14)
	assert_almost_eq(r.as_float, 3.14, 0.001)


func test_feature_flag_null():
	var r := JestFeatureFlagResult.make_success(null)
	assert_eq(r.as_string, "")
	assert_false(r.as_bool)
	assert_eq(r.as_int, 0)


func test_feature_flag_error():
	var r := JestFeatureFlagResult.make_error("not_found")
	assert_false(r.ok)
	assert_eq(r.error, "not_found")


# --- JestNameValidationResult ---

func test_name_validation_valid():
	var r := JestNameValidationResult.from_dict({"status": "valid"})
	assert_true(r.ok)
	assert_true(r.is_valid)


func test_name_validation_invalid():
	var r := JestNameValidationResult.from_dict({"status": "invalid", "validationError": "too short"})
	assert_true(r.ok)
	assert_false(r.is_valid)
	assert_eq(r.validation_error, "too short")


# --- JestShareResult ---

func test_share_result_shared():
	var r := JestShareResult.make_success(false)
	assert_true(r.ok)
	assert_false(r.canceled)


func test_share_result_canceled():
	var r := JestShareResult.make_success(true)
	assert_true(r.ok)
	assert_true(r.canceled)


# --- JestReferralResult ---

func test_referral_result_from_dict():
	var d := {
		"referrals": [{"reference": "abc", "registrations": 5}],
		"referralsSigned": "jwt"
	}
	var r := JestReferralResult.from_dict(d)
	assert_true(r.ok)
	assert_eq(r.referrals.size(), 1)
	assert_eq(r.referrals[0]["reference"], "abc")
	assert_eq(r.referrals_signed, "jwt")


# --- JestIncompletePurchasesResult ---

func test_incomplete_purchases_empty():
	var r := JestIncompletePurchasesResult.from_dict({"hasMore": false, "purchases": [], "purchasesSigned": ""})
	assert_true(r.ok)
	assert_false(r.has_more)
	assert_eq(r.purchases.size(), 0)


# --- JestLoginReservation ---

func test_login_reservation_success():
	var d := {"reservation": {"id": "r1", "message": "hello"}}
	var r := JestLoginReservation.from_dict(d)
	assert_true(r.ok)
	assert_eq(r.reservation["id"], "r1")


func test_login_reservation_error():
	var r := JestLoginReservation.from_dict({"error": "could_not_acquire_lease"})
	assert_false(r.ok)
	assert_eq(r.error, "could_not_acquire_lease")
