# JsonApiModel

Much like `ActiveRecord` is an ORM on top of your database, [`JSON API Client`](https://github.com/JsonApiClient/json_api_client) is an ORM specific to a service. This gem is the `app/models/` on top of `json_api_client`. 

Yes, you can put business in the client, but if you need to distrubute the gem, you will want that to live somewhere else. This gem provides a thin wrapper layer to let you do that. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_api_model

## Usage

TODO: finish writing this

Sample Base Class

```ruby
module MyService
  class Base < JsonApiModel::Model

    wraps MyService::Client::Base

    # delegates connection options to the Client::Base without having to modify the gem
    self.connection do | conn |
      conn.use Faraday::Response::Logger, Rails.logger

      conn.faraday.options.merge!(
        open_timeout: 5,
        timeout: 5
      )
    end
  end
end
```

Inherited Class

```ruby
module MySerive
  class MyModel < Base
    wraps MyService::Client::MyModel

    def instanece_level_business
      42
    end
  end
end
```

In the controller

```ruby
class WhateversController < ApplicationController
  def index
    render json: MyService::MyModel.where( request.query_parameters ).all.as_json
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/json_api_model. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JsonApiModel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/json_api_model/blob/master/CODE_OF_CONDUCT.md).
