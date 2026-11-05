# Historique des changements

## [Unreleased]

- `Device.read_texture` programme une lecture différée bornée des textures 2D
  RGBA8/BGRA8 résolues. `GPU.Readback` expose disponibilité, pixels RGBA8 possédés,
  annulation et erreurs récupérables sans attente GPU lors de la collecte.
