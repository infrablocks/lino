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

The `CommandLineBuilder` allows a number of different styles of commands to be 
built.

#### Flags

Flags can be added with `#with_flag`:

```ruby
Lino::CommandLineBuilder.for_command('ls')
    .with_flag('-l')
    .with_flag('-a')
    .build
    .to_s

# => ls -l -a
```

or `#with_flags`:

```ruby
Lino::CommandLineBuilder.for_command('ls')
    .with_flags(%w[-l -a])
    .build
    .to_s

# => ls -l -a
```

#### Options

Options with values can be added with `#with_option`:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_option('--recipient', 'tobyclemson@gmail.com')
    .with_option('--sign', './doc.txt')
    .build
    .to_s

# => gpg --recipient tobyclemson@gmail.com --sign ./doc.txt
```

or `#with_options`, either as a hash:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_options({
      '--recipient' => 'tobyclemson@gmail.com',
      '--sign' => './doc.txt'
    })
    .build
    .to_s

# => gpg --recipient tobyclemson@gmail.com --sign ./doc.txt
```

or as an array:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_options(
      [
        { option: '--recipient', value: 'tobyclemson@gmail.com' },
        { option: '--sign', value: './doc.txt' }
      ]
    )
    .build
    .to_s

# => gpg --recipient tobyclemson@gmail.com --sign ./doc.txt
```

Some commands allow options to be repeated:

```ruby
Lino::CommandLineBuilder.for_command('example.sh')
    .with_repeated_option('--opt', ['file1.txt', nil, '', 'file2.txt'])
    .build
    .to_s

# => example.sh --opt file1.txt --opt file2.txt
```

> Note: `lino` ignores `nil` or empty option values in the resulting command 
>       line. 

#### Arguments

Arguments can be added using `#with_argument`:

```ruby 
Lino::CommandLineBuilder.for_command('diff')
    .with_argument('./file1.txt')
    .with_argument('./file2.txt')
    .build
    .to_s

# => diff ./file1.txt ./file2.txt
```

or `#with_arguments`, as an array:

```ruby
Lino::CommandLineBuilder.for_command('diff')
    .with_arguments(['./file1.txt', nil, '', './file2.txt'])
    .build
    .to_s

# => diff ./file1.txt ./file2.txt
```

> Note: `lino` ignores `nil` or empty argument values in the resulting command 
>        line.

#### Option Separators

By default, `lino` separates option values from the option by a space. This
can be overridden globally using `#with_option_separator`:

```ruby
Lino::CommandLineBuilder.for_command('java')
    .with_option_separator(':')
    .with_option('-splash', './images/splash.jpg')
    .with_argument('./application.jar')
    .build
    .to_s

# => java -splash:./images/splash.jpg ./application.jar
```

The option separator can be overridden on an option by option basis:

```ruby
Lino::CommandLineBuilder.for_command('java')
    .with_option('-splash', './images/splash.jpg', separator: ':')
    .with_argument('./application.jar')
    .build
    .to_s

# => java -splash:./images/splash.jpg ./application.jar
```

> Note: `#with_options` supports separator overriding when the options are
>       passed as an array of hashes and a `separator` key is included in the 
>       hash.

> Note: `#with_repeated_option` also supports the `separator` named parameter.

> Note: option specific separators take precedence over the global option 
>       separator 

#### Option Quoting

By default, `lino` does not quote option values. This can be overridden 
globally using `#with_option_quoting`:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_option_quoting('"')
    .with_option('--sign', 'some file.txt')
    .build
    .to_s

# => gpg --sign "some file.txt"
```

The option quoting can be overridden on an option by option basis:

```ruby
Lino::CommandLineBuilder.for_command('java')
    .with_option('-splash', './images/splash.jpg', quoting: '"')
    .with_argument('./application.jar')
    .build
    .to_s

# => java -splash "./images/splash.jpg" ./application.jar
```

> Note: `#with_options` supports quoting overriding when the options are
>       passed as an array of hashes and a `quoting` key is included in the 
>       hash.

> Note: `#with_repeated_option` also supports the `quoting` named parameter.

> Note: option specific quoting take precedence over the global option 
>       quoting 

#### Subcommands

Subcommands can be added using `#with_subcommand`:

```ruby
Lino::CommandLineBuilder.for_command('git')
    .with_flag('--no-pager')
    .with_subcommand('log')
    .build
    .to_s

# => git --no-pager log
```

Multi-level subcommands can be added using multiple `#with_subcommand` 
invocations:

```ruby
Lino::CommandLineBuilder.for_command('gcloud')
    .with_subcommand('sql')
    .with_subcommand('instances')
    .with_subcommand('set-root-password')
    .with_subcommand('some-database')
    .build
    .to_s

# => gcloud sql instances set-root-password some-database
```

or using `#with_subcommands`:
     
```ruby
Lino::CommandLineBuilder.for_command('gcloud')
    .with_subcommands(
      %w[sql instances set-root-password some-database]
    )
    .build
    .to_s
    
# => gcloud sql instances set-root-password some-database
```

Subcommands also support options via `#with_flag`, `#with_flags`, 
`#with_option`, `#with_options` and `#with_repeated_option` just like commands,
via a block, for example: 

```ruby
Lino::CommandLineBuilder.for_command('git')
    .with_flag('--no-pager')
    .with_subcommand('log') do |sub|
      sub.with_option('--since', '2016-01-01')
    end
    .build
    .to_s

# => git --no-pager log --since 2016-01-01
```

> Note: `#with_subcommands` also supports a block, which applies in the context
>       of the last subcommand in the passed array.

#### Environment Variables

