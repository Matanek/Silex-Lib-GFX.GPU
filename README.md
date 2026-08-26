# GFX.GPU

`GFX.GPU` provides direct GPU devices, resources, pipelines, commands,
compute, offscreen rendering, and presentation to a `GFX.Window`.

```text
silex install GFX.GPU
```

```silex
use GFX.GPU

var device = GPU.Device(GPU.DeviceSettings(debug:true))
var buffer = device.buffer(GPU.BufferSettings(
    size:256,
    usage:GPU.BufferUsage.vertex()
))
```

A device does not require a window for compute, transfers, or offscreen
rendering. Presentation is composed explicitly with `GFX.Window`, while
`GPU.Plugin` installs the standard Window integration for an Application.

The package contributes `Plugins.GPU`, `Plugins.GPU.Settings`,
`Resources.Device`, and `Resources.GPUSurface` to GFX's open catalogs. SDL3
and native handles remain private infrastructure supplied by the GFX core.

## Examples

- [TriangleApplication.sx](Examples/TriangleApplication.sx) renders a triangle
  through `Application`, frame pacing, and `Plugins.GPU`; the GPU plugin
  installs the default window integration itself.
- [TriangleDirect.sx](Examples/TriangleDirect.sx) owns the window, input loop,
  GPU device, surface, pipeline, and commands directly, without `Application`
  or plugins.

From the Silex workspace root, run either path with:

```text
silex run Packages/GFX.GPU/Examples/TriangleApplication.sx
silex run Packages/GFX.GPU/Examples/TriangleDirect.sx
```

See [Docs/README.md](Docs/README.md) for direct usage, HLSL programs, and the
Application plugin.
