class_name JestSubscription
extends RefCounted

## SKU identifier for this subscription.
var sku: String = ""
## Display name of the subscription.
var display_name: String = ""
## Optional description. Empty string when null.
var display_description: String = ""
## Entitlement status: "active" or "inactive".
var status: String = ""
## Price in the specified currency, in decimal.
var price: float = 0.0
## ISO currency code, e.g. "USD".
var currency: String = ""
## Billing period: "monthly", "yearly", or "weekly".
var billing_period: String = ""
## Whether the wallet is eligible for this subscription's free trial: it has a
## trial configured and the wallet has never subscribed to it before.
var trial_eligible: bool = false
## @deprecated Always 0. Kept for SDK backwards compatibility.
var estimated_revenue: float = 0.0


static func from_dict(d: Dictionary) -> JestSubscription:
	var s := JestSubscription.new()
	s.sku = str(d.get("sku", ""))
	s.display_name = str(d.get("displayName", ""))
	var desc = d.get("displayDescription", null)
	s.display_description = str(desc) if desc != null else ""
	s.status = str(d.get("status", "inactive"))
	s.price = float(d.get("price", 0.0))
	s.currency = str(d.get("currency", ""))
	s.billing_period = str(d.get("billingPeriod", ""))
	s.trial_eligible = bool(d.get("trialEligible", false))
	s.estimated_revenue = float(d.get("estimatedRevenue", 0.0))
	return s
