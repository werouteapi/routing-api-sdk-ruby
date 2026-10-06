# frozen_string_literal: true

# Routing API Ruby SDK - Merchant of Record (Card Processing)
#
# Providers:
#   Paddle       → /api/v2/paddle/*
#   Lemon Squeezy → /api/v2/lemonsqueezy/*
#
# Both work from Tunisia. No Stripe account needed.
# Customers pay by card (Visa, Mastercard, Amex, Apple Pay, Google Pay, PayPal).
# You receive payouts via wire transfer or Payoneer.
#
# Usage:
#   require 'routing_api'
#   require 'mor'
#
#   client = RoutingAPIClient.new(api_key: 'rn_your_key')
#   mor = MoR.new(client)
#
#   # Paddle checkout
#   checkout = mor.paddle_checkout(
#     items: [{ price_id: 'pri_xxx', quantity: 1 }],
#     customer_email: 'user@example.com',
#     success_url: 'https://yourapp.com/thank-you'
#   )
#   # Redirect customer to checkout['checkout_url']
#
#   # Lemon Squeezy checkout
#   checkout = mor.ls_checkout(
#     variant_id: '12345',
#     customer_email: 'user@example.com'
#   )
#   # Redirect customer to checkout['checkout_url']

class MoRError < StandardError; end

class MoR
  def initialize(client)
    @client = client
  end

  # ── Status ────────────────────────────────────────────────────────────────

  def status
    @client.get('api/v2/mor/status')
  end

  # ── Paddle ────────────────────────────────────────────────────────────────

  def paddle_create_product(name:, description: '', tax_category: 'saas')
    @client.post('api/v2/paddle/products', {
      name: name,
      description: description,
      tax_category: tax_category
    })
  end

  def paddle_create_price(product_id:, amount_cents:, currency: 'USD', description: '', billing_cycle: nil)
    body = {
      product_id: product_id,
      amount_cents: amount_cents,
      currency: currency,
      description: description
    }
    body[:billing_cycle] = billing_cycle if billing_cycle
    @client.post('api/v2/paddle/prices', body)
  end

  def paddle_create_customer(email:, name: '')
    @client.post('api/v2/paddle/customers', { email: email, name: name })
  end

  # Create a Paddle hosted checkout. Redirect customer to checkout_url.
  #
  # @param [Hash] opts
  # @option opts [Array<Hash>] :items List of { price_id: 'pri_xxx', quantity: 1 }
  # @option opts [String] :customer_email Pre-fill email
  # @option opts [String] :customer_id Paddle ctm_... (optional)
  # @option opts [String] :success_url Redirect after payment
  # @option opts [Hash] :custom_data Key-value data passed in webhooks
  # @return [Hash] { 'checkout_url' => '...', 'transaction_id' => 'txn_...' }
  def paddle_checkout(items:, customer_email: '', customer_id: '', success_url: '', custom_data: nil)
    body = { items: items }
    body[:customer_email] = customer_email unless customer_email.empty?
    body[:customer_id] = customer_id unless customer_id.empty?
    body[:success_url] = success_url unless success_url.empty?
    body[:custom_data] = custom_data if custom_data
    @client.post('api/v2/paddle/checkout', body)
  end

  def paddle_get_transaction(transaction_id)
    @client.get("api/v2/paddle/transactions/#{transaction_id}")
  end

  def paddle_list_subscriptions(customer_id: '', status: '')
    params = {}
    params[:customer_id] = customer_id unless customer_id.empty?
    params[:status] = status unless status.empty?
    @client.get('api/v2/paddle/subscriptions', params)
  end

  def paddle_cancel_subscription(subscription_id, effective_from: 'next_billing_period')
    @client.post(
      "api/v2/paddle/subscriptions/#{subscription_id}/cancel",
      { effective_from: effective_from }
    )
  end

  # ── Lemon Squeezy ─────────────────────────────────────────────────────────

  def ls_list_products
    @client.get('api/v2/lemonsqueezy/products')
  end

  def ls_list_variants(product_id: '')
    params = product_id.empty? ? {} : { product_id: product_id }
    @client.get('api/v2/lemonsqueezy/variants', params)
  end

  # Create a Lemon Squeezy hosted checkout. Redirect customer to checkout_url.
  #
  # @param [Hash] opts
  # @option opts [String] :variant_id LS product variant ID (required)
  # @option opts [String] :customer_email Pre-fill email
  # @option opts [String] :customer_name Pre-fill name
  # @option opts [String] :success_url Redirect after payment
  # @option opts [Hash] :custom_data Passed in webhooks
  # @option opts [String] :discount_code Pre-apply promo code
  # @return [Hash] { 'checkout_url' => '...', 'checkout_id' => '...' }
  def ls_checkout(variant_id:, customer_email: '', customer_name: '', success_url: '', custom_data: nil, discount_code: '')
    body = { variant_id: variant_id }
    body[:customer_email] = customer_email unless customer_email.empty?
    body[:customer_name] = customer_name unless customer_name.empty?
    body[:success_url] = success_url unless success_url.empty?
    body[:custom_data] = custom_data if custom_data
    body[:discount_code] = discount_code unless discount_code.empty?
    @client.post('api/v2/lemonsqueezy/checkout', body)
  end

  def ls_get_order(order_id)
    @client.get("api/v2/lemonsqueezy/orders/#{order_id}")
  end

  def ls_refund_order(order_id)
    @client.post("api/v2/lemonsqueezy/orders/#{order_id}/refund", {})
  end

  def ls_list_subscriptions(email: '', status: '')
    params = {}
    params[:email] = email unless email.empty?
    params[:status] = status unless status.empty?
    @client.get('api/v2/lemonsqueezy/subscriptions', params)
  end

  def ls_cancel_subscription(subscription_id)
    @client.delete("api/v2/lemonsqueezy/subscriptions/#{subscription_id}")
  end

  # Report API usage for usage-based billing.
  # @param [String] action 'increment' (add to count) or 'set' (override)
  def ls_report_usage(subscription_item_id:, quantity:, action: 'increment')
    @client.post('api/v2/lemonsqueezy/usage', {
      subscription_item_id: subscription_item_id,
      quantity: quantity,
      action: action
    })
  end

  # Create a discount/promo code.
  # @param [String] amount_type 'percent' or 'fixed'
  def ls_create_discount(name:, code:, amount:, amount_type: 'percent', duration: 'once')
    @client.post('api/v2/lemonsqueezy/discounts', {
      name: name,
      code: code,
      amount: amount,
      amount_type: amount_type,
      duration: duration
    })
  end
end
