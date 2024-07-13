# Lino

Command line building and execution utilities.

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
  
command_line = Lino.builder_for_command('ruby')
    .with_flag('-v')
    .with_option('-e', 'puts "Hello"')
    .build
    
puts command_line.array
# => ['ruby', '-v', '-e', 'puts "Hello"']
  
puts command_line.string
# => ruby -v -e puts "Hello"
  
command_line.execute 
# ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
# Hello
```

### Building command lines

`Lino` supports building command lines via instances of the 
`Lino::Builder::CommandLine` class. `Lino::Builder::CommandLine` allows a 
number of different styles of commands to be built. The object built by 
`Lino::Builder::CommandLine` is an instance of `Lino::Model::CommandLine`, which
represents the components and context of a command line and allows the 
command line to be executed. 

Aside from the object model, `Lino::Model::CommandLine` instances have two 
representations, accessible via the `#string` and `#array` instance methods.

The string representation is useful when the command line is intended to be
executed by a shell, where quoting is important. However, it can present a 
security risk if the components (option values, arguments, environment 
variables) of the command line are user provided. For this reason, the array
representation is preferable and is the representation used by default whenever 
`Lino` executes commands.

#### Getting a command line builder

A `Lino::Builder::CommandLine` can be instantiated using:

```ruby
Lino.builder_for_command('ls')
```

or using the now deprecated:

```ruby
Lino::CommandLineBuilder.for_command('ls')
```

#### Flags

Flags can be added with `#with_flag`:

```ruby
command_line = Lino.builder_for_command('ls')
    .with_flag('-l')
    .with_flag('-a')
    .build

command_line.array
# => ["ls", "-l", "-a"]
command_line.string
# => "ls -l -a"
```

or `#with_flags`:

```ruby
command_line = Lino.builder_for_command('ls')
    .with_flags(%w[-l -a])
    .build

command_line.array
# => ["ls", "-l", "-a"]
command_line.string
# => "ls -l -a"
```

#### Options

Options with values can be added with `#with_option`:

```ruby
command_line = Lino.builder_for_command('gpg')
    .with_option('--recipient', 'tobyclemson@gmail.com')
    .with_option('--sign', './doc.txt')
    .build

command_line.array
# => ["gpg", "--recipient", "tobyclemson@gmail.com", "--sign", "./doc.txt"]
command_line.string
# => "gpg --recipient tobyclemson@gmail.com --sign ./doc.txt"

```

or `#with_options`, either as a hash:

```ruby
command_line = Lino.builder_for_command('gpg')
    .with_options({
      '--recipient' => 'tobyclemson@gmail.com',
      '--sign' => './doc.txt'
    })
    .build

command_line.array
# => ["gpg", "--recipient", "tobyclemson@gmail.com", "--sign", "./doc.txt"]
command_line.string
# => "gpg --recipient tobyclemson@gmail.com --sign ./doc.txt"
```

or as an array:

```ruby
command_line = Lino.builder_for_command('gpg')
    .with_options(
      [
        { option: '--recipient', value: 'tobyclemson@gmail.com' },
        { option: '--sign', value: './doc.txt' }
      ]
    )
    .build

command_line.array
# => ["gpg", "--recipient", "tobyclemson@gmail.com", "--sign", "./doc.txt"]
command_line.string
# => "gpg --recipient tobyclemson@gmail.com --sign ./doc.txt"
```

Some commands allow options to be repeated:

```ruby
command_line = Lino.builder_for_command('example.sh')
    .with_repeated_option('--opt', ['file1.txt', nil, '', 'file2.txt'])
    .build

command_line.array
# => ["example.sh", "--opt", "file1.txt", "--opt", "file2.txt"]
command_line.string
# => "example.sh --opt file1.txt --opt file2.txt"
```

> Note: `lino` ignores `nil` or empty option values in the resulting command 
>       line. 

#### Arguments

