module RoutingAPI
  ##
  # Routing API Ruby SDK - Billing Integration
  #
  # Provides methods for usage tracking, subscription management, and invoices
  #
  # Usage:
  #   client = RoutingAPI::Client.new(api_key: 'rn_your_key')
  #   billing = RoutingAPI::Billing.new(client)
  #
  #   # Get current usage
  #   usage = billing.get_usage
  #   puts "Charges: $#{usage['charges_this_month']}"
  #
  #   # Create subscription
  #   sub = billing.create_subscription(plan: 'professional', payment_provider: 'dodo')
  #   puts "Status: #{sub['status']}"
  #
  class Billing
    BASE_ENDPOINT = 'api/v2/billing'

    def initialize(client)
      @client = client
    end

    ##
    # Get current month's usage and charges
    #
    def get_usage
      @client.request('GET', "#{BASE_ENDPOINT}/usage")
    end

    ##
    # Estimate monthly charges
    #
    def estimate_charges(requests_count, avg_amount = 0)
      base = requests_count * 0.50
      percent = avg_amount > 0 ? (requests_count * avg_amount) * 0.015 : 0
      {
        requests: requests_count,
        avg_amount: avg_amount,
        base_charge: base,
        percent_charge: percent,
        total_charge: base + percent
      }
    end

    ##
    # Create or upgrade to a subscription.
    #
    def create_subscription(plan:, payment_provider: '', payment_customer_id: '', payment_subscription_id: '')
      unless %w[starter professional enterprise].include?(plan)
        raise BillingError, "Invalid plan: #{plan}"
      end

      unless %w[dodo polar paddle lemon_squeezy].include?(payment_provider)
        raise BillingError, "Invalid payment_provider: #{payment_provider}"
      end

      payload = { plan: plan, payment_provider: payment_provider }
      payload[:payment_customer_id]     = payment_customer_id     unless payment_customer_id.empty?
      payload[:payment_subscription_id] = payment_subscription_id unless payment_subscription_id.empty?

      @client.request('POST', "#{BASE_ENDPOINT}/subscribe", payload)
    end

    ##
    # Update subscription (change_plan, pause, resume)
    #
    def update_subscription(action:, plan: nil)
      payload = { action: action }
      payload[:plan] = plan if plan

      @client.request('PATCH', "#{BASE_ENDPOINT}/subscription", payload)
    end

    ##
    # Cancel subscription
    #
    def cancel_subscription
      @client.request('POST', "#{BASE_ENDPOINT}/cancel")
    end

    ##
    # List invoices with pagination
    #
    def list_invoices(limit: 50, offset: 0, status: nil)
      limit = [limit, 100].min
      endpoint = "#{BASE_ENDPOINT}/invoices?limit=#{limit}&offset=#{offset}"
      endpoint += "&status=#{status}" if status

      @client.request('GET', endpoint)
    end

    ##
    # Get specific invoice with line items
    #
    def get_invoice(invoice_id)
      @client.request('GET', "#{BASE_ENDPOINT}/invoices/#{invoice_id}")
    end

    ##
    # Get revenue-share partner dashboard
    #
    def get_revenue_share_dashboard
      @client.request('GET', "#{BASE_ENDPOINT}/revenue-share")
    end

    ##
    # Switch billing model
    #
    def switch_billing_model(model:, plan: nil)
      unless %w[pay_per_tx subscription revenue_share].include?(model)
        raise BillingError, "Invalid model: #{model}"
      end

      payload = { model: model }
      payload[:plan] = plan if plan

      @client.request('POST', "#{BASE_ENDPOINT}/switch-model", payload)
    end

    ##
    # Estimate monthly costs for different models
    #
    def estimate_monthly_cost(requests: 100_000, avg_amount: 50)
      ppt_cost = (requests * 0.50) + (requests * avg_amount * 0.015)

      sub_costs = {
        starter: 99.00,
        professional: 499.00,
        enterprise: 1999.00
      }

      results = {
        requests: requests,
        avg_amount: avg_amount,
        pay_per_tx: ppt_cost,
        subscription_starter: sub_costs[:starter],
        subscription_professional: sub_costs[:professional],
        subscription_enterprise: sub_costs[:enterprise]
      }

      best_cost = ppt_cost
      best_model = 'pay_per_tx'

      sub_costs.each do |model, cost|
        if cost < best_cost
          best_cost = cost
          best_model = "subscription_#{model}"
        end
      end

      results[:best_model] = best_model
      results[:best_cost] = best_cost
      results[:savings_vs_pay_per_tx] = ppt_cost - best_cost
      results[:savings_percent] = ppt_cost > 0 ? ((ppt_cost - best_cost) / ppt_cost * 100) : 0

      results
    end
  end

  ##
  # Billing-specific error
  #
  class BillingError < StandardError; end
end
