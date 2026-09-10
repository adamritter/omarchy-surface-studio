import QtQuick
import qs.Commons
Item {
 id:root
 required property var controller
 property real radius:8
 property bool hot:false
 property bool pressed:false
 property bool selected:false
 readonly property bool active:!!controller && controller.current.panelControlsEnabled && (controller.current.panelEffectsEnabled || controller.current.panelControlColorsEnabled)
 visible:active
 readonly property bool customColors:!!controller && controller.current.panelControlColorsEnabled
 readonly property color mainColor:customColors?(hot?controller.current.panelControlHoverColor:selected?controller.current.panelControlActiveColor:controller.current.panelControlIdleColor):Qt.lighter(Color.popups.background,pressed?1.04:hot?1.5:selected?1.4:1.18)
 readonly property var material: {
  if(!controller) return ({})
  var v=controller.clone(controller.panelSettings)
  v.strength=controller.current.enabled && controller.current.panels?v.strength:0
  if(customColors) { v.strength=0; v.grain=0 }
  v.bevelWidth=Math.min(v.bevelWidth,Math.max(1,height/5))
  v.shadowBlur=Math.min(12,v.shadowBlur*0.45)
  v.shadowOffset=Math.min(4,v.shadowOffset*0.4)
  v.shadowStrength*=pressed?0.15:0.6
  v.contactStrength*=pressed?0.2:0.7
  v.contactBlur=Math.min(4,v.contactBlur)
  v.contactOffset=Math.min(2,v.contactOffset)
  v.innerShadow=pressed?Math.max(0.25,v.innerShadow):v.innerShadow
  v.sheenStrength*=pressed?0.4:hot?1.25:1
  return v
 }
 SurfaceShadow { settings:root.material; radius:root.radius }
 GradientSurface {
  anchors.fill:parent
  radius:root.radius
  settings:root.material
  baseColor:root.pressed?Qt.darker(root.mainColor,1.12):root.mainColor
  Behavior on baseColor { ColorAnimation { duration:100 } }
 }
 Rectangle {
  anchors.fill:parent; radius:root.radius
  visible:!root.customColors
  color:Qt.rgba(0.8,0.88,1,(root.pressed?0.025:root.hot?0.10:root.selected?0.075:0.015)*(root.controller?root.controller.current.panelControlContrast:1))
 }
}