Arguments can be added using `#with_argument`:

```ruby 
command_line = Lino.builder_for_command('diff')
    .with_argument('./file1.txt')
    .with_argument('./file2.txt')
    .build

command_line.array
# => ["diff", "./file1.txt", "./file2.txt"]
command_line.string
# => "diff ./file1.txt ./file2.txt"
```

or `#with_arguments`, as an array:

```ruby
command_line = Lino.builder_for_command('diff')
    .with_arguments(['./file1.txt', nil, '', './file2.txt'])
    .build

command_line.array
# => ["diff", "./file1.txt", "./file2.txt"]
command_line.string
# => "diff ./file1.txt ./file2.txt"
```

> Note: `lino` ignores `nil` or empty argument values in the resulting command 
>        line.

#### Option Separators

By default, when rendering command lines as a string, `lino` separates option 
values from the option by a space. This can be overridden globally using 
`#with_option_separator`:

```ruby
command_line = Lino.builder_for_command('java')
    .with_option_separator(':')
    .with_option('-splash', './images/splash.jpg')
    .with_argument('./application.jar')
    .build

command_line.array
# => ["java", "-splash:./images/splash.jpg", "./application.jar"]
command_line.string
# => "java -splash:./images/splash.jpg ./application.jar"
```

The option separator can also be overridden on an option by option basis:

```ruby
command_line = Lino.builder_for_command('java')
    .with_option('-splash', './images/splash.jpg', separator: ':')
    .with_argument('./application.jar')
    .build

command_line.array
# => ["java", "-splash:./images/splash.jpg", "./application.jar"]
command_line.string
# => "java -splash:./images/splash.jpg ./application.jar"
```

> Note: `#with_options` supports separator overriding when the options are
>       passed as an array of hashes and a `separator` key is included in the 
>       hash.

> Note: `#with_repeated_option` also supports the `separator` named parameter.

> Note: option specific separators take precedence over the global option 
>       separator 

#### Option Quoting

By default, when rendering command line strings, `lino` does not quote option 
values. This can be overridden globally using `#with_option_quoting`:

```ruby
command_line = Lino.builder_for_command('gpg')
    .with_option_quoting('"')
    .with_option('--sign', 'some file.txt')
    .build

command_line.string
# => "gpg --sign \"some file.txt\""
command_line.array
# => ["gpg", "--sign", "some file.txt"]
```

The option quoting can also be overridden on an option by option basis:

```ruby
command_line = Lino.builder_for_command('java')
    .with_option('-splash', './images/splash.jpg', quoting: '"')
    .with_argument('./application.jar')
    .build
    .string

command_line.string
# => "java -splash \"./images/splash.jpg\" ./application.jar"
command_line.array
# => ["java", "-splash", "./images/splash.jpg", "./application.jar"]
```

> Note: `#with_options` supports quoting overriding when the options are
>       passed as an array of hashes and a `quoting` key is included in the 
>       hash.

> Note: `#with_repeated_option` also supports the `quoting` named parameter.

> Note: option specific quoting take precedence over the global option 
>       quoting 

> Note: option quoting has no impact on the array representation of a command 
>       line

#### Subcommands

Subcommands can be added using `#with_subcommand`:

```ruby
command_line = Lino.builder_for_command('git')
    .with_flag('--no-pager')
    .with_subcommand('log')
    .build

command_line.array
# => ["git", "--no-pager", "log"]
command_line.string
# => "git --no-pager log"
```

Multi-level subcommands can be added using multiple `#with_subcommand` 
invocations:

```ruby
command_line = Lino.builder_for_command('gcloud')
    .with_subcommand('sql')
    .with_subcommand('instances')
    .with_subcommand('set-root-password')
    .with_subcommand('some-database')
    .build

command_line.array
# => ["gcloud", "sql", "instances", "set-root-password", "some-database"]
command_line.string
# => "gcloud sql instances set-root-password some-database"
```

