# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com)
and this project adheres to 
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [Unreleased]

## [2.0.0] — 2021-04-04

### Changed

* Renamed `switches` to `options` internally. As long as you are using the 
  library as documented, this is not a breaking change. However, since the named
  parameters passed to the constructors of `CommandLineBuilder` and 
  `SubcommandBuilder` effectively form part of the interface, if you are using 
  the constructors directly you'll need to rename the parameter.
