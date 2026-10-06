# frozen_string_literal: true

# Routing API - Ruby Client
# 
# Universal Crypto-to-Bank Transfers
# 
# Global coverage: 195+ countries with intelligent provider routing.
# Supports bank lookups, SWIFT codes, IBAN validation, crypto transfers.
# 
# Usage:
#   client = RoutingAPI::Client.new('your_api_key')
#   
#   # Crypto to bank transfer
#   result = client.initiate_crypto_to_bank(
#     transaction_id: 'txn_001',
#     source_network: 'bitcoin',
#     source_token: 'BTC',
#     platform_wallet: '1A1z7agoat4bNjRreGMVP8hoShKzChF4P',
#     tx_hash: 'abc123def456',
#     expected_amount: 0.01,
#     customer_id: 'cust_001',
#     bank_account_token: 'ba_token_123'
#   )
#   
#   # Check fees for any country
#   fees = client.calculate_transfer_fees('TN', 100)
# 
# Coverage: 195+ countries (all UN countries except US-sanctioned)
# Languages: 12 SDKs available

require 'http'
require 'json'

module RoutingAPI
  class Error < StandardError; end
  
  class Client
    DEFAULT_BASE_URL = 'http://localhost:8800'
    DEFAULT_TIMEOUT = 30
    
    attr_reader :api_key, :base_url
    
    # Create a new Routing API client
    def initialize(api_key, base_url = DEFAULT_BASE_URL, timeout = DEFAULT_TIMEOUT)
      @api_key = api_key
      @base_url = base_url.gsub(/\/$/, '')
      @timeout = timeout
      @http = HTTP.headers('User-Agent' => 'routing-api-client-ruby/0.1.0')
    end
    
    private
    
    def request(method, endpoint, params = {})
      url = "#{@base_url}#{endpoint}"
      
      response = @http
        .timeout(@timeout)
        .auth("Bearer #{@api_key}")
        .send(method.downcase, url, params: params)
      
      raise Error, response.status if response.status >= 400
      
      response.parse
    end
    
    public
    
    # Look up bank information by routing number
    def lookup_bank(routing_number, transfer_type = 'ach')
      request(:get, '/bank-information', routing_number: routing_number, transfer_type: transfer_type)
    end
    
    # Look up SWIFT/BIC code information
    def lookup_swift(bic)
      request(:get, '/swift-lookup', bic: bic)
    end
    
    # Search for SWIFT codes
    def search_swift(bank_name = nil, country = nil)
      request(:get, '/swift-search', bank_name: bank_name, country: country)
    end
    
    # Validate an IBAN
    def validate_iban(iban)
      request(:get, '/iban-validate', iban: iban)
    end
    
    # Screen a name for OFAC compliance
    def screen_name(name, country = nil)
      request(:get, '/compliance/screen', name: name, country: country)
    end
    
    # Validate a Japanese bank account
    def validate_japan_account(bank_code, branch_code, account_number)
      request(:get, '/account/validate-jp', 
        bank_code: bank_code, 
        branch_code: branch_code, 
        account_number: account_number
      )
    end
    
    # Validate a Korean bank account
    def validate_korea_account(bank_code, account_number)
      request(:get, '/account/validate-kr', 
        bank_code: bank_code, 
        account_number: account_number
      )
    end
    
    # Validate an Australian bank account
    def validate_australia_account(bsb, account_number)
      request(:get, '/account/validate-au', 
        bsb: bsb, 
        account_number: account_number
      )
    end
    
    # Validate a Chinese bank account
    def validate_china_account(bank_code, account_number)
      request(:get, '/account/validate-cn', 
        bank_code: bank_code, 
        account_number: account_number
      )
    end
    
    # Check API health
    def health
      request(:get, '/health')
    end

    # ========== PROOF API: UNIVERSAL CRYPTO → BANK TRANSFERS ==========

    # Initiate complete crypto → USDC → Bank transfer flow
    # Supports ANY cryptocurrency: BTC, ETH, SOL, MATIC, AVAX, ARB, OP, etc.
    def initiate_crypto_to_bank(transaction_id:, source_network:, source_token:, platform_wallet:, 
                       tx_hash:, expected_amount:, customer_id:, bank_account_token:)
      request(:post, '/proof/crypto-to-bank/initiate', {
        transaction_id: transaction_id,
        source_network: source_network,
        source_token: source_token,
        platform_wallet: platform_wallet,
        tx_hash: tx_hash,
        expected_amount: expected_amount,
        customer_id: customer_id,
        bank_account_token: bank_account_token
      })
    end

    # Get complete proof for crypto → bank transaction
    def get_crypto_transaction_proof(transaction_id)
      request(:get, "/proof/crypto-to-bank/#{transaction_id}")
    end

    # Get list of supported cryptocurrencies and networks
    def get_supported_networks
      request(:get, '/proof/supported-networks')
    end

    # Check cryptocurrency balance on any supported network
    def check_crypto_balance(network, address)
      request(:get, "/proof/check-balance/#{network}/#{address}")
    end

    # Get swap quote for any crypto to USDC
    def get_swap_quote(network, token, amount)
      request(:get, "/proof/get-swap-quote/#{network}/#{token}/#{amount}")
    end

    # Get metrics across ALL supported cryptocurrencies
    def get_all_crypto_metrics
      request(:get, '/proof/metrics/all-crypto')
    end

    # ========== GLOBAL PAYMENT ROUTING ==========

    # Get payment provider info for a specific country
    def get_payment_providers(country_code)
      request(:get, "/proof/payment-providers/#{country_code}")
    end

    # Calculate fees for a transfer to a specific country
    def calculate_transfer_fees(country_code, amount)
      request(:get, "/proof/calculate-fees/#{country_code}/#{amount}")
    end

    # Get all available payment providers
    def get_all_payment_providers
      request(:get, '/proof/all-providers')
    end
  end
end
