import QtQuick
import qs.Commons
Item {
 id:root
 anchors.fill:parent
 z:-1
 objectName:"surface-studio-control-adapter"
 required property var controller
 required property var control
 required property int kind
 readonly property bool surface:kind!==1
 readonly property bool hot:kind===0?(control.hot || control._showFocusRing):kind===2?control.hasCursor:kind===3?(control._hot || control._showFocusRing):false
 readonly property bool selected:kind===0?(control.selected || control.active):kind===2?control.current:false
 readonly property bool active: controller.current.panelControlsEnabled
 property real originalHorizontal:0
 property real originalVertical:0
 PointHandler { id:press; acceptedButtons:Qt.LeftButton; enabled:root.active && root.surface }
 ControlMaterial { anchors.fill:parent; controller:root.controller; visible:active && root.surface; radius:root.surface?root.control.radius:0; hot:root.hot; selected:root.selected; pressed:press.active }
 function textColor() {
  var c=Color.popups.text; var t=controller.current.panelTextNeutrality
  return Qt.rgba(c.r+(0.94-c.r)*t,c.g+(0.95-c.g)*t,c.b+(0.97-c.b)*t,1)
 }
 Binding { target:root.surface?root.control:null; property:"radius"; value:Math.min(root.controller.current.panelControlRadius,root.control.height/2); when:root.active && root.surface; restoreMode:Binding.RestoreBindingOrValue }
 Binding { target:root.kind===0?root.control:null; property:"horizontalPadding"; value:root.originalHorizontal*root.controller.current.panelControlSpacing; when:root.active && root.kind===0; restoreMode:Binding.RestoreBindingOrValue }
 Binding { target:root.kind===0?root.control:null; property:"verticalPadding"; value:root.originalVertical*root.controller.current.panelControlSpacing; when:root.active && root.kind===0; restoreMode:Binding.RestoreBindingOrValue }
 Binding { target:root.kind===1?root.control:null; property:"rounded"; value:root.controller.current.panelControlRadius>0; when:root.active && root.kind===1; restoreMode:Binding.RestoreBindingOrValue }
 Binding { target:root.control; property:"foreground"; value:root.textColor(); when:root.active; restoreMode:Binding.RestoreBindingOrValue }
 Binding {
  target:root.surface?root.control:null; property:"color"; when:root.active && root.surface; restoreMode:Binding.RestoreBindingOrValue
  value: {
   if(!root.surface) return "transparent"
   if(root.controller.current.panelEffectsEnabled || root.controller.current.panelControlColorsEnabled) return "transparent"
   var alpha=root.hot?0.13:root.selected?0.12:0.025
   return Qt.rgba(0.88,0.92,1,alpha*root.controller.current.panelControlContrast)
  }
 }
}