or using `#with_subcommands`:
     
```ruby
command_line = Lino.builder_for_command('gcloud')
    .with_subcommands(
      %w[sql instances set-root-password some-database]
    )
    .build

command_line.array
# => ["gcloud", "sql", "instances", "set-root-password", "some-database"]
command_line.string
# => "gcloud sql instances set-root-password some-database"
```

Subcommands also support options via `#with_flag`, `#with_flags`, 
`#with_option`, `#with_options` and `#with_repeated_option` just like commands,
via a block, for example: 

```ruby
command_line = Lino.builder_for_command('git')
    .with_flag('--no-pager')
    .with_subcommand('log') do |sub|
      sub.with_option('--since', '2016-01-01')
    end
    .build

command_line.array
# => ["git", "--no-pager", "log", "--since", "2016-01-01"]
command_line.string
# => "git --no-pager log --since 2016-01-01"
```

> Note: `#with_subcommands` also supports a block, which applies in the context
>       of the last subcommand in the passed array.

#### Environment Variables

Environment variables can be added to command lines using 
`#with_environment_variable`:
  
```ruby
command_line = Lino.builder_for_command('node')
    .with_environment_variable('PORT', '3030')
    .with_environment_variable('LOG_LEVEL', 'debug')
    .with_argument('./server.js')
    .build

command_line.string
# => "PORT=\"3030\" LOG_LEVEL=\"debug\" node ./server.js"
command_line.array
# => ["node", "./server.js"]
command_line.env
# => {"PORT"=>"3030", "LOG_LEVEL"=>"debug"}
```

or `#with_environment_variables`, either as a hash:

```ruby
command_line = Lino.builder_for_command('node')
    .with_environment_variables({
      'PORT' => '3030',
      'LOG_LEVEL' => 'debug'
    })
    .build

command_line.string
# => "PORT=\"3030\" LOG_LEVEL=\"debug\" node ./server.js"
command_line.array
# => ["node", "./server.js"]
command_line.env
# => {"PORT"=>"3030", "LOG_LEVEL"=>"debug"}
```

or as an array:

```ruby
command_line = Lino.builder_for_command('node')
    .with_environment_variables(
      [
        { name: 'PORT', value: '3030' },
        { name: 'LOG_LEVEL', value: 'debug' }
      ]
    )
    .build

command_line.string
# => "PORT=\"3030\" LOG_LEVEL=\"debug\" node ./server.js"
command_line.array
# => ["node", "./server.js"]
command_line.env
# => {"PORT"=>"3030", "LOG_LEVEL"=>"debug"}
```

#### Option Placement

By default, `lino` places top-level options after the command, before all 
subcommands and arguments.

This is equivalent to calling `#with_options_after_command`:

```ruby
command_line = Lino.builder_for_command('gcloud')
    .with_options_after_command
    .with_option('--password', 'super-secure')
    .with_subcommands(%w[sql instances set-root-password])
    .build

command_line.array
# => 
# ["gcloud", 
#  "--password", 
#  "super-secure", 
#  "sql", 
#  "instances", 
#  "set-root-password"]
command_line.string
# => gcloud --password super-secure sql instances set-root-password
```

Alternatively, top-level options can be placed after all subcommands using
`#with_options_after_subcommands`:

```ruby
command_line = Lino.builder_for_command('gcloud')
    .with_options_after_subcommands
    .with_option('--password', 'super-secure')
    .with_subcommands(%w[sql instances set-root-password])
    .build

command_line.array
# => 
# ["gcloud",  
#  "sql", 
#  "instances", 
#  "set-root-password",
#  "--password", 
#  "super-secure"]
command_line.string
# => gcloud sql instances set-root-password --password super-secure
```

or, after all arguments, using `#with_options_after_arguments`:

