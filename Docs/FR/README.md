# Accéder directement au GPU avec GFX.GPU

`GFX.GPU` expose directement les devices, ressources, pipelines, commandes,
calculs, rendus hors écran et présentation. Les handles SDL_GPU et structures
natives restent privés.

[Read this documentation in English.](../EN/README.md)

## Installer le package

```text
silex install GFX.GPU
```

GFX.GPU demande Silex 0.39.0 ou une version plus récente.

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

## Fournir les programmes de shaders

Un pipeline peut recevoir du HLSL depuis un fichier ou depuis une chaîne :

```sx
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

Ce fragment suppose un contexte qui utilise ensuite ces programmes. Silex les
compile pour la cible ; GFX.GPU n’impose aucun shader de scène.

Pour une sortie multisamplée, `CommandBuffer.render_resolved(...)` enregistre
une passe vers une texture couleur multisamplée puis la résout dans la surface
active. `Device.reset_command_stats()` ouvre une période de mesure et
`Device.command_stats()` retourne un instantané immuable
`GPU.CommandStatistics`.

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
