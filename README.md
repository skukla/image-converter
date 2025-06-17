# image-converter

A Ruby-based image conversion tool that supports multiple formats and provides enhanced error messages for missing dependencies.

## Dependencies

### Required Dependencies

The following packages are required and must be installed via Homebrew:

- **ImageMagick** (for general image conversion):
  ```bash
  brew install imagemagick
  ```

- **librsvg** (for SVG conversion with rsvg-convert):
  ```bash
  brew install librsvg
  ```

### Optional Dependencies

For enhanced SVG conversion quality (raster-to-vector tracing), consider installing:

- **potrace** (bitmap tracing utility):
  ```bash
  brew install potrace
  ```

- **autotrace** (alternative bitmap tracing utility):
  ```bash
  brew install autotrace
  ```

## Installation

To install Node.js dependencies:

```bash
bun install
```

## Usage

To run the image converter:

```bash
bun run main.rb
```

The application will automatically check for required dependencies and provide specific installation instructions if any are missing.

## Error Messages

The application now provides descriptive error messages with specific homebrew installation commands when dependencies are missing. For example:

```
❌ Error: The following required commands are not installed:
   • rsvg-convert (install with: brew install librsvg)
   • potrace (install with: brew install potrace)

Please install the missing packages and try again.
```

---

This project was created using `bun init` in bun v1.0.2. [Bun](https://bun.sh) is a fast all-in-one JavaScript runtime.
