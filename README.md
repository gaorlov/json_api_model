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

## Disclaimer

This is a work in progress. Right now only fetching data works. This will soon change.

## Usage

Using the model wrappers is pretty straighforward. It thinly wraps `JsonApiClient` to separate communication defintions from your in-app business specific logic. To specify what client class your model is wrapping, use the `wraps` method.

Any instance or class(non-query) level method will fall thorugh to the client.

### Example

If you have an app that talks to a `user` service. Here's how your `User` model might look:

```ruby
module UserService
  class User < JsonApiModel::Model
    wraps UserService::Client::User

    def lucky_number
      42
    end
  end
end
```

And the interaction with it is not that different from how you would work with the client:

```ruby
# fetching looks identical to as json_api_client (because it thinly wraps it)
user = UserService::User.where( id: 8 ).first

# now you can access your app logic
user.lucky_number

# => 42

# but also transparently access the client properties
user.id
# => 8
```

### Rendering

If you need to propagate your response set up, `JsonApiModel` adds `as_json` handling so that:

```ruby
class WhateversController < ApplicationController
  def index
    render json: MyService::MyModel.where( params ).all
  end
end
```

Would produce the standard JSONAPI response of:

```ruby
{
  data: data,
  meta: meta
}
```

But if that's not the structure you want, you can modify the `to_json` output as:

```ruby
class MyModelInRussianConroller < ApplicationController

  def индекс
    @response = MyModel.where( params ).all

    @response.as_json do |data, meta|
      {
        данные: data,
        мета: {
          счёт: meta["record_count"],
          страницы: meta["page_count"]
        }
      }
    end
  end
end
```


### Configuration

If you don't want to override the connection configuration of the client gem in an initializer, you can modify the connection options inside an inhrited class.

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

### Monitoring

`JsonApiModel` emits several `ActiveSupport::Notifications` events you can subscribe to:

* `find.json_api_model`: fires on every `find`/`all`/`to_a` call. Probably most common.

  | key  | value |
  |------|-------|
  | url  | full url hit |
  | args | args passed into the requestor |

* `first.json_api_model`: fires on `Model.first`
  
  | key  | value |
  |------|-------|
  | url  | full url hit |

* `last.json_api_model`: fired on `Model.last`
  
  | key  | value |
  |------|-------|
  | url  | full url hit |

**NOTE**: By default the instrumenter is null, so be sure to configure your app to actually have a notifier and subscribe to the events

```ruby
# config/initializers/json_api_model.rb
JsonApiModel.instrumenter = ActiveSupport::Notifications.instrumenter

ActiveSupport::Notifications.subscribe "find.json_api_model" do |name, started, finished, unique_id, payload|
  Rails.logger.debug ['notification:', name, started, finished, unique_id, payload].join(' ')
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gaorlov/json_api_model. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JsonApiModel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gaorlov/json_api_model/blob/master/CODE_OF_CONDUCT.md).
