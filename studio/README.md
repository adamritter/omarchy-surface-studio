# Surface Studio components

`Controller.qml` owns live/saved settings and migrates older shared palettes into separate bar and panel profiles. `Widget.qml` is the English appearance editor. The bundled bar owns one controller and creates one editor per display, with a single IPC entry routed to the focused display.

`GradientSurface.qml` exposes shader uniforms through QML bindings. The fragment source and compiled `.qsb` ship together; rebuild with the root build script. `SurfaceShadow.qml` draws ambient/contact shadows outside the fill. `ControlMaterial.qml` reuses panel lighting on supported buttons, with independent idle/selected/hover colors.

`SurfaceAttachment.qml` adapts common popup cards and controls while open. This depends on Omarchy internals and is not an upstream appearance API. `MaterialCompositor.qml` toggles runtime Hyprland blur rules. No desktop refraction is performed.

Appearance IPC target: `surface-studio`; methods: `status`, `preview(key, JSON value)`, `save`, `revert`. Editor IPC target: `io.github.adamritter.surface-studio`; methods: `open`, `close`.

## Experimental analytic ray glass

`rayGlass` enables a bounded fragment-shader optical approximation with a beveled entrance normal, a planar rear interface and procedural environment planes. It computes refraction at both interfaces, Schlick Fresnel reflection and distance-based absorption, with a single bounded fallback for total internal reflection. The front normal is an analytic approximation, not an intersection with a complete 3D mesh. Roughness broadens the virtual light and reduces background variation; it is not stochastic microfacet sampling.

`glassIor` (1–1.8), `glassThickness` (0.5–12 logical pixels) and `glassMix` (0–1) are independently configurable for bar and panel profiles. Existing profiles default to disabled. Effects must also be enabled. This uses neither hardware RT acceleration nor live desktop capture; there is no global illumination or full path tracing. The virtual backdrop uses the configured corner colors. Text and icons remain separate QML content.

The shader builds for the configured GLSL, HLSL and MSL targets and was visually checked with live bar/panel toggles. GPU frame-time and power costs have not yet been benchmarked.
