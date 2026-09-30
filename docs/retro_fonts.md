# Retro font candidates

Candidates for the look of `bdg_retro_menu`. The licenses below are from memory, so verify each one before bundling a font in a published addon.

| Font | Look | License (verify) |
|---|---|---|
| Press Start 2P | The classic 8-bit arcade look, based on Namco-style glyphs | SIL OFL |
| Silkscreen | Small and clean, with an all-caps feel | SIL OFL |
| VT323 | Terminal style, with a home-computer or CRT feel | SIL OFL |
| Pixelify Sans | Modern and readable, with more weights | SIL OFL |
| Kenney fonts (Kenney Pixel, Kenney Mini) | Simple pixel fonts | CC0 |
| Print Char 21 / PR Number 3 (Kreative Software) | Apple II text screen. Print Char 21 is the wide 40-column look, PR Number 3 the narrow 80-column look | Kreative Software Relay Fonts Free Use License 1.2f (not OSI-approved, see below) |

Also popular in game jams: m5x7 and m6x11 by Daniel Linssen. Their exact terms are unchecked.

## Using pixel fonts in Godot

- Use an integer multiple of the font's design size. Press Start 2P is designed at 8px, so use 8, 16 or 24. Other sizes blur.
- On the font's import settings, turn off antialiasing, set hinting to none, and turn off subpixel positioning.
- Set the menu's `texture_filter` to Nearest so it isn't smoothed when scaled.
- Set the font under the `RetroMenu` theme type (`font` and `font_size`).

## Kreative Apple II fonts: license terms

Downloaded from <https://www.kreativekorp.com/software/fonts/apple2/> (`pr.zip`); the license file inside the zip is `demo/fonts/LICENSE-Kreative-PrintChar21-PRNumber3.txt`. In summary (read the file for the exact terms):

- Allowed: use, display, embed and redistribute the fonts.
- You may give copies away free of charge if the license and documentation are included verbatim and credit is given to Kreative Korporation / Kreative Software.
- You may not sell copies of the fonts, and may not modify them or make derivative works.
- Kreative may change the license at any time without notice.

This is not an open-source license. The fonts are kept in `demo/fonts/` only and are not bundled inside `addons/`, so users of the addon do not receive them. Check the current terms again before shipping them in a released game or on the Asset Library.

Measured in Godot 4.7.2: at 16px, Print Char 21 advances 14px per character and PR Number 3 advances 7px, so PR Number 3 is exactly half as wide. At 8px, PR Number 3 advances 3.5px, so use sizes that are multiples of 16 to keep glyphs on whole pixels. The demo uses 16.

## Shipping

If the addon bundles a font, ship the license file next to it. Only OFL and CC0 fonts are suitable for redistribution.
