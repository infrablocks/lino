# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com)
and this project adheres to 
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0]

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
