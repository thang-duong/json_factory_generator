# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-04-30

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - `json_factory_annotation` `v1.2.0`
 - `json_factory_generator` `v1.3.0`

---

#### `json_factory_annotation` - `v1.2.0`

 - **CHANGED**: raise Dart SDK constraint to `>=3.10.0 <4.0.0` and refresh README version examples.

#### `json_factory_generator` - `v1.3.0`

 - **CHANGED**: raise Dart SDK constraint to `>=3.10.0 <4.0.0` and update `json_factory_annotation` dependency to `^1.2.0`.
 - **TEST**: align example error-message expectations with current generated `JsonFactory` runtime messages.

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`json_factory_annotation` - `v1.1.0`](#json_factory_annotation---v110)
 - [`json_factory_generator` - `v1.2.0`](#json_factory_generator---v120)

---

#### `json_factory_annotation` - `v1.1.0`

 - **FEAT**: add melos release workspace and bump package versions. ([75f9e796](https://github.com/thang-duong/json_factory_generator/commit/75f9e796aabfb6f7a1851c18b883f04d2f7da476))
 - **FEAT**: introduce standalone CLI generation mode and executable alias for json_factory_generator. ([09211542](https://github.com/thang-duong/json_factory_generator/commit/092115421895f7a12a9df8fa2be162366b07081b))

#### `json_factory_generator` - `v1.2.0`

 - **FEAT**: add melos release workspace and bump package versions. ([75f9e796](https://github.com/thang-duong/json_factory_generator/commit/75f9e796aabfb6f7a1851c18b883f04d2f7da476))
 - **FEAT**: introduce standalone CLI generation mode and executable alias for json_factory_generator. ([09211542](https://github.com/thang-duong/json_factory_generator/commit/092115421895f7a12a9df8fa2be162366b07081b))
 - **DOCS**: update README and examples for BaseResponse usage and type safety. ([78d8337c](https://github.com/thang-duong/json_factory_generator/commit/78d8337cfbec3aa4a950f95be08ddd2998a1e86e))
 - **DOCS**: update BaseResponse usage examples. ([95da1632](https://github.com/thang-duong/json_factory_generator/commit/95da163234034bcc0f22d2ebd6f433433a4ef901))
 - **DOCS**: update CHANGELOG with enhancements to BaseResponse examples and documentation clarity. ([8ed30161](https://github.com/thang-duong/json_factory_generator/commit/8ed30161a5efab2361199354a87f877f9d0ed849))
 - **DOCS**: update README with examples for BaseResponse usage and type safety. ([f8e4ad46](https://github.com/thang-duong/json_factory_generator/commit/f8e4ad46c30768796c2ce6d1cff171a8d05957cf))

## 1.1.1 - 2026-04-30

### Changed
- Added Melos workspace configuration and release scripts at repository root.
- Added standalone CLI generation improvements and alias/documentation updates.

## 1.1.0 - 2026-04-30

### Changed
- Added and documented a dedicated CLI flow for generator usage.
- Added `flutterjfg` executable alias for shorter commands.
- Updated command docs to clarify default CLI behavior and build_runner passthrough mode.

## 1.0.1 - 2025-08-25

### Changed
- Enhanced documentation in json_factory_annotation package
- Improved README files with better structure and examples
- Added detailed annotation usage explanations
- Fixed code formatting in documentation
- Added comprehensive examples for json_serializable integration

## 1.0.0 - 2025-08-25

First stable release of the project, including both json_factory_annotation and json_factory_generator packages.

### Added
- Production-ready implementation with stability guarantees
- Complete documentation for both packages
- Comprehensive test coverage
- Enhanced error handling and type safety
- Support for complex object graphs and generic types
- Refined BaseResponse<T> implementation
- Advanced code generation features

### Changed
- Updated all dependencies to latest stable versions
- Improved documentation structure
- Enhanced build configuration
- Better error messages and reporting

### Migration
- No breaking changes from 0.1.x series
- All existing code will continue to work as expected
- Improved backwards compatibility

## 0.1.7 - 2025-08-20

### Added
- Enhanced BaseResponse<T> implementation with better type safety
- Added unit tests for BaseResponse error handling
- Added API usage examples in README

### Changed
- Improved documentation and examples
- Fixed code formatting and documentation style

## 0.1.6 - 2025-08-15

### Added
- Comprehensive BaseResponse<T> documentation with usage examples
- Detailed examples for handling API responses with type safety

### Changed
- Enhanced README with BaseResponse generic API wrapper section
- Improved documentation structure and clarity
- Updated examples to showcase BaseResponse benefits and use cases

## 0.1.5

* Version bump and package improvements
* Maintenance release with updated dependencies and documentation

## 0.1.4

* Fixed package description length to comply with pub.dev guidelines (under 180 characters)
* Added missing `meta` dependency for enhanced code generation capabilities
* Improved package metadata and lint compliance
* Code quality improvements and better documentation

## 0.1.3

* Package maintenance and publishing improvements
* Updated documentation and examples
* Improved package metadata and description
* Enhanced code quality and consistency

## 0.1.2

* Lowered minimum Dart SDK requirement to 3.0.0 for broader compatibility
* Adjusted dependency versions to support wider range of Dart versions
* Improved compatibility with older Dart installations

## 0.1.1

* Fixed dependency version constraints for better compatibility
* Added platform support for all major platforms (Android, iOS, Linux, macOS, Web, Windows)
* Fixed example package publish configuration
* Improved static analysis score

## 0.1.0

* Initial release
* Auto-generate centralized JSON factories for Dart models
* Support for @jsonModel annotation
* Type-safe JSON parsing with support for both single objects and List<T>
* Automatic discovery of annotated classes
* Compatible with json_serializable and manual fromJson implementations
