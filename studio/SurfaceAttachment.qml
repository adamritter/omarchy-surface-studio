import QtQuick
import qs.Commons
Item {
 id: root
 required property var controller
 required property var popup
 required property var card
 anchors.fill: parent
 z: -1
 readonly property bool backgroundEnabled: (controller.current.enabled && controller.current.panels) || controller.current.panelEffectsEnabled
 readonly property bool borderEnabled: controller.current.panelBorderCustom && controller.current.borderPanels
 Binding {
  target: root.card
  property: "color"
  value: "transparent"
  when: root.backgroundEnabled
  restoreMode: Binding.RestoreBindingOrValue
 }
 Binding {
  target: root.card
  property: "borderSpec"
  value: root.borderEnabled ? root.controller.panelBorderSpec : root.popup.borderSpec
  restoreMode: Binding.RestoreBindingOrValue
 }
 Binding {
  target: root.card
  property: "radius"
  value: root.controller.current.panelBorderRadius
  when: root.borderEnabled
  restoreMode: Binding.RestoreBindingOrValue
 }
 Binding { target:root.popup; property:"margin"; value:root.controller.current.panelOuterGap; when:root.controller.current.panelControlsEnabled; restoreMode:Binding.RestoreBindingOrValue }
 property bool hasGap:false
 Component.onCompleted:hasGap=("gap" in popup)
 Binding { target:root.hasGap?root.popup:null; property:"gap"; value:root.controller.current.panelOuterGap; when:root.hasGap && root.controller.current.panelControlsEnabled; restoreMode:Binding.RestoreBindingOrValue }
 Binding { target:root.popup; property:"padding"; value:root.controller.current.panelInnerPadding; when:root.controller.current.panelControlsEnabled; restoreMode:Binding.RestoreBindingOrValue }
 property var controlAdapters: []
 Component { id:controlAdapter; ControlStyle {} }
 function scanControls() {
  if(!root.controller.current.panelControlsEnabled) return
  var seen=[]
  function visit(o) {
   if(!o || seen.length>1800 || seen.indexOf(o)>=0 || o===root || o.objectName==="surface-studio-control-adapter") return
   seen.push(o)
   var kind=("_showFocusRing" in o && "horizontalPadding" in o && "radius" in o)?0:(("trackHeight" in o && "rounded" in o && "knobInset" in o)?1:(("currentFill" in o && "hasCursor" in o && "borderSpec" in o)?2:(("_hot" in o && "hoverColor" in o && "borderSpec" in o)?3:-1)))
   if(kind>=0) {
    var exists=false
    for(var a of root.controlAdapters) if(a && a.control===o) exists=true
    if(!exists) { var a=controlAdapter.createObject(o,{controller:root.controller,control:o,kind:kind,originalHorizontal:kind===0?o.horizontalPadding:0,originalVertical:kind===0?o.verticalPadding:0}); if(a) root.controlAdapters=root.controlAdapters.concat([a]) }
   }
   if("children" in o) for(var child of o.children) visit(child)
   if("item" in o && o.item) visit(o.item)
  }
  visit(root.card)
 }
 Timer { interval:250; repeat:true; running:root.popup.open && root.controller.current.panelControlsEnabled; triggeredOnStart:true; onTriggered:root.scanControls() }
 Component.onDestruction: {
  // The shared popup owns the original reactive border specification.
  // Restore that binding explicitly: Qt's var Binding restoration can retain
  // the last preview object when value and when change together.
  for(var a of controlAdapters) if(a) a.destroy()
  var source=root.popup
  if(root.card && source) root.card.borderSpec=Qt.binding(function() { return source.borderSpec })
 }
 SurfaceShadow {
  clipBounds: {
   if(!("cardOrigin" in root.popup)) return Qt.vector4d(-100000,-100000,100000,100000)
   // Explicit animation dependencies keep the cutoff screen-aligned as the card moves.
   var movement=root.card.x+root.card.y+root.card.scale
   var origin=root.card.mapToItem(null,0,0)
   var pos=root.popup.barPos
   var left=pos==="left"?root.popup.barW:0
   var top=pos==="top"?root.popup.barH:0
   var right=root.popup.screenW-(pos==="right"?root.popup.barW:0)
   var bottom=root.popup.screenH-(pos==="bottom"?root.popup.barH:0)
   var scale=Math.max(0.001,root.card.scale)
   return Qt.vector4d((left-origin.x)/scale,(top-origin.y)/scale,(right-origin.x)/scale,(bottom-origin.y)/scale)
  }
  settings:root.controller.panelSettings
  radius:root.card.radius
  // KeyboardPanel has a full-screen drawing surface. PopupCard's native
  // window clips at its card bounds, so retain only the inset lighting there.
  visible: root.backgroundEnabled && root.controller.current.panelEffectsEnabled && (root.controller.current.panelShadowStrength>0 || root.controller.current.panelContactStrength>0) && ("cardOrigin" in root.popup)
 }
 GradientSurface {
  visible: root.backgroundEnabled
  anchors.fill: parent
  settings: {
   var v=root.controller.clone(root.controller.panelSettings)
   if(!root.controller.current.enabled || !root.controller.current.panels) { v.strength=0; v.grain=0 }
   return v
  }
  baseColor: Color.popups.background
  radius: root.card.radius
 }
}
