# Surface Studio components

`Controller.qml` owns live/saved settings and migrates older shared palettes into separate bar and panel profiles. `Widget.qml` is the English appearance editor. The bundled bar owns one controller and creates one editor per display, with a single IPC entry routed to the focused display.

`GradientSurface.qml` exposes shader uniforms through QML bindings. The fragment source and compiled `.qsb` ship together; rebuild with the root build script. `SurfaceShadow.qml` draws ambient/contact shadows outside the fill. `ControlMaterial.qml` reuses panel lighting on supported buttons, with independent idle/selected/hover colors.

`SurfaceAttachment.qml` adapts common popup cards and controls while open. This depends on Omarchy internals and is not an upstream appearance API. `MaterialCompositor.qml` toggles runtime Hyprland blur rules. No desktop refraction is performed.

Appearance IPC target: `surface-studio`; methods: `status`, `preview(key, JSON value)`, `save`, `revert`. Editor IPC target: `io.github.adamritter.surface-studio`; methods: `open`, `close`.
