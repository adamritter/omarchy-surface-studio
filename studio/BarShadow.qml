import QtQuick
import Quickshell
import Quickshell.Wayland
PanelWindow {
 id: root
 required property var bar
 required property var sourceWindow
 required property var controller
 readonly property var settings: controller.current
 readonly property bool vertical: bar.position==="left" || bar.position==="right"
 screen:sourceWindow.screen
 visible:sourceWindow.visible && !bar.barHidden && !bar.transparent && !!settings.effectsEnabled && (settings.shadowStrength>0 || settings.contactStrength>0)
 color:"transparent"
 exclusionMode:ExclusionMode.Ignore
 mask:Region {}
 WlrLayershell.namespace:"surface-studio-bar-shadow"
 WlrLayershell.layer:WlrLayer.Top
 WlrLayershell.keyboardFocus:WlrKeyboardFocus.None
 anchors {
  top:root.bar.position==="top" || root.vertical
  bottom:root.bar.position==="bottom" || root.vertical
  left:root.bar.position==="left" || !root.vertical
  right:root.bar.position==="right" || !root.vertical
 }
 margins {
  top:root.bar.position==="top"?root.bar.barSize:0
  bottom:root.bar.position==="bottom"?root.bar.barSize:0
  left:root.bar.position==="left"?root.bar.barSize:0
  right:root.bar.position==="right"?root.bar.barSize:0
 }
 implicitWidth:vertical?Math.ceil(Math.max(settings.shadowBlur+settings.shadowOffset,settings.contactBlur*2+settings.contactOffset)):0
 implicitHeight:vertical?0:Math.ceil(Math.max(settings.shadowBlur+settings.shadowOffset,settings.contactBlur*2+settings.contactOffset))
 Rectangle {
  anchors {
   top:root.bar.position==="top" || root.vertical ? parent.top : undefined
   bottom:root.bar.position==="bottom" || root.vertical ? parent.bottom : undefined
   left:root.bar.position==="left" || !root.vertical ? parent.left : undefined
   right:root.bar.position==="right" || !root.vertical ? parent.right : undefined
  }
  width:root.vertical?root.settings.contactBlur*2+root.settings.contactOffset:parent.width
  height:root.vertical?parent.height:root.settings.contactBlur*2+root.settings.contactOffset
  rotation:root.bar.position==="bottom" || root.bar.position==="right"?180:0
  gradient:Gradient {
   orientation:root.vertical?Gradient.Horizontal:Gradient.Vertical
   GradientStop { position:0; color:Qt.rgba(0,0,0,root.settings.contactStrength || 0) }
   GradientStop { position:1; color:"transparent" }
  }
 }
 Rectangle {
  anchors.fill:parent
  rotation:root.bar.position==="bottom" || root.bar.position==="right"?180:0
  gradient:Gradient {
   orientation:root.vertical?Gradient.Horizontal:Gradient.Vertical
   GradientStop { position:0; color:Qt.rgba(0,0,0,root.settings.shadowStrength*0.8) }
   GradientStop { position:0.35; color:Qt.rgba(0,0,0,root.settings.shadowStrength*0.3) }
   GradientStop { position:1; color:"transparent" }
  }
 }
}
