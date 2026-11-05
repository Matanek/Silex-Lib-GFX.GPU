# Accéder directement au GPU avec GFX.GPU

`GFX.GPU` expose directement les devices, ressources, pipelines, commandes,
calculs, rendus hors écran et présentation. Les handles SDL_GPU et structures
natives restent privés.

[Read this documentation in English.](../EN/README.md)

## Installer le package

```text
silex install GFX.GPU
```

GFX.GPU demande Silex 0.44.0 ou une version plus récente.

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

## Récupérer les pixels d’une texture

Après soumission du rendu ou de l’upload d’une texture, `device.read_texture(texture)`
programme une lecture GPU différée. Le ticket `GPU.Readback` conserve le device,
la source et le transfert. Il ne bloque pas en attendant le GPU. Dans une boucle
existante, ce fragment demande la lecture, puis collecte le résultat dans une
itération ultérieure où `is_ready()` vaut `true` :

```sx
var readback = device.read_texture(texture)
// Continue rendering and handling input before collecting the result.
if readback.is_ready() {
    let pixels = readback.read()
    assert(pixels.count() == readback.width() * readback.height() * 4)
}
```

Les octets possédés sont RGBA8, de gauche à droite et de haut en bas. Les formats
`rgba8_unorm`, `bgra8_unorm`, `rgba8_srgb` et `bgra8_srgb` sont acceptés ; BGRA
est réordonné, les octets sRGB restent encodés et l’alpha reste inchangé.
La source doit être une texture 2D mono-couche et mono-échantillon ; résoudre le
MSAA au préalable. La swapchain n’est pas une texture persistante récupérable par
cette API. Cette primitive ne capture pas encore le rendu final d’Application.

`try device.read_texture(texture)` et `try readback.read()` permettent de traiter
les erreurs. Une lecture prématurée échoue sans consommer le transfert. Une
lecture réussie le consomme ; les octets restent valides après les frames suivantes.
`cancel()` ou la destruction abandonnent la lecture sans attendre sa fence ;
SDL conserve les allocations natives aussi longtemps que leurs utilisateurs GPU.
La destruction du dernier device peut néanmoins attendre ses travaux restants.

`maximum_bytes` borne le transfert, rangées alignées à 256 octets comprises :
64 Mio par défaut, de 1 à 256 Mio au maximum. Chaque ticket possède son transfert ;
l’appelant borne leur nombre. Mapping, copie CPU et réordonnancement se font lors
de `read()` sur le thread appelant, une fois la fence prête. Cette opération a un
coût proportionnel au nombre de pixels ; elle n’est pas une promesse de lecture
CPU sans coût. Utiliser un ticket depuis un seul thread à la fois et soumettre
les écritures et lectures du device dans l’ordre attendu.

Le [consommateur exécutable](../../Tests/Consumer/Tests/Readback.sx) vérifie
les couleurs, l’orientation, la conservation des résultats et l’annulation.

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
pipelines, commandes, passes et fences sont des classes `nocopy` : une
affectation ordinaire partage leur identité, tandis que `copy` est refusé afin
de ne jamais dupliquer un handle natif et son nettoyage.

## Choisir l’intégration Application ou directe

Pour présenter une image rendue dans une texture persistante,
`commands.present(texture, surface)` enregistre son blit vers la fenêtre.
La texture doit être 2D, mono-couche, résolue et déclarée `sampled` ; soumettre
ensuite les commandes. `try commands.present(...)` rend `false` si la surface
est indisponible et conserve les erreurs d'acquisition. La cadence d'acquisition
reste celle de la présentation ordinaire. `RenderPass.size()` indique aussi
les dimensions physiques d'une cible texture, au niveau de mip sélectionné.

`try device.texture(settings)` et `try commands.submit()` permettent de traiter
les erreurs natives d'allocation et de soumission. Les erreurs de programmation
(paramètres de texture incohérents, passe active ou mauvais device) restent
soumises aux validations ordinaires du GPU.

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