```ruby
command_line = Lino.builder_for_command('ls')
    .with_options_after_arguments
    .with_flag('-l')
    .with_argument('/some/directory')
    .build

command_line.array
# => ["ls", "/some/directory", "-l"]
command_line.string
# => "ls /some/directory -l"
```

The option placement can be overridden on an option by option basis:

```ruby
command_line = Lino.builder_for_command('gcloud')
    .with_options_after_subcommands
    .with_option('--log-level', 'debug', placement: :after_command)
    .with_option('--password', 'pass1')
    .with_subcommands(%w[sql instances set-root-password])
    .build

command_line.array
# => 
# ["gcloud", 
#  "--log-level", 
#  "debug", 
#  "sql", 
#  "instances", 
#  "set-root-password",
#  "--password",
#  "pass1"]
command_line.string
# => "gcloud --log-level debug sql instances set-root-password --password pass1"
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
command_line = Lino.builder_for_command('gpg')
    .with_appliable(AppliableOption.new('--recipient', 'tobyclemson@gmail.com'))
    .with_flag('--sign')
    .with_argument('/some/file.txt')
    .build

command_line.array
# => ["gpg", "--recipient", "tobyclemson@gmail.com", "--sign", "/some/file.txt"]
command_line.string
# => "gpg --recipient tobyclemson@gmail.com --sign /some/file.txt" 
```

or multiple with `#with_appliables`:

```ruby
command_line = Lino.builder_for_command('gpg')
    .with_appliables([
      AppliableOption.new('--recipient', 'user@example.com'),
      AppliableOption.new('--output', '/signed.txt')
    ])
    .with_flag('--sign')
    .with_argument('/file.txt')
    .build

command_line.array
# => 
# ["gpg", 
#  "--recipient", 
#  "tobyclemson@gmail.com",
#  "--output", 
#  "/signed.txt",
#  "--sign", 
#  "/some/file.txt"]
command_line.string
# => "gpg --recipient user@example.com --output /signed.txt --sign /file.txt" 
```

> Note: an 'appliable' is any object that has an `#apply` method.

> Note: `lino` ignores `nil` or empty appliables in the resulting command line.

#### Working Directory

By default, when a command line is executed, the working directory of the parent
process is used. This can be overridden with `#with_working_directory`:

```ruby
command_line = Lino.builder_for_command('ls')
                   .with_flag('-l')
                   .with_working_directory('/home/tobyclemson')
                   .build

command_line.working_directory
# => "/home/tobyclemson"
```

All built in executors honour the provided working directory, setting it on
spawned processes.

### Executing command lines

`Lino::Model::CommandLine` instances can be executed after construction. They
utilise an executor to achieve this, which is any object that has an
`#execute(command_line, opts)` method. `Lino` provides default executors such
that a custom executor only needs to be provided in special cases.

#### `#execute`

A `Lino::Model::CommandLine` instance can be executed using the `#execute` 
method:

```ruby
command_line = Lino.builder_for_command('ls')
    .with_flag('-l')
    .with_flag('-a')
    .with_argument('/')
    .build
    
command_line.execute
# => <contents of / directory> 
```

#### Standard Streams

By default, all streams are inherited from the parent process.

To populate standard input:

```ruby
require 'stringio'

command_line.execute(
  stdin: StringIO.new('something to be passed to standard input')
)
```

The `stdin` option supports any object that responds to `read`.

To provide custom streams for standard output or standard error:

```ruby
require 'tempfile'
  
stdout = Tempfile.new
stderr = Tempfile.new
  
command_line.execute(stdout: stdout, stderr: stderr)

stdout.rewind
stderr.rewind
  
puts "[output: #{stdout.read}, error: #{stderr.read}]"
```

The `stdout` and `stderr` options support any instance of `IO` or a subclass.

#### Executors

`Lino` includes three built-in executors:

