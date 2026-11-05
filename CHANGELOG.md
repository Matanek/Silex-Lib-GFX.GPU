# Changelog

## [Unreleased]

- `Device.read_texture` submits a bounded deferred read of resolved RGBA8/BGRA8
  2D textures. `GPU.Readback` provides readiness, owned RGBA8 pixels, cancellation
  and recoverable errors without waiting for GPU completion during collection.
