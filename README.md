# Surface Studio Bar

A replacement Omarchy bar with Surface Studio built in. One plugin installs both the bar and its appearance editor. No upstream patch or separate `adam.bar` / `adam.surface-studio` installation is required.

## Install

```bash
omarchy plugin add https://github.com/adamritter/omarchy-surface-studio --enable
```

Enabling selects this bar while preserving the configured widgets and their settings. The ◈ Surface Studio button appears automatically on the right (or in the position of an existing editor). The plugin does not install or modify your network, tray, clock, or other widgets.

For a local checkout, run `python3 install.py`. The installer makes a backup, preserves the previous bar selection, and activates the bundle. `python3 install.py --uninstall` restores the previous bar selection while preserving other later configuration changes. A running shell is required for activation. It restarts the shell to refresh cached QML components and restores the current appearance preview without saving it.

## Use

Open ◈. The editor and status messages are in English:

- **General**: enabled surfaces and bar transparency.
- **Colors**: four-corner, linear or radial gradients, graphical color picker and hex values.
- **Border**: border width, colors and panel rounding.
- **Effects**: material, light, shadow and controls. **Controls → Custom button colors** sets idle, selected and hover colors.
- **Save** saves; **Revert** restores the saved appearance.

Bar and panel profiles are separate. Changes preview immediately; closing the editor keeps the preview, while restarting discards unsaved edits. Settings are stored at `~/.config/omarchy/surface-studio.json`, so an existing Surface Studio setup is reused. The file and its contents are not bundled.

## Scope and compatibility

Tested with the user's Omarchy Quattro development shell based on `fed2d225`, Qt 6.11 and Quickshell. This is an experimental full-bar plugin, not a claim of compatibility with every Omarchy release. See UPSTREAM.md for provenance and maintenance boundaries.

Panel styling adapts common Omarchy popup, Button, CursorSurface and PanelActionButton components. Custom plugin controls may retain their own style. It does not style ordinary application windows. Native popup windows clip external shadows; full-screen KeyboardPanel surfaces can draw them.

Backdrop blur uses runtime Hyprland layer rules and may enable the shared blur engine. Actual desktop refraction is not implemented. Disabling effects restores the original blur baseline; reload Hyprland after removing the plugin if runtime blur overrides were active. Shader lighting itself is local to QML. Binary bar transparency still hides the bar fill and shadow.

## Development

GLSL sources and their compiled Qt shader packages are included. Run `./build-shaders.sh` after shader changes. Run `python3 -m unittest discover -s tests` for installation/configuration tests. The installer never edits the packaged Omarchy source.

MIT licensed; includes Omarchy bar code (see LICENSE and UPSTREAM.md).
