# Access the GPU directly with GFX.GPU

`GFX.GPU` directly exposes devices, resources, pipelines, commands, compute,
offscreen rendering, and presentation. SDL_GPU handles and native structures
remain private.

[Lire cette documentation en français.](../FR/README.md)

## Install the package

```text
silex install GFX.GPU
```

GFX.GPU requires Silex 0.39.0 or newer.

## Create a device and resource

```sx
use GFX.GPU

func main() {
    var device = GPU.Device(GPU.DeviceSettings(debug:true))
    var buffer = device.buffer(GPU.BufferSettings(
        size:256,
        usage:GPU.BufferUsage.vertex(),
    ))
}
```

A device does not need a window for compute, transfers, or offscreen rendering.
Presentation composes explicitly with `GFX.Window`.

## Provide shader programs

A pipeline can receive HLSL from a file or source string:

```sx
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

This fragment assumes a context that later uses these programs. Silex compiles
them for the target; GFX.GPU does not impose scene shaders.

For multisampled output, `CommandBuffer.render_resolved(...)` records a pass
into a multisampled color texture and resolves it into the active surface.
`Device.reset_command_stats()` opens a measurement period and
`Device.command_stats()` returns an immutable `GPU.CommandStatistics` snapshot.

## Choose Application or direct integration

`GPU.Plugin` installs a surface and the presentation lifecycle into
`GFX.Application`. It also installs `Window.Plugin` with its defaults when the
application has not provided a configured window. Either plugin may be added
first.

The package contributes `Plugins.GPU`, `Plugins.GPU.Settings`,
`Resources.Device`, and `Resources.GPUSurface` to GFX's open catalogs. SDL3 and
native handles remain private infrastructure supplied by the GFX core.

Use the [Application example](https://github.com/Matanek/Silex-Examples/tree/main/Sources/ApplicationGPUTriangle)
to delegate startup, rendering, events, and shutdown. Use the
[direct example](https://github.com/Matanek/Silex-Examples/tree/main/Sources/DirectGPUTriangle)
to own the window, input, device, surface, pipeline, and loop explicitly. Both
paths use the same public GPU API.
