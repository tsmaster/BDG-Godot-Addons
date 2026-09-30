# Retro font candidates

Candidates for the look of `bdg_retro_menu`. The licenses below are from memory, so verify each one before bundling a font in a published addon.

| Font | Look | License (verify) |
|---|---|---|
| Press Start 2P | The classic 8-bit arcade look, based on Namco-style glyphs | SIL OFL |
| Silkscreen | Small and clean, with an all-caps feel | SIL OFL |
| VT323 | Terminal style, with a home-computer or CRT feel | SIL OFL |
| Pixelify Sans | Modern and readable, with more weights | SIL OFL |
| Kenney fonts (Kenney Pixel, Kenney Mini) | Simple pixel fonts | CC0 |

Also popular in game jams: m5x7 and m6x11 by Daniel Linssen. Their exact terms are unchecked.

## Using pixel fonts in Godot

- Use an integer multiple of the font's design size. Press Start 2P is designed at 8px, so use 8, 16 or 24. Other sizes blur.
- On the font's import settings, turn off antialiasing, set hinting to none, and turn off subpixel positioning.
- Set the menu's `texture_filter` to Nearest so it isn't smoothed when scaled.
- Set the font under the `RetroMenu` theme type (`font` and `font_size`).

## Shipping

If the addon bundles a font, ship the license file next to it. Only OFL and CC0 fonts are suitable for redistribution.
