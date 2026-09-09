# Access the GPU directly with GFX.GPU

`GFX.GPU` directly exposes devices, resources, pipelines, commands, compute,
offscreen rendering, and presentation. SDL_GPU handles and native structures
remain private.

[Lire cette documentation en français.](../FR/README.md)

## Install the package

```text
silex install GFX.GPU
```

GFX.GPU requires Silex 0.44.0 or newer.

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

## Transfer typed numeric values

An upload `GPU.TransferBuffer` can write Silex slices directly with
`write_floats`, `write_int8s`, `write_uint8s`, `write_int16s`,
`write_uint16s`, `write_int32s`, `write_uint32s`, `write_int64s`, and
`write_uint64s`. Download buffers expose the corresponding `read_*` methods.
Offsets and counts are expressed in elements of the named type, never bytes:

```sx
var values:int32[] = [101 as int32, 2023 as int32]
var upload = device.upload_buffer(values.count() * 4)
upload.write_int32s(@values[0:values.count()])
```

These methods preserve the values' bit representation and do not construct an
intermediate byte array. Writes require an upload buffer and reads require a
download buffer. For reads, `count:-1` means “through the last complete
element”; any trailing bytes shorter than one element are ignored.

## Provide shader programs

A pipeline can receive HLSL from a file or source string:

```sx
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

This fragment assumes a context that later uses these programs. Silex compiles
them for the target; GFX.GPU does not impose scene shaders.

`ShaderProgram.layout()` returns an immutable snapshot of the entry points and
the reflected sampler, storage texture, storage buffer, and constant-buffer
counts for each stage. A specialized API can therefore validate its resource
contract before pipeline creation without accessing compiled code or a native
handle.
`same_program(other)` additionally lets a renderer share pipelines between
equivalent values without publishing their compiled payload.

For multisampled output, `CommandBuffer.render_resolved(...)` records a pass
into a multisampled color texture and resolves it into the active surface.
`Device.reset_command_stats()` opens a measurement period and
`Device.command_stats()` returns an immutable `GPU.CommandStatistics` snapshot.
The snapshot includes uploads, downloads, compute passes, and uniform bytes so
a specialized layer can prove that a chain stays on the GPU until its explicit
readback.

`CommandBuffer.compute_uniform(slot, value)` directly accepts a `float32`
scalar in addition to the general byte view. Devices, resources, pipelines,
commands, passes, and fences are `nocopy` classes: ordinary assignment
shares their identity, while `copy` is rejected so a native handle and its
cleanup are never duplicated.

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
