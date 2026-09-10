import QtQuick
ShaderEffect {
 id: root
 property var settings: ({})
 property color c1: settings.c1 || "#24416b"
 property color c2: settings.c2 || "#493d68"
 property color c3: settings.c3 || "#193d49"
 property color c4: settings.c4 || "#292f50"
 property color baseColor: "#161c2b"
 property vector2d size: Qt.vector2d(width, height)
 property real mode: settings.mode || 0
 property real angle: (settings.angle || 0) * Math.PI / 180
 property real strength: settings.strength === undefined ? 0.55 : settings.strength
 property real alpha: settings.effectsEnabled ? (settings.surfaceOpacity === undefined ? 1 : settings.surfaceOpacity) : 1.0
 property real coherentLight: settings.coherentLight ? 1 : 0
 property real edgeTint: settings.edgeTint || 0
 property real edgeTintWidth: settings.edgeTintWidth === undefined ? 5 : settings.edgeTintWidth
 property real rayGlass: settings.rayGlass ? 1 : 0
 property real glassIor: settings.glassIor === undefined ? 1.45 : settings.glassIor
 property real glassThickness: settings.glassThickness === undefined ? 4 : settings.glassThickness
 property real glassMix: settings.glassMix === undefined ? 0.55 : settings.glassMix
 property real radius: 0
 property real grain: settings.grain === undefined ? 0.15 : settings.grain
 property real effects: settings.effectsEnabled ? 1 : 0
 property real lightAngle: (settings.lightAngle === undefined ? 225 : settings.lightAngle)*Math.PI/180
 property real bevelWidth: settings.bevelWidth === undefined ? 3 : settings.bevelWidth
 property real bevelStrength: settings.bevelStrength || 0
 property real rimStrength: settings.rimStrength || 0
 property real sheenStrength: settings.sheenStrength || 0
 property real innerShadow: settings.innerShadow || 0
 property real rimWidth: settings.rimWidth === undefined ? 0.65 : settings.rimWidth
 property real edgeProfile: settings.edgeProfile === undefined ? 1 : settings.edgeProfile
 property real roughness: settings.roughness === undefined ? 0.6 : settings.roughness
 // These are ordinary QML properties: consumers can bind live application
 // data directly. Local hover is a built-in optional data source.
 property real lightX: {
  var base=settings.lightX === undefined ? 0.2 : settings.lightX
  var amount=settings.lightFollowAmount === undefined ? 0.65 : settings.lightFollowAmount
  return settings.followLight && pointer.hovered ? base*(1-amount)+Math.max(0,Math.min(1,pointer.point.position.x/Math.max(width,1)))*amount : base
 }
 property real lightY: {
  var base=settings.lightY === undefined ? 0.05 : settings.lightY
  var amount=settings.lightFollowAmount === undefined ? 0.65 : settings.lightFollowAmount
  return settings.followLight && pointer.hovered ? base*(1-amount)+Math.max(0,Math.min(1,pointer.point.position.y/Math.max(height,1)))*amount : base
 }
 HoverHandler { id:pointer }
 Behavior on lightX { NumberAnimation { duration:100 } }
 Behavior on lightY { NumberAnimation { duration:100 } }
 property real lightSize: settings.lightSize === undefined ? 0.55 : settings.lightSize
 property real tintAmount: settings.tintAmount === undefined ? 1 : settings.tintAmount
 fragmentShader: Qt.resolvedUrl("gradient.frag.qsb")
}
