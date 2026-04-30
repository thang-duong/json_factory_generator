## 1.1.0 - 2026-04-30

 - **FEAT**: add melos release workspace and bump package versions. ([75f9e796](https://github.com/thang-duong/json_factory_generator/commit/75f9e796aabfb6f7a1851c18b883f04d2f7da476))
 - **FEAT**: introduce standalone CLI generation mode and executable alias for json_factory_generator. ([09211542](https://github.com/thang-duong/json_factory_generator/commit/092115421895f7a12a9df8fa2be162366b07081b))

## 1.0.3 - 2026-04-30

### Changed

- Updated workspace compatibility (`resolution: workspace`) for Melos-based release flow.
- Updated lint configuration to align with workspace toolchain.

## 1.0.2 - 2025-08-28

### Changed

- Updated BaseResponse usage examples with clearer examples
- Enhanced documentation clarity for type-safe JSON parsing
- Improved code examples in README

## 1.0.1 - 2025-08-25

### Changed
- Enhanced README with clearer usage examples
- Added detailed explanation of @JsonModel annotation
- Improved documentation structure and formatting
- Added examples for json_serializable integration
- Added code examples with proper syntax highlighting

## 1.0.0 - 2025-08-25

First stable release with production-ready features.

### Added
- Stable public API for JSON serialization annotations
- Complete documentation with usage examples
- Comprehensive test coverage
- Type-safe serialization support
- Generic type support
- Integration with json_factory_generator

### Changed
- Improved annotation definitions
- Enhanced type safety
- Updated meta package dependency

### Migration
- No breaking changes from 0.1.x
- All existing annotations will continue to work as expected

## 0.1.1 - 2025-08-20

### Added
- Support for generic API responses
- Support for complex object graphs
- Improved documentation and examples

### Changed
- Enhanced type safety features
- Better integration with json_factory_generator

## 0.1.0 - 2025-08-10

### Added
- Initial release with basic annotation support
- `@JsonModel` annotation for marking classes for JSON factory generation
- Basic documentation
- Core functionality for JSON serialization
