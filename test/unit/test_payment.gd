extends GutTest
## Tests for JestPayment using mock bridge


var bridge: JestBridge
var payment: JestPayment


func before_each():
	bridge = JestBridge.new()
	payment = JestPayment.new(bridge)


func test_get_products_returns_typed_array():
	var products = await payment.get_products()
	assert_true(products is Array)
	assert_gt(products.size(), 0)
	assert_true(products[0] is JestProduct)
	assert_eq(products[0].sku, "gems_100")


func test_begin_purchase_success():
	bridge._mock.mock_purchase_succeeds = true
	var result = await payment.begin_purchase("gems_100")
	assert_true(result is JestPurchaseResult)
	assert_true(result.ok)
	assert_eq(result.status, JestPurchaseResult.Status.SUCCESS)
	assert_not_null(result.purchase)
	assert_eq(result.purchase.product_sku, "gems_100")


func test_begin_purchase_cancel():
	bridge._mock.mock_purchase_succeeds = false
	var result = await payment.begin_purchase("gems_100")
	assert_false(result.ok)
	assert_eq(result.status, JestPurchaseResult.Status.CANCELED)


func test_begin_purchase_empty_sku():
	var result = await payment.begin_purchase("")
	assert_false(result.ok)
	assert_eq(result.error, "invalid_sku")


func test_complete_purchase():
	var result = await payment.complete_purchase("mock_token")
	assert_true(result is JestResult)
	assert_true(result.ok)


func test_complete_purchase_empty_token():
	var result = await payment.complete_purchase("")
	assert_false(result.ok)
	assert_eq(result.error, "invalid_token")


func test_get_incomplete_purchases():
	var result = await payment.get_incomplete_purchases()
	assert_true(result is JestIncompletePurchasesResult)
	assert_true(result.ok)
	assert_false(result.has_more)
	assert_eq(result.purchases.size(), 0)
