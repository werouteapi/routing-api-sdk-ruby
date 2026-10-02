# frozen_string_literal: true

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
  end
end
