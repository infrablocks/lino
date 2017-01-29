# Lino

Command line execution utilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lino'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lino

## Usage

Lino allows commands to be built and executed:

```ruby
require 'lino'
  
command_line = Lino::CommandLineBuilder.for_command('ruby')
    .with_flag('-v')
    .with_option('-e', 'puts "Hello"')
    .build
    
puts command_line.to_s 
# => ruby -v -e puts "Hello"
  
command_line.execute 
# ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
# Hello
```

### `Lino::CommandLineBuilder`

The `CommandLineBuilder` allows a number of different styles of commands to be built:

```ruby
# commands with flags
Lino::CommandLineBuilder.for_command('ls')
    .with_flag('-l')
    .with_flag('-a')
    .build
    .to_s
    
# => ls -l -a
  
# commands with options
Lino::CommandLineBuilder.for_command('gpg')
    .with_option('--recipient', 'tobyclemson@gmail.com')
    .with_option('--sign', './doc.txt')
    .build
    .to_s 
    
# => gpg --recipient tobyclemson@gmail.com --sign ./doc.txt
  
# commands with arguments
Lino::CommandLineBuilder.for_command('diff')
    .with_argument('./file1.txt')
    .with_argument('./file2.txt')
    .build
    .to_s 
    
# => diff ./file1.txt ./file2.txt
  
# commands with custom option separator
Lino::CommandLineBuilder.for_command('java')
    .with_option_separator(':')
    .with_option('-splash', './images/splash.jpg')
    .with_argument('./application.jar')
    .build
    .to_s 
    
# => java -splash:./images/splash.jpg ./application.jar
  
# commands using a subcommand style
Lino::CommandLineBuilder.for_command('git')
    .with_flag('--no-pager')
    .with_subcommand('log') do |sub|
      sub.with_option('--since', '2016-01-01')
    end
    .build
    .to_s
    
# => git --no-pager log --since 2016-01-01
  
# commands with multiple levels of subcommand
Lino::CommandLineBuilder.for_command('gcloud')
    .with_subcommand('sql')
    .with_subcommand('instances')
    .with_subcommand('set-root-password')
    .with_subcommand('some-database') do |sub|
      sub.with_option('--password', 'super-secure')
    end
    .build
    .to_s
    
# => gcloud sql instances set-root-password some-database --password super-secure
  
# commands controlled by environment variables
Lino::CommandLineBuilder.for_command('node')
    .with_environment_variable('PORT', '3030')
    .with_environment_variable('LOG_LEVEL', 'debug')
    .with_argument('./server.js')
    .build
    .to_s
    
# => PORT=3030 LOG_LEVEL=debug node ./server.js
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyclemson/lino. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

