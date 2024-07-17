# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com)
and this project adheres to 
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.0.0] - 2024-07-17

### Fixed

* Subcommand options were not honouring the global option separator and quoting
  which was a regression introduced during the preparation of version 4. This
  has now been resolved and additional test coverage has been introduced.

## [4.0.0] - 2024-07-14

### Added

* A richer model for command lines has been introduced within the `Lino::Model`
  module simplifying the construction of command line strings and adding support
  for the construction of command line arrays, avoiding the challenges of
  quoting arguments and reducing the risk of including user provided values in
  command executions.
* A new `with_executor` method has been added to the command line builder, 
  allowing the executor used to execute the command line to be overridden. An
  `Executor` is any object with an `#execute(command_line, opts)` method, with
  the provided opts being user defined but typically including `stdin` 
  (any object that supports `#read`), `stdout` and `stderr` (instances of `IO`).
* A new `childprocess` based executor, `Lino::Executors::Childprocess` has been 
  added and is now the default when building command lines. This brings
  benefits such as inheritance of standard streams and support for Windows. This
  executor uses the command line array and as such, ignores quoting.
* The previous `open4` based executor implementation has been encapsulated in
  `Lino::Executors::Open4` such that the previous behaviour can be recovered by
  providing an instance of that executor at command line build time. This
  executor now uses the command line array and as such, ignores quoting.
* A mock executor, `Lino::Executors::Mock` has been added which allows capturing
  executions of command lines without any real processes being spawned for the
  purposes of testing or dry runs.
* A new `Lino.configure` method has been added taking a block which receives
  a configuration object, allowing the default executor to be set using, for 
  example, `Lino.configure { |c| c.executor = Lino::Executors::Open4.new }`.
* Executors are expected to throw `Lino::Errors::ExecutionError` errors in the
  case that command line execution fails. This error includes the string 
  representation of the command line, the exit code of the process and the
  underlying error if any.
* A new `with_working_directory` method has been added to the command line 
  builder allowing the working directory for the command line to be provided at
  construction time. The `Childprocess` and `Open4` executors both respect this
  and set the working directory on any spawned processes.
* A new factory function `Lino.builder_for_command` has been introduced as the
  starting point of the fluent interface for building command lines.

### Changed

* The minimum supported Ruby version is now 3.1
* The `Lino::CommandLineBuilder`, `Lino::SubcommandBuilder` and 
  `Lino::CommandLine` classes have all been moved into submodules as 
  `Lino::Builders::CommandLine`, `Lino::Builders::Subcommand` and 
  `Lino::Model::CommandLine` respectively. However, for backwards compatibility,
  the entrypoint remains as `Lino::CommandLineBuilder.for_command(...)`.
* Since the default executor is based on `childprocess` rather than `open4`, it
  is no longer possible to pass `StringIO` instances for `stdout` or `stderr` 
  when using the default executor. Instead, either a `Tempfile` should be used,
  which should subsequently have `#rewind` and `#read` called on it, or a pipe
  should be created using `IO.pipe` and managed in userland. See the 
  [`childprocess documentation`](https://github.com/enkessler/childprocess)
  documentation for more details on managing pipes. To retain the previous 
  behaviour allowing `StringIO`, switch to the `open4` executor.
* Previously, when command line execution failed, an `Open4::SpawnError` was
  thrown, including the full command printed as part of the error's `#to_s`
  method. This posed a security risk as any sensitive command line parameters
  would be printed in logging. Now, a `Lino::Errors::ExecutionError` is thrown
  which includes the command line, exit code and underlying cause as attributes
  but does not print these in the result of a call to `#to_s`. 

## [3.1.0] - 2022-12-24

### Changed

* The minimum supported Ruby version is now 2.7.
* All dependencies have been updated.

## [3.0.0] - 2021-05-10

### Changed

* All `with*` methods now retain empty string values as sometimes these are
  intentional, e.g., to indicate no password should be set. 

## [2.7.0] - 2021-05-01

### Added

* `#with_option`, `#with_options` and `#with_repeated_option` all now accept a
  `:placement` keyword argument allowing option placement to be overridden on an
  option by option basis.

## [2.5.0] - 2021-04-14

### Added

* `#with_subcommand` and `#with_subcommands` now ignores `nil` or empty
  arguments.

## [2.3.0] - 2021-04-05

### Added

* Versions of `#with_flag`, `#with_option`, `#with_environment_variable` that
  accept multiple of each type, namely `#with_flags`, `#with_options` and 
  `#with_environment_variables` respectively.
* Support for 'appliables', any object that has an `#apply` method, taking the
  builder as an argument and returning an updated builder, allowing operations
  to be encapsulated inside instances of some class.

## [2.0.0] — 2021-04-04

### Changed

* Renamed `switches` to `options` internally. As long as you are using the 
  library as documented, this is not a breaking change. However, since the named
  parameters passed to the constructors of `CommandLineBuilder` and 
  `SubcommandBuilder` effectively form part of the interface, if you are using 
  the constructors directly you'll need to rename the parameter.