* `Lino::Executors::Childprocess` which is based on the
  [`childprocess` gem](https://github.com/enkessler/childprocess)
* `Lino::Executors::Open4` which is based on the
  [`open4` gem](https://github.com/ahoward/open4)
* `Lino::Executors::Mock` which does not start real processes and is useful for
  use in tests.

##### Configuration

By default, an instance of `Lino::Executors::Childprocess` is used. This is
controlled by the default executor configured on `Lino`:

```ruby
Lino.configuration.executor
# => #<Lino::Executors::Childprocess:0x0000000103007108>

executor = Lino::Executors::Mock.new

Lino.configure do |config|
  config.executor = executor
end

Lino.configuration.executor
# =>
# #<Lino::Executors::Mock:0x0000000106d4d3c8   
#  @executions=[],
#  @exit_code=0,
#  @stderr_contents=nil,
#  @stdout_contents=nil>

Lino.reset!

Lino.configuration.executor
# => #<Lino::Executors::Childprocess:0x00000001090fcb48>
```

##### Builder overrides

Any built command will inherit the executor set as default at build time. 

To override the executor on the builder, use `#with_executor`:

```ruby
executor = Lino::Executors::Mock.new
command_line = Lino.builder_for_command('ls')
    .with_executor(executor)
    .build

command_line.executor
# =>
# #<Lino::Executors::Mock:0x0000000108e7d890   
#  @executions=[],
#  @exit_code=0,
#  @stderr_contents=nil,
#  @stdout_contents=nil>
```

##### Mock executor

The `Lino::Executors::Mock` captures executions without spawning any real
processes:

```ruby
executor = Lino::Executors::Mock.new
command_line = Lino.builder_for_command('ls')
    .with_executor(executor)
    .build

command_line.execute

executor.executions.length
# => 1

execution = executor.executions.first
execution.command_line == command_line
# => true
execution.exit_code
# => 0
```

The mock can be configured to write to any provided `stdout` or `stderr`:

```ruby
require 'tempfile'

executor = Lino::Executors::Mock.new
executor.write_to_stdout('hello!')
executor.write_to_stderr('error!')

command_line = Lino.builder_for_command('ls')
    .with_executor(executor)
    .build

stdout = Tempfile.new
stderr = Tempfile.new

command_line.execute(stdout:, stderr:)

stdout.rewind
stderr.rewind

stdout.read == 'hello!'
# => true
stderr.read == 'error!'
# => true
```

The mock also captures any provided `stdin`:

```ruby
require 'stringio'

executor = Lino::Executors::Mock.new
command_line = Lino.builder_for_command('ls')
                   .with_executor(executor)
                   .build

stdin = StringIO.new("input\n")

command_line.execute(stdin:)

execution = executor.executions.first
execution.stdin_contents
# => "input\n"
```

The mock can be configured to fail all executions:

```ruby
executor = Lino::Executors::Mock.new
executor.fail_all_executions

command_line = Lino.builder_for_command('ls')
                   .with_executor(executor)
                   .build

command_line.execute
# ...in `execute': Failed while executing command line. 
# (Lino::Errors::ExecutionError)

command_line.execute
# ...in `execute': Failed while executing command line. 
# (Lino::Errors::ExecutionError)
```

The exit code, which defaults to zero, can also be set explicitly, with anything
other than zero causing a `Lino::Errors::ExecutionError` to be raised:

```ruby
executor = Lino::Executors::Mock.new
executor.exit_code = 128

command_line = Lino.builder_for_command('ls')
                   .with_executor(executor)
                   .build

begin
  command_line.execute
rescue Lino::Errors::ExecutionError => e
  e.exit_code
end
# => 128
```

The mock is stateful and accumulates executions and configurations. To reset the
mock to its initial state:

```ruby
executor = Lino::Executors::Mock.new
executor.exit_code = 128
executor.write_to_stdout('hello!')
executor.write_to_stderr('error!')

executor.reset

executor.exit_code
# => 0
executor.stdout_contents
# => nil
executor.stderr_contents
# => nil
```

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
