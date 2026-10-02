# Routing API Ruby Client

Official Ruby client for the [Routing API](https://routing-api.com) — the most comprehensive bank and payment routing service.

## Features

- **Bank Lookups** - Search by routing number, Swift code, IBAN
- **SWIFT Codes** - 112,000+ BIC/SWIFT codes with bank details
- **IBAN Validation** - Validate and parse IBAN numbers
- **OFAC Screening** - Screen against US Treasury OFAC SDN list
- **Asia-Pacific Support** - Japan, Korea, Australia, China account validation
- **Async Support** - Async operations with Net::HTTP or Faraday
- **Ruby Idiomatic** - Follows Ruby conventions and best practices
- **Error Handling** - Custom exceptions for better error handling

## Installation

Add to your Gemfile:

```ruby
gem 'routing-api-client'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install routing-api-client
```

## Quick Start

```ruby
require 'routing_api'

client = RoutingAPI::Client.new(api_key: 'your_api_key')

# Lookup bank by routing number
bank = client.lookup_bank('121000245', transfer_type: 'ach')
puts bank['name']  # Wells Fargo Bank, Na

# Validate IBAN
result = client.validate_iban('DE89370400440532013000')
puts result['valid']    # true
puts result['country']  # DE

# OFAC screening
screening = client.screen_name('John Smith', country: 'US')
puts screening['risk_level']  # low
```

## API Methods

### lookup_bank()

Look up bank information by routing number.

```ruby
bank = client.lookup_bank('121000245', transfer_type: 'ach', format: 'json')

puts bank['name']     # Wells Fargo Bank, Na
puts bank['address']  # 1 Home Street
puts bank['city']     # San Francisco
puts bank['state']    # CA
puts bank['active']   # true
```

### lookup_swift()

Look up SWIFT/BIC code information.

```ruby
swift = client.lookup_swift('PBNAUS33')

puts swift['bic']       # PBNAUS33
puts swift['bank_name'] # PITNEY BOWES INC
puts swift['country']   # US
```

### search_swift()

Search for SWIFT codes by bank name and/or country.

```ruby
results = client.search_swift(bank_name: 'Wells', country: 'US')

results.each do |swift|
  puts "#{swift['bic']}: #{swift['bank_name']}"
end
```

### validate_iban()

Validate an IBAN (International Bank Account Number).

```ruby
result = client.validate_iban('DE89370400440532013000')

puts result['valid']            # true
puts result['country']          # DE
puts result['bank_code']        # 37040044
puts result['account_number']   # 0532013000
```

### screen_name()

Screen a name against OFAC SDN list.

```ruby
result = client.screen_name('Osama Bin Laden', country: 'US')

puts result['risk_level']  # high
puts result['is_blocked']  # true
puts result['matches']     # [...]
```

### validate_japan_account()

Validate a Japanese bank account.

```ruby
result = client.validate_japan_account(
  bank_code: '0005',
  branch_code: '001',
  account_number: '1234567'
)

puts result['valid']          # true
puts result['bank_name']      # Mizuho Bank
puts result['account_type']   # Savings
```

### validate_korea_account()

Validate a South Korean bank account.

```ruby
result = client.validate_korea_account(
  bank_code: '004',
  account_number: '12345678901'
)

puts result['valid']        # true
puts result['bank_name']    # KB Kookmin Bank
puts result['swift_code']   # KKBKKRSE
```

### validate_australia_account()

Validate an Australian bank account.

```ruby
result = client.validate_australia_account(
  bsb: '012-001',
  account_number: '123456789'
)

puts result['valid']       # true
puts result['bank_name']   # Westpac Banking Corporation
puts result['state']       # NSW
```

### validate_china_account()

Validate a Chinese bank account.

```ruby
result = client.validate_china_account(
  bank_code: '102100001',
  account_number: '123456789'
)

puts result['valid']        # true
puts result['bank_name']    # Bank of China
puts result['swift_code']   # BKCHUS33
```

### get_health()

Check API health status.

```ruby
health = client.get_health

puts health['status']             # healthy
puts health['routing_records']    # 15234
puts health['swift_records']      # 112456
puts health['ofac_records']       # 8532
```

## Error Handling

```ruby
begin
  bank = client.lookup_bank('invalid')
rescue RoutingAPI::APIError => e
  puts "API Error: #{e.message}"
rescue RoutingAPI::NotFoundError => e
  puts "Bank not found"
end
```

## Configuration

### Custom Base URL

```ruby
client = RoutingAPI::Client.new(
  api_key: 'your_api_key',
  base_url: 'https://api.routing-api.com'
)
```

### Custom Timeout

```ruby
client = RoutingAPI::Client.new(
  api_key: 'your_api_key',
  timeout: 60
)
```

## Requirements

- Ruby 2.7+
- Net::HTTP (included) or Faraday gem

## Development

### Install dependencies

```bash
bundle install
```

### Run tests

```bash
bundle exec rake test
```

### Format code

```bash
bundle exec rubocop -a
```

### Lint

```bash
bundle exec rubocop
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details

## Support

- 📚 [Documentation](https://docs.routing-api.com/ruby)
- 💬 [Discord Community](https://discord.gg/routing-api)
- 📧 [Email Support](mailto:support@routing-api.com)
- 🐛 [Issue Tracker](https://github.com/routing-api-clients/ruby-client/issues)

## Changelog

### v0.1.0 (2024-10-02)

- Initial release
- Bank lookups via routing number
- SWIFT code lookups and search
- IBAN validation
- OFAC screening
- Asia-Pacific account validation (JP, KR, AU, CN)
- Ruby idiomatic API
- Comprehensive error handling
