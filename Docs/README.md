# GFX.GPU

`GFX.GPU` directly exposes the device, resources, pipelines, commands, and
presentation. SDL_GPU handles and native structures remain private.

```silex
use GFX.GPU

var device = GPU.Device(GPU.DeviceSettings(debug:true))
var buffer = device.buffer(GPU.BufferSettings(
    size:256,
    usage:GPU.BufferUsage.vertex()
))
```

A user can provide custom HLSL from a file or source text:

```silex
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

Silex compiles these programs for the target; GFX does not impose scene
shaders. `GPU.Plugin` integrates a surface and the presentation lifecycle with
`Application`, while the direct API remains available without a plugin. The
plugin installs `Window.Plugin` with its defaults when the application does not
provide a configured window explicitly; either plugin may be added first.

For multisampled window output, `CommandBuffer.render_resolved(...)` records a
render pass into a multisampled color texture and resolves it into the active
surface. Command statistics remain an internal representation;
`Device.reset_command_stats()` starts a measurement period and
`Device.command_stats()` returns an immutable `GPU.CommandStatistics`
snapshot.

## Choosing the application or direct path

Use [TriangleApplication.sx](../Examples/TriangleApplication.sx) when you want
`Application` to schedule startup, rendering, shutdown, event handling, and
frame pacing. `Plugins.GPU` installs the default window integration and standard
resources itself; the example only retains its pipeline and records its draw
commands.

Use [TriangleDirect.sx](../Examples/TriangleDirect.sx) when you do not want an
`Application`. It constructs `Window`, `Input`, `GPU.Device`, `GPU.Surface`,
the graphics pipeline, and the event/render loop explicitly. This path uses the
same public GPU API and the same HLSL shader; plugins are an orchestration
choice, not a requirement for presentation.
