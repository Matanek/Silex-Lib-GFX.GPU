# Changelog

## [Unreleased]

- `CommandBuffer.present` presents a resolved 2D texture without exposing the
  swapchain. Texture render passes now report their physical size, including
  mip selection. `Device.texture` and `CommandBuffer.submit` allow native errors
  to be captured with `try`, preserving ordinary call behavior.

- `Device.read_texture` submits a bounded deferred read of resolved RGBA8/BGRA8
  2D textures. `GPU.Readback` provides readiness, owned RGBA8 pixels, cancellation
  and recoverable errors without waiting for GPU completion during collection.
