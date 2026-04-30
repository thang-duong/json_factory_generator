## 1.3.0 - 2026-04-30

### Changed

- Raised minimum Dart SDK constraint to `>=3.10.0 <4.0.0`.
- Updated dependency constraint to `json_factory_annotation: ^1.2.0`.
- Updated package README SDK and installation version examples.

## 1.2.0 - 2026-04-30

 - **FEAT**: add melos release workspace and bump package versions. ([75f9e796](https://github.com/thang-duong/json_factory_generator/commit/75f9e796aabfb6f7a1851c18b883f04d2f7da476))
 - **FEAT**: introduce standalone CLI generation mode and executable alias for json_factory_generator. ([09211542](https://github.com/thang-duong/json_factory_generator/commit/092115421895f7a12a9df8fa2be162366b07081b))
 - **DOCS**: update README and examples for BaseResponse usage and type safety. ([78d8337c](https://github.com/thang-duong/json_factory_generator/commit/78d8337cfbec3aa4a950f95be08ddd2998a1e86e))
 - **DOCS**: update BaseResponse usage examples. ([95da1632](https://github.com/thang-duong/json_factory_generator/commit/95da163234034bcc0f22d2ebd6f433433a4ef901))
 - **DOCS**: update CHANGELOG with enhancements to BaseResponse examples and documentation clarity. ([8ed30161](https://github.com/thang-duong/json_factory_generator/commit/8ed30161a5efab2361199354a87f877f9d0ed849))
 - **DOCS**: update README with examples for BaseResponse usage and type safety. ([f8e4ad46](https://github.com/thang-duong/json_factory_generator/commit/f8e4ad46c30768796c2ce6d1cff171a8d05957cf))

## 1.1.1 - 2026-04-30

### Added

- Standalone `generate` mode now reads `build.yaml` options when CLI params are omitted.
- Added Melos workspace support at repository root for release automation scripts.

### Changed

- Added `flutterjfg` short executable alias and updated CLI command docs.
- Default CLI behavior remains `build` with `--delete-conflicting-outputs`.

## 1.1.0 - 2026-04-30

### Added

- Added standalone CLI generation mode (`generate`) that can produce `json_factory.dart` without running full `build_runner` pipelines.
- Added executable alias `flutterjfg` for shorter commands.

### Changed

- Default CLI command now maps to `build` and runs `build_runner build --delete-conflicting-outputs`.
- Updated README with new CLI workflows, alias usage, and command examples.

## 1.0.2 - 2025-08-28

### Changed

- Updated BaseResponse usage examples with clearer examples for both single objects and lists
- Enhanced documentation clarity for type-safe JSON parsing
- Improved code examples in README

## 1.0.1+1 - 2025-08-25

### Changed

- Update doc and optimal Helper

## 1.0.0 - 2025-08-25

First stable release with production-ready features.

### Added
- Production-ready code generation implementation
- Robust error handling and reporting system
- Comprehensive documentation with examples
- Complete test coverage for all features
- Advanced support for complex object graphs
- Enhanced type discovery system
- Improved support for List<T> and generic types
- Refined BaseResponse<T> implementation
- Integration with latest Dart analyzer
- Performance optimizations

### Changed
- Enhanced build configuration
- Improved error messages
- Updated all dependencies to latest stable versions
- Refined code generation templates

### Migration
- No breaking changes from 0.1.x series
- All existing generated code will continue to work
- Improved backwards compatibility

## 0.1.6 - 0.1.7

* Added comprehensive BaseResponse<T> documentation with usage examples
* Enhanced README with BaseResponse generic API wrapper section
* Added detailed examples for handling API responses with type safety
* Improved documentation structure and clarity
* Updated examples to showcase BaseResponse benefits and use cases

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