Command lines can be prefixed with environment variables using 
`#with_environment_variable`:
  
```ruby
Lino::CommandLineBuilder.for_command('node')
    .with_environment_variable('PORT', '3030')
    .with_environment_variable('LOG_LEVEL', 'debug')
    .with_argument('./server.js')
    .build
    .to_s
    
# => PORT=3030 LOG_LEVEL=debug node ./server.js
```

or `#with_environment_variables`, either as a hash:

```ruby
Lino::CommandLineBuilder.for_command('node')
    .with_environment_variables({
      'PORT' => '3030',
      'LOG_LEVEL' => 'debug'
    })
    .build
    .to_s
    
# => PORT=3030 LOG_LEVEL=debug node ./server.js
```

or as an array:

```ruby
Lino::CommandLineBuilder.for_command('node')
    .with_environment_variables(
      [
        { name: 'PORT', value: '3030' },
        { name: 'LOG_LEVEL', value: 'debug' }
      ]
    )
    .build
    .to_s
    
# => PORT=3030 LOG_LEVEL=debug node ./server.js
```

#### Option Placement

By default, `lino` places top-level options after the command, before all 
subcommands and arguments.

This is equivalent to calling `#with_options_after_command`:

```ruby
Lino::CommandLineBuilder.for_command('gcloud')
    .with_options_after_command
    .with_option('--password', 'super-secure')
    .with_subcommands(%w[sql instances set-root-password])
    .build
    .to_s

# => gcloud --password super-secure sql instances set-root-password
```

Alternatively, top-level options can be placed after all subcommands using
`#with_options_after_subcommands`:

```ruby
Lino::CommandLineBuilder.for_command('gcloud')
    .with_options_after_subcommands
    .with_option('--password', 'super-secure')
    .with_subcommands(%w[sql instances set-root-password])
    .build
    .to_s

# => gcloud sql instances set-root-password --password super-secure
```

or, after all arguments, using `#with_options_after_arguments`:

```ruby
Lino::CommandLineBuilder.for_command('ls')
    .with_options_after_arguments
    .with_flag('-l')
    .with_argument('/some/directory')
    .build
    .to_s

# => ls /some/directory -l
```

The option placement can be overridden on an option by option basis:

```ruby
Lino::CommandLineBuilder.for_command('gcloud')
    .with_options_after_subcommands
    .with_option('--log-level', 'debug', placement: :after_command)
    .with_option('--password', 'super-secure')
    .with_subcommands(%w[sql instances set-root-password])
    .build
    .to_s

# => gcloud --log-level debug sql instances set-root-password \ 
#      --password super-secure
```

The `:placement` keyword argument accepts placement values of `:after_command`,
`:after_subcommands` and `:after_arguments`.

> Note: `#with_options` supports placement overriding when the options are
>       passed as an array of hashes and a `placement` key is included in the
>       hash.

> Note: `#with_repeated_option` also supports the `placement` named parameter.

> Note: option specific placement take precedence over the global option
>       placement

#### Appliables

Command and subcommand builders both support passing 'appliables' that are
applied to the builder allowing an operation to be encapsulated in an object.

Given an appliable type:

```ruby
class AppliableOption
  def initialize(option, value)
    @option = option
    @value = value
  end

  def apply(builder)
    builder.with_option(@option, @value)
  end
end
```

an instance of the appliable can be applied using `#with_appliable`:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_appliable(AppliableOption.new('--recipient', 'tobyclemson@gmail.com'))
    .with_flag('--sign')
    .with_argument('/some/file.txt')
    .build
    .to_s

# => gpg --recipient tobyclemson@gmail.com --sign /some/file.txt 
```

or multiple with `#with_appliables`:

```ruby
Lino::CommandLineBuilder.for_command('gpg')
    .with_appliables([
      AppliableOption.new('--recipient', 'user@example.com'),
      AppliableOption.new('--output', '/signed.txt')
    ])
    .with_flag('--sign')
    .with_argument('/file.txt')
    .build
    .to_s

# => gpg --recipient user@example.com --output /signed.txt --sign /file.txt 
```

> Note: an 'appliable' is any object that has an `#apply` method.

> Note: `lino` ignores `nil` or empty appliables in the resulting command line.

### `Lino::CommandLine`

A `CommandLine` can be executed using the `#execute` method:

```ruby
command_line = Lino::CommandLineBuilder.for_command('ls')
    .with_flag('-l')
    .with_flag('-a')
    .with_argument('/')
    .build
    
command_line.execute
  
# => <contents of / directory> 
```

By default, the standard input stream is empty and the process writes to the 
standard output and error streams.

To populate standard input:

```ruby
command_line.execute(stdin: 'something to be passed to standard input')
```

The `stdin` option supports any object that responds to `each`, `read` or 
`to_s`.

To provide custom streams for standard output or standard error:

```ruby
require 'stringio'
  
stdout = StringIO.new
stderr = StringIO.new
  
command_line.execute(stdout: stdout, stderr: stderr)
  
puts "[output: #{stdout.string}, error: #{stderr.string}]"
```

The `stdout` and `stderr` options support any object that responds to `<<`.

## Development

To install dependencies and run the build, run the pre-commit build:

```shell script
./go
```

This runs all unit tests and other checks including coverage and code linting / 
formatting.

To run only the unit tests, including coverage:

```shell script
./go test:unit
```

To attempt to fix any code linting / formatting issues:

```shell script
./go library:fix
```

To check for code linting / formatting issues without fixing:

```shell script
./go library:check
```

You can also run `bin/console` for an interactive prompt that will allow you to 
experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/lino. This project is intended to be a safe, 
welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
