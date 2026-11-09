# Historique des changements

## [0.5.0] - 2026-11-09

- `CommandBuffer.present` présente une texture 2D résolue sans exposer la swapchain.
  Les passes vers une texture renseignent désormais leur taille physique, mip
  compris. `Device.texture` et `CommandBuffer.submit` permettent de capturer
  leurs erreurs natives avec `try`, sans changer les appels ordinaires.

- `Device.read_texture` programme une lecture différée bornée des textures 2D
  RGBA8/BGRA8 résolues. `GPU.Readback` expose disponibilité, pixels RGBA8 possédés,
  annulation et erreurs récupérables sans attente GPU lors de la collecte.
