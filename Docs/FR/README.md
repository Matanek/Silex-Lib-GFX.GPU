# Accéder directement au GPU avec GFX.GPU

`GFX.GPU` expose directement les devices, ressources, pipelines, commandes,
calculs, rendus hors écran et présentation. Les handles SDL_GPU et structures
natives restent privés.

[Read this documentation in English.](../EN/README.md)

## Installer le package

```text
silex install GFX.GPU
```

GFX.GPU demande Silex 0.43.0 ou une version plus récente.

## Créer un device et une ressource

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

Un device n’a pas besoin de fenêtre pour le calcul, les transferts ou le rendu
hors écran. La présentation se compose explicitement avec `GFX.Window`.

## Transférer des valeurs numériques typées

Un `GPU.TransferBuffer` d’upload peut écrire directement des slices Silex avec
`write_floats`, `write_int8s`, `write_uint8s`, `write_int16s`,
`write_uint16s`, `write_int32s`, `write_uint32s`, `write_int64s` et
`write_uint64s`. Le buffer de download expose les méthodes `read_*`
correspondantes. Les offsets et les counts sont exprimés en éléments du type,
jamais en octets :

```sx
var values:int32[] = [101 as int32, 2023 as int32]
var upload = device.upload_buffer(values.count() * 4)
upload.write_int32s(@values[0:values.count()])
```

Ces méthodes préservent la représentation binaire des valeurs et ne créent pas
de tableau d’octets intermédiaire. Une écriture exige un buffer d’upload, une
lecture un buffer de download. Pour une lecture, `count:-1` signifie « jusqu’au
dernier élément entier disponible » ; un reliquat plus court qu’un élément est
ignoré.

## Fournir les programmes de shaders

Un pipeline peut recevoir du HLSL depuis un fichier ou depuis une chaîne :

```sx
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

Ce fragment suppose un contexte qui utilise ensuite ces programmes. Silex les
compile pour la cible ; GFX.GPU n’impose aucun shader de scène.

`ShaderProgram.layout()` fournit un instantané immuable des entry points et du
nombre de samplers, textures de stockage, buffers de stockage et constant
buffers réfléchis pour chaque stage. Une API spécialisée peut ainsi valider son
contrat de ressources avant de créer un pipeline, sans accéder au code compilé
ni à un handle natif.
`same_program(other)` permet en complément de mutualiser les pipelines de deux
valeurs équivalentes sans publier leur payload compilé.

Pour une sortie multisamplée, `CommandBuffer.render_resolved(...)` enregistre
une passe vers une texture couleur multisamplée puis la résout dans la surface
active. `Device.reset_command_stats()` ouvre une période de mesure et
`Device.command_stats()` retourne un instantané immuable
`GPU.CommandStatistics`. Cet instantané compte notamment les uploads,
downloads, passes compute et octets d'uniformes ; une couche spécialisée peut
ainsi prouver qu'une chaîne reste sur GPU jusqu'à son readback explicite.

`CommandBuffer.compute_uniform(slot, value)` accepte directement un scalaire
`float32` en plus de la vue d'octets générale. Les devices, ressources,
pipelines, commandes, passes et fences sont des classes `noncopyable` : une
affectation ordinaire partage leur identité, tandis que `copy` est refusé afin
de ne jamais dupliquer un handle natif et son nettoyage.

## Choisir l’intégration Application ou directe

`GPU.Plugin` installe une surface et le cycle de présentation dans
`GFX.Application`. Il installe aussi `Window.Plugin` avec ses valeurs par
défaut si l’application n’a pas fourni de fenêtre configurée. L’ordre d’ajout
des deux plugins est indifférent.

Le package contribue `Plugins.GPU`, `Plugins.GPU.Settings`,
`Resources.Device` et `Resources.GPUSurface` aux catalogues ouverts de GFX.
SDL3 et les handles natifs restent fournis comme infrastructure privée par le
noyau GFX.

Utilisez l’[exemple Application](https://github.com/Matanek/Silex-Examples/tree/main/Sources/ApplicationGPUTriangle)
pour déléguer le démarrage, le rendu, les événements et l’arrêt. Utilisez
l’[exemple direct](https://github.com/Matanek/Silex-Examples/tree/main/Sources/DirectGPUTriangle)
pour posséder explicitement la fenêtre, l’input, le device, la surface, le
pipeline et la boucle. Les deux parcours emploient la même API GPU publique.
