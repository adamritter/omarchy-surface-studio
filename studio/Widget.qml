import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import qs.Ui
import qs.Commons
Panel {
 id: root
 component StudioTab: C.Button {
  id: tab
  implicitHeight:34
  background: Rectangle {
   color:tab.hovered?"#12ffffff":"transparent"
   radius:6; border.width:tab.activeFocus?1:0; border.color:"#7089a7cd"
   Rectangle { anchors.bottom:parent.bottom; anchors.horizontalCenter:parent.horizontalCenter; width:parent.width-24; height:2; radius:1; color:Color.popups.text; opacity:tab.highlighted?0.85:0; Behavior on opacity { NumberAnimation { duration:140 } } }
  }
  contentItem: Text { text:tab.text; color:Color.popups.text; opacity:tab.highlighted?1:tab.hovered?0.9:0.65; font.pixelSize:13; font.weight:tab.highlighted?Font.DemiBold:Font.Normal; horizontalAlignment:Text.AlignHCenter; verticalAlignment:Text.AlignVCenter; Behavior on opacity { NumberAnimation { duration:140 } } }
 }
 component StudioToggle: C.CheckBox {
  id: toggle
  implicitHeight:30
  spacing:10
  indicator: Rectangle {
   x:toggle.leftPadding; y:(toggle.height-height)/2
   width:30; height:18; radius:9
   color:toggle.checked?"#91a8d0":"#394052"
   Behavior on color { ColorAnimation { duration:120 } }
   Rectangle { x:toggle.checked?14:3; y:3; width:12; height:12; radius:6; color:toggle.checked?"#152033":"#aab3c4"; Behavior on x { NumberAnimation { duration:120; easing.type:Easing.OutCubic } } }
   border.width:toggle.activeFocus?1:0; border.color:"#e5edff"
  }
  contentItem: Text { text:toggle.text; leftPadding:toggle.indicator.width+toggle.spacing; color:Color.popups.text; opacity:toggle.enabled?0.9:0.4; font.pixelSize:13; verticalAlignment:Text.AlignVCenter }
 }
 component StudioButton: C.Button {
  id: control
  implicitHeight:36*(styled?materialController.current.panelControlSpacing:1)
  property var materialController:root.studio
  readonly property bool styled:!!materialController && materialController.current.panelControlsEnabled
  implicitWidth:Math.max(80,contentItem.implicitWidth+24*(styled?materialController.current.panelControlSpacing:1))
  background: Rectangle {
   id:buttonBackground
   radius:control.styled?Math.min(height/2,control.materialController.current.panelControlRadius):8
   color:material.active?"transparent":control.down?"#506389":control.hovered?"#405172":control.highlighted?"#45628b":"#2c354b"
   border.color:control.activeFocus?"#a9c8ff":control.highlighted?"#7893b5":"#53627c"; border.width:1
   opacity:control.enabled?1:0.45
   ControlMaterial { id:material; anchors.fill:parent; anchors.margins:1; radius:Math.max(0,buttonBackground.radius-1); controller:control.materialController; hot:control.hovered || control.activeFocus; pressed:control.down; selected:control.highlighted }
  }
  contentItem: Text { text:control.text; color:"#e5edff"; opacity:control.enabled?1:0.5; font.pixelSize:13; horizontalAlignment:Text.AlignHCenter; verticalAlignment:Text.AlignVCenter }
 }
 component StudioSlider: C.Slider {
  id: control
  implicitHeight:26
  background: Rectangle {
   x:control.leftPadding; y:control.topPadding+(control.availableHeight-height)/2
   width:control.availableWidth; height:4; radius:2; color:"#46526b"
   Rectangle { width:control.visualPosition*parent.width; height:parent.height; radius:2; color:"#a9c8ff" }
  }
  handle: Rectangle {
   x:control.leftPadding+control.visualPosition*(control.availableWidth-width)
   y:control.topPadding+(control.availableHeight-height)/2
   width:16; height:16; radius:8; color:control.pressed?"#ffffff":"#c3d8ff"
  }
 }
 component VisualColorPicker: ColumnLayout {
  id: picker
  property color selected: "#89b4fa"
  property real hue: 0
  property real saturation: 0
  property real brightness: 0
  property bool editing: false
  signal picked(string hexColor)
  spacing:10
  function sync() {
   if(editing) return
   if(selected.hsvSaturation>0.001 && selected.hsvValue>0.001) hue=selected.hsvHue
   saturation=selected.hsvSaturation
   brightness=selected.hsvValue
  }
  function commit() {
   var c=Qt.hsva(hue,saturation,brightness,1)
   function hex(v) { return Math.round(v*255).toString(16).padStart(2,"0") }
   editing=true
   picked("#"+hex(c.r)+hex(c.g)+hex(c.b))
   editing=false
  }
  function pickPoint(px,py) {
   saturation=Math.max(0,Math.min(1,px/field.width))
   brightness=1-Math.max(0,Math.min(1,py/field.height))
   commit()
  }
  onSelectedChanged: sync()
  Component.onCompleted: sync()
  Rectangle {
   id: field
   Layout.fillWidth:true
   Layout.preferredHeight:165
   color:Qt.hsva(picker.hue,1,1,1)
   Rectangle {
    anchors.fill:parent
    gradient:Gradient {
     orientation:Gradient.Horizontal
     GradientStop { position:0; color:"#ffffff" }
     GradientStop { position:1; color:"#00ffffff" }
    }
   }
   Rectangle {
    anchors.fill:parent
    gradient:Gradient {
     GradientStop { position:0; color:"#00000000" }
     GradientStop { position:1; color:"#000000" }
    }
   }
   Rectangle {
    x:Math.max(0,Math.min(parent.width-width,picker.saturation*parent.width-width/2))
    y:Math.max(0,Math.min(parent.height-height,(1-picker.brightness)*parent.height-height/2))
    width:14; height:14; radius:7; color:"transparent"; border.color:"white"; border.width:2
    Rectangle { anchors.fill:parent; anchors.margins:2; radius:5; color:"transparent"; border.color:"#222222"; border.width:1 }
   }
   MouseArea {
    anchors.fill:parent
    cursorShape:Qt.CrossCursor
    preventStealing:true
    onPressed:function(mouse) { picker.pickPoint(mouse.x,mouse.y) }
    onPositionChanged:function(mouse) { if(pressed) picker.pickPoint(mouse.x,mouse.y) }
   }
  }
  C.Slider {
   id: hueSlider
   Layout.fillWidth:true
   implicitHeight:25
   from:0; to:1
   value:picker.hue
   onMoved: { picker.hue=value; picker.commit() }
   background:Rectangle {
    x:hueSlider.leftPadding; y:(hueSlider.height-height)/2
    width:hueSlider.availableWidth; height:14; radius:7
    gradient:Gradient {
     orientation:Gradient.Horizontal
     GradientStop { position:0; color:"#ff0000" }
     GradientStop { position:0.1667; color:"#ffff00" }
     GradientStop { position:0.3333; color:"#00ff00" }
     GradientStop { position:0.5; color:"#00ffff" }
     GradientStop { position:0.6667; color:"#0000ff" }
     GradientStop { position:0.8333; color:"#ff00ff" }
     GradientStop { position:1; color:"#ff0000" }
    }
   }
   handle:Rectangle {
    x:hueSlider.leftPadding+hueSlider.visualPosition*(hueSlider.availableWidth-width)
    y:(hueSlider.height-height)/2
    width:18; height:22; radius:5; color:Qt.hsva(picker.hue,1,1,1); border.color:"white"; border.width:2
   }
  }
  Text { text:"Drag in the color field; choose a hue below."; color:Color.popups.text; opacity:0.65; font.pixelSize:11; Layout.fillWidth:true; wrapMode:Text.WordWrap }
 }
 moduleName: "io.github.adamritter.surface-studio"
 ipcTarget: "io.github.adamritter.surface-studio"
 property int selectedColor: 0
 property int selectedBorder: 0
 property int activeTab: 3
 property int effectPage: 0
 property int buttonColorState:0
 readonly property string buttonColorKey:["controlIdleColor","controlActiveColor","controlHoverColor"][buttonColorState]
 function setButtonColor(value) {
  if(!studio) return
  var v=studio.clone(studio.current)
  v.panelControlsEnabled=true; v.panelControlColorsEnabled=true
  v[studio.panelKey(buttonColorKey)]=value
  studio.current=studio.normalized(v); studio.status="Button color · live preview, not saved"
 }
 property bool targetPanel: false
 function profileKey(k) { return targetPanel ? "panel"+k.charAt(0).toUpperCase()+k.slice(1) : k }
 function profileValue(k) { return studio ? studio.current[profileKey(k)] : undefined }
 function profileChange(k,v) { if(studio) studio.change(profileKey(k),v) }
 readonly property bool profileBorderEnabled: studio && !!profileValue("borderCustom") && (targetPanel ? studio.current.borderPanels : studio.current.borderBar)
 readonly property bool barTransparent: bar ? ("transparent" in bar ? bar.transparent : bar.requestedTransparent) : false
 readonly property bool previewBorderEnabled: profileBorderEnabled && (targetPanel || !barTransparent)
 function setProfileBorder(enabled) {
  if(!studio) return
  studio.change(targetPanel?"borderPanels":"borderBar",enabled)
  profileChange("borderCustom",enabled)
 }
 readonly property var previewSettings: studio ? (targetPanel ? studio.panelSettings : studio.current) : ({})
 readonly property var previewBorder: studio ? (targetPanel ? studio.panelBorderSpec : studio.customBorderSpec) : Border.none()
 property var studio: bar && "surfaceStudio" in bar ? bar.surfaceStudio : null
 implicitWidth: button.implicitWidth
 implicitHeight: button.implicitHeight
 WidgetButton {
  id: button
  anchors.fill: parent
  bar: root.bar
  text: "◈"
  tooltipText: "Surface Studio · appearance"
  onPressed: root.toggle()
 }
 KeyboardPanel {
  id: popup
  anchorItem: button
  bar: root.bar
  owner: root
  open: root.opened
  contentWidth: fittedContentWidth(480)
  contentHeight: Math.min(760, availableCardHeight>0?availableCardHeight:760)
  padding: 20
  focusTarget: body
  ColumnLayout {
   id: body
   anchors.fill: parent
   spacing:12
   Keys.onEscapePressed: root.close()
   Text { text:"Surface Studio"; color:Color.popups.text; font.pixelSize:20; font.weight:Font.DemiBold }
   RowLayout {
    Layout.fillWidth:true
    Repeater {
     model:["General","Colors","Border","Effects"]
     StudioTab {
      required property int index
      required property string modelData
      Layout.fillWidth:true
      text:modelData
      highlighted:root.activeTab===index
      onClicked:root.activeTab=index
     }
    }
   }
   Rectangle {
    Layout.fillWidth:true; implicitHeight:34; radius:8; color:"#18000000"
    RowLayout {
     anchors.fill:parent; anchors.margins:3; spacing:3
     Repeater {
      model:["Bar","Panels"]
      C.Button {
       id: segment
       required property int index
       required property string modelData
       Layout.fillWidth:true; Layout.fillHeight:true; Layout.preferredWidth:1
       checked:root.targetPanel===(index===1)
       onClicked:root.targetPanel=index===1
       background:Rectangle { radius:6; color:segment.checked?"#22ffffff":segment.hovered?"#0cffffff":"transparent"; Behavior on color { ColorAnimation { duration:130 } } }
       contentItem:Text { text:segment.modelData; color:Color.popups.text; opacity:segment.checked?1:0.65; font.pixelSize:12; horizontalAlignment:Text.AlignHCenter; verticalAlignment:Text.AlignVCenter }
      }
     }
    }
   }
   Item {
    Layout.fillWidth:true; Layout.preferredHeight:root.targetPanel?126:Math.max(62,(root.bar?root.bar.barSize:Style.bar.sizeHorizontal)+32)
    Rectangle {
     anchors.fill:parent; anchors.margins:8; radius:8; color:"#172536"
     clip:true
     Row {
      anchors.fill:parent
      Repeater { model:12; Rectangle { width:40; height:parent.height; color:index%2===0?"#293e53":"#192939" } }
     }
    }
    Item {
     id: sampleCard
     anchors.centerIn:parent
     width:parent.width-16
     height:root.targetPanel?parent.height-16:(root.bar?root.bar.barSize:Style.bar.sizeHorizontal)
     property real corner:root.targetPanel?(root.profileBorderEnabled?root.profileValue("borderRadius"):Style.cornerRadius):0
     SurfaceShadow { settings:root.previewSettings; radius:sampleCard.corner }
     Rectangle { anchors.fill:parent; radius:sampleCard.corner; color:root.targetPanel?Color.popups.background:Color.bar.background; visible:!(root.studio && ((root.studio.current.enabled && (root.targetPanel?root.studio.current.panels:root.studio.current.bar)) || root.profileValue("effectsEnabled"))) }
     GradientSurface {
      anchors.fill:parent
      visible:root.studio && (root.targetPanel || !root.barTransparent) && ((root.studio.current.enabled && (root.targetPanel?root.studio.current.panels:root.studio.current.bar)) || root.profileValue("effectsEnabled"))
      settings: {
       var v=JSON.parse(JSON.stringify(root.previewSettings))
       if(!root.studio || !root.studio.current.enabled || !(root.targetPanel?root.studio.current.panels:root.studio.current.bar)) { v.strength=0; v.grain=0 }
       return v
      }
      radius:sampleCard.corner
      baseColor:root.targetPanel?Color.popups.background:Color.bar.background
     }
     BorderOverlay { radius:sampleCard.corner; borderSpec:root.previewBorderEnabled?root.previewBorder:(root.targetPanel?Border.surfaceSpec("popups","border",Color.popups.border,2):Border.none()) }
     RowLayout {
      visible:!root.targetPanel
      anchors.fill:parent; anchors.leftMargin:12; anchors.rightMargin:12; spacing:12
      Text { text:"◈"; color:Color.bar.text; font.pixelSize:18 }
      Text { text:"1   2   3"; color:Color.bar.text; opacity:0.65; font.pixelSize:12 }
      Item { Layout.fillWidth:true }
      Text { text:"10:24"; color:Color.bar.text; font.pixelSize:13; font.weight:Font.Medium }
      Item { Layout.fillWidth:true }
      Text { text:"♫   ◉   ▰"; color:Color.bar.text; opacity:0.85; font.pixelSize:13 }
     }
     ColumnLayout {
      visible:root.targetPanel
      anchors.fill:parent; anchors.margins:14; spacing:6
      RowLayout {
       Text { text:"Quick settings"; color:Color.popups.text; font.pixelSize:13; font.weight:Font.DemiBold }
       Item { Layout.fillWidth:true }
       Text { text:"•••"; color:Color.popups.text; opacity:0.5 }
      }
      RowLayout {
       StudioButton { text:"Wi-Fi"; highlighted:true; Layout.fillWidth:true }
       StudioButton { text:"Bluetooth"; Layout.fillWidth:true }
       StudioButton { text:"Sound"; Layout.fillWidth:true }
      }
     }
    }
   }
   C.ScrollView {
    id: scroll
    Layout.fillWidth:true
    Layout.fillHeight:true
    clip:true
    contentWidth:availableWidth
    ColumnLayout {
     width:scroll.availableWidth
     spacing:12
     ColumnLayout {
      visible:root.activeTab===0
      Layout.fillWidth:true
      spacing:12
    RowLayout {
     StudioToggle { text:"Gradients"; checked:root.studio ? root.studio.current.enabled : false; onClicked:root.studio.change("enabled",checked) }
     StudioToggle { text:"Bar"; checked:root.studio ? root.studio.current.bar : false; onClicked:root.studio.change("bar",checked) }
     StudioToggle { text:"Panels"; checked:root.studio ? root.studio.current.panels : false; onClicked:root.studio.change("panels",checked) }
    }
    StudioButton {
     Layout.fillWidth:true
     text:root.bar && root.bar.requestedTransparent ? "Disable transparency" : "Enable transparency"
     enabled:root.bar && typeof root.bar.toggleTransparency === "function"
     onClicked:root.bar.toggleTransparency()
    }
    Text { Layout.fillWidth:true; wrapMode:Text.WordWrap; text:(root.bar && root.bar.requestedTransparent ? "The bar is transparent; its gradient is hidden." : "The bar background is visible.") + " This toggle is saved immediately."; color:Color.popups.text; opacity:0.65; font.pixelSize:12 }
    RowLayout {
     Repeater {
      model:["Windows","Dusk","Night"]
      StudioButton { required property string modelData; required property int index; text:modelData; Layout.fillWidth:true; onClicked:root.studio.preset(index,root.targetPanel) }
     }
    }

     }
     ColumnLayout {
      visible:root.activeTab===1
      Layout.fillWidth:true
      spacing:12
    C.ComboBox {
     Layout.fillWidth:true
     model:["Four corners", "Linear — four colors", "Radial — four colors"]
     background: Rectangle { color:"#2c354b"; radius:8; border.color:"#53627c"; border.width:1 }
     palette.text: "#e5edff"
     palette.buttonText: "#e5edff"
     currentIndex:root.studio ? root.profileValue("mode") : 0
     onActivated:root.profileChange("mode",currentIndex)
    }
    GridLayout {
     columns:2; columnSpacing:12; rowSpacing:10; Layout.fillWidth:true
     Repeater {
      model:["Top left / 1","Top right / 2","Bottom left / 3","Bottom right / 4"]
      ColumnLayout {
       required property string modelData
       required property int index
       Layout.fillWidth:true
       Text { text:modelData; color:Color.popups.text; font.pixelSize:12 }
       RowLayout {
        Rectangle {
         width:28; height:28; radius:7
         color:root.studio ? root.profileValue("c"+(index+1)) : "#24416b"
         border.width:root.selectedColor===index?2:1
         border.color:root.selectedColor===index?"#a9c8ff":"#607089"
         MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:root.selectedColor=index }
        }
        C.TextField {
         Layout.fillWidth:true
         text:root.studio ? root.profileValue("c"+(index+1)) : ""
         maximumLength:7
         selectByMouse:true
         color:acceptableInput ? Color.popups.text : "#f38ba8"
         background: Rectangle { color:"#252d40"; radius:7; border.color:parent.activeFocus?"#a9c8ff":"#47526a"; border.width:1 }
         validator:RegularExpressionValidator { regularExpression:/#[0-9a-fA-F]{6}/ }
         onTextEdited:if(acceptableInput) root.profileChange("c"+(index+1),text)
        }
       }
      }
     }
    }
    Text { text:"Color picker · "+(root.selectedColor+1)+" color"; color:Color.popups.text; font.pixelSize:13 }
    VisualColorPicker {
     Layout.fillWidth:true
     selected:root.studio?root.profileValue("c"+(root.selectedColor+1)):"#89b4fa"
     onPicked:function(hexColor) { if(root.studio) root.profileChange("c"+(root.selectedColor+1),hexColor) }
    }
    Text { text:"Color strength"; color:Color.popups.text; font.pixelSize:13 }
    StudioSlider { Layout.fillWidth:true; from:0; to:1; value:root.studio ? root.profileValue("strength") : 0.55; onMoved:root.profileChange("strength",value) }
    Text { visible:root.studio && root.profileValue("mode")===1; text:"Direction · "+Math.round(root.studio ? root.profileValue("angle") : 0)+"°"; color:Color.popups.text; font.pixelSize:13 }
    StudioSlider { visible:root.studio && root.profileValue("mode")===1; Layout.fillWidth:true; from:0; to:360; value:root.studio ? root.profileValue("angle") : 25; onMoved:root.profileChange("angle",value) }
    Text { text:"Fine grain"; color:Color.popups.text; font.pixelSize:13 }
    StudioSlider { Layout.fillWidth:true; from:0; to:1; value:root.studio ? root.profileValue("grain") : 0.15; onMoved:root.profileChange("grain",value) }

     }
     ColumnLayout {
      visible:root.activeTab===2
      Layout.fillWidth:true
      spacing:12

    StudioToggle { text:"Custom border"; checked:root.profileBorderEnabled; onClicked:root.setProfileBorder(checked) }
    Text { Layout.fillWidth:true; wrapMode:Text.WordWrap; text:root.targetPanel?"When disabled, the theme border and rounding apply.":(root.barTransparent?"The bar is transparent. Disable transparency in General to show the border.":"Border changes apply to the bar immediately."); color:Color.popups.text; opacity:0.65; font.pixelSize:12 }
    ColumnLayout {
     Layout.fillWidth:true
     enabled:root.profileBorderEnabled
     opacity:enabled?1:0.45
     spacing:12
     Text { text:"Width · "+(root.studio?root.profileValue("borderWidth"):2)+" px"; color:Color.popups.text; font.pixelSize:13 }
     StudioSlider { Layout.fillWidth:true; from:0; to:12; stepSize:1; value:root.studio?root.profileValue("borderWidth"):2; onMoved:root.profileChange("borderWidth",value) }
     Text { visible:root.targetPanel; text:"Corner radius · "+(root.studio?root.profileValue("borderRadius"):8)+" px"; color:Color.popups.text; font.pixelSize:13 }
     StudioSlider { visible:root.targetPanel; Layout.fillWidth:true; from:0; to:40; stepSize:1; value:root.studio?root.profileValue("borderRadius"):8; onMoved:root.profileChange("borderRadius",value) }
     StudioToggle { text:"Gradient border"; checked:root.studio && root.profileValue("borderGradient"); onClicked:root.profileChange("borderGradient",checked) }
     Repeater {
      model:["Border color","Second color"]
      RowLayout {
       required property int index
       required property string modelData
       visible:index===0 || (root.studio && root.profileValue("borderGradient"))
       Layout.fillWidth:true
       Text { text:modelData; Layout.preferredWidth:100; color:Color.popups.text; font.pixelSize:13 }
       Rectangle {
        width:32; height:32; radius:7
        color:root.studio?root.profileValue("borderColor"+(index+1)):"#89b4fa"
        border.color:root.selectedBorder===index?"white":"#607089"; border.width:root.selectedBorder===index?2:1
        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:root.selectedBorder=index }
       }
       C.TextField {
        Layout.fillWidth:true; maximumLength:7; selectByMouse:true
        text:root.studio?root.profileValue("borderColor"+(index+1)):"#89b4fa"
        color:acceptableInput?Color.popups.text:"#f38ba8"
        background:Rectangle { radius:7; color:"#252d40"; border.color:parent.activeFocus?"#a9c8ff":"#47526a" }
        validator:RegularExpressionValidator { regularExpression:/#[0-9a-fA-F]{6}/ }
        onTextEdited:if(acceptableInput) root.profileChange("borderColor"+(index+1),text)
       }
      }
     }
     Text { text:"Border color picker"; color:Color.popups.text; font.pixelSize:13 }
     VisualColorPicker {
      Layout.fillWidth:true
      property int effectiveIndex:root.studio && root.profileValue("borderGradient")?root.selectedBorder:0
      selected:root.studio?root.profileValue("borderColor"+(effectiveIndex+1)):"#89b4fa"
      onPicked:function(hexColor) { if(root.studio) root.profileChange("borderColor"+(effectiveIndex+1),hexColor) }
     }
     Text { visible:root.studio && root.profileValue("borderGradient"); text:"Gradient direction · "+Math.round(root.studio?root.profileValue("borderAngle"):45)+"°"; color:Color.popups.text; font.pixelSize:13 }
     StudioSlider { visible:root.studio && root.profileValue("borderGradient"); Layout.fillWidth:true; from:0; to:360; stepSize:1; value:root.studio?root.profileValue("borderAngle"):45; onMoved:root.profileChange("borderAngle",value) }
    }

     }
     ColumnLayout {
      visible:root.activeTab===3
      Layout.fillWidth:true; spacing:12
      Text { text:root.effectPage===3?"Buttons and controls":"Light, material and depth"; color:Color.popups.text; font.pixelSize:16; font.bold:true }
      StudioToggle { visible:root.effectPage!==3; text:"Visual effects"; checked:root.studio && root.profileValue("effectsEnabled"); onClicked:root.profileChange("effectsEnabled",checked) }
      RowLayout {
       Layout.fillWidth:true
       Repeater {
        model:root.effectPage===3?[]:["Glass","Satin","Floating"]
        StudioButton { required property int index; required property string modelData; Layout.fillWidth:true; text:modelData; onClicked:root.studio.effectPreset(index,root.targetPanel) }
       }
      }
      Text { visible:root.effectPage!==3; Layout.fillWidth:true; wrapMode:Text.WordWrap; text:!root.targetPanel && root.barTransparent?"The bar is fully transparent. Disable transparency in General to show material effects.":"Opacity affects the background; text and icons remain sharp."; color:Color.popups.text; opacity:0.65; font.pixelSize:12 }
      StudioButton { visible:root.effectPage!==3; Layout.fillWidth:true; text:"Refined glass · coordinated preset"; onClicked:root.studio.refinedPreset(root.targetPanel) }
      RowLayout {
       Layout.fillWidth:true
       Repeater {
        model:["Material","Light","Shadow","Controls"]
        StudioTab { required property int index; required property string modelData; Layout.fillWidth:true; text:modelData; highlighted:root.effectPage===index; onClicked:root.effectPage=index }
       }
      }
      C.ComboBox {
       visible:root.effectPage===0
       Layout.fillWidth:true
       model:["Flat edge","Rounded edge","Glass edge"]
       currentIndex:root.studio?root.profileValue("edgeProfile"):1
       onActivated:root.profileChange("edgeProfile",currentIndex)
      }
      StudioToggle { visible:root.effectPage===0; text:"Backdrop blur"; checked:root.studio && root.profileValue("backdropBlur"); onClicked:root.profileChange("backdropBlur",checked) }
      Text { visible:root.effectPage===0; Layout.fillWidth:true; wrapMode:Text.WordWrap; text:"Backdrop blur also enables Hyprland's shared blur engine. Lighting and material effects are rendered locally."; color:Color.popups.text; opacity:0.6; font.pixelSize:11 }
      StudioToggle { visible:root.effectPage===1; text:"Pointer-following light"; checked:root.studio && root.profileValue("followLight"); onClicked:root.profileChange("followLight",checked) }
      StudioToggle { visible:root.effectPage===3 && root.targetPanel; text:"Button materials and panel control styling"; checked:root.studio && root.profileValue("controlsEnabled"); onClicked:root.profileChange("controlsEnabled",checked) }
      ColumnLayout {
       visible:root.effectPage===3 && root.targetPanel
       Layout.fillWidth:true; spacing:10
       StudioToggle { text:"Custom button colors"; checked:root.studio && root.studio.current.panelControlColorsEnabled; onClicked:{ root.studio.change("panelControlColorsEnabled",checked); if(checked) root.studio.change("panelControlsEnabled",true) } }
       Text { Layout.fillWidth:true; wrapMode:Text.WordWrap; text:"Choose a state and its color. Lighting and shadows are preserved. Hover color takes precedence over selection."; color:Color.popups.text; font.pixelSize:12 }
       RowLayout {
        Layout.fillWidth:true
        Repeater {
         model:["Idle","Selected","Hover"]
         ColumnLayout {
          required property int index
          required property string modelData
          Layout.fillWidth:true
          StudioButton { text:modelData; Layout.fillWidth:true; highlighted:root.buttonColorState===index; onClicked:root.buttonColorState=index }
          Rectangle {
           Layout.fillWidth:true; height:25; radius:5
           color:root.studio?root.studio.current[root.studio.panelKey(["controlIdleColor","controlActiveColor","controlHoverColor"][index])]:"#292536"
           border.width:root.buttonColorState===index?2:1; border.color:root.buttonColorState===index?"#c3d8ff":"#53627c"
           MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:root.buttonColorState=index }
          }
         }
        }
       }
       C.TextField {
        Layout.fillWidth:true; maximumLength:7; selectByMouse:true
        text:root.studio?root.studio.current[root.studio.panelKey(root.buttonColorKey)]:"#292536"
        color:acceptableInput?Color.popups.text:"#f38ba8"
        validator:RegularExpressionValidator { regularExpression:/#[0-9a-fA-F]{6}/ }
        onTextEdited:if(acceptableInput) root.setButtonColor(text)
       }
       VisualColorPicker { Layout.fillWidth:true; selected:root.studio?root.studio.current[root.studio.panelKey(root.buttonColorKey)]:"#292536"; onPicked:function(hexColor) { root.setButtonColor(hexColor) } }
      }
      Text { visible:root.effectPage===3 && !root.targetPanel; Layout.fillWidth:true; wrapMode:Text.WordWrap; text:"Select Panels above to style buttons, switches and spacing."; color:Color.popups.text; font.pixelSize:12 }
      ColumnLayout {
       Layout.fillWidth:true; spacing:10
       Repeater {
        model:[{"key": "surfaceOpacity", "label": "Background opacity", "min": 0.15, "max": 1, "step": 0.01, "unit": "%", "group": 0}, {"key": "tintAmount", "label": "Material tint", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 0}, {"key": "roughness", "label": "Roughness", "min": 0.05, "max": 1, "step": 0.01, "unit": "%", "group": 0}, {"key": "bevelWidth", "label": "Bevel width", "min": 1, "max": 12, "step": 0.25, "unit": "px", "group": 0}, {"key": "rimWidth", "label": "Rim width", "min": 0.25, "max": 3, "step": 0.05, "unit": "px", "group": 0}, {"key": "bevelStrength", "label": "Bevel light", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "rimStrength", "label": "Rim light", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "lightX", "label": "Light horizontal position", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "lightY", "label": "Light vertical position", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "lightSize", "label": "Light size", "min": 0.05, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "lightFollowAmount", "label": "Pointer-follow amount", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "sheenStrength", "label": "Surface sheen", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "innerShadow", "label": "Inset shadow", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 1}, {"key": "shadowStrength", "label": "Ambient shadow strength", "min": 0, "max": 1, "step": 0.01, "unit": "%", "group": 2}, {"key": "shadowBlur", "label": "Ambient shadow softness", "min": 2, "max": 40, "step": 1, "unit": "px", "group": 2}, {"key": "shadowOffset", "label": "Ambient shadow offset", "min": 0, "max": 20, "step": 1, "unit": "px", "group": 2}, {"key": "contactStrength", "label": "Contact shadow strength", "min": 0, "max": 0.7, "step": 0.01, "unit": "%", "group": 2}, {"key": "contactBlur", "label": "Contact shadow softness", "min": 1, "max": 10, "step": 0.5, "unit": "px", "group": 2}, {"key": "contactOffset", "label": "Contact shadow offset", "min": 0, "max": 6, "step": 0.5, "unit": "px", "group": 2}, {"key": "controlRadius", "label": "Control rounding", "min": 0, "max": 20, "step": 1, "unit": "px", "group": 3}, {"key": "controlSpacing", "label": "Control spacing", "min": 0.7, "max": 1.5, "step": 0.05, "unit": "%", "group": 3}, {"key": "controlContrast", "label": "State contrast", "min": 0.3, "max": 1.5, "step": 0.05, "unit": "%", "group": 3}, {"key": "textNeutrality", "label": "Neutral text color", "min": 0, "max": 1, "step": 0.05, "unit": "%", "group": 3}, {"key": "outerGap", "label": "Panel outer gap", "min": 0, "max": 30, "step": 1, "unit": "px", "group": 3}, {"key": "innerPadding", "label": "Panel inner padding", "min": 8, "max": 30, "step": 1, "unit": "px", "group": 3}]
        ColumnLayout {
         required property var modelData
         visible:modelData.group===root.effectPage && (modelData.group!==3 || root.targetPanel)
         enabled:root.studio && (modelData.group===3?root.profileValue("controlsEnabled"):root.profileValue("effectsEnabled"))
         opacity:enabled?1:0.45
         Layout.fillWidth:true; spacing:2
         Text { text:modelData.label+" · "+(modelData.unit==="%"?Math.round((root.studio?root.profileValue(modelData.key):0)*100):Number(root.studio?root.profileValue(modelData.key):0).toFixed(modelData.step<1?1:0))+" "+modelData.unit; color:Color.popups.text; font.pixelSize:13 }
         StudioSlider { Layout.fillWidth:true; from:modelData.min; to:modelData.max; stepSize:modelData.step; value:root.studio?root.profileValue(modelData.key):modelData.min; onMoved:root.profileChange(modelData.key,value) }
        }
       }
      }
     }
    }
   }
   RowLayout {
    Layout.fillWidth:true
    StudioButton { text:"Revert"; Layout.fillWidth:true; enabled:root.studio && root.studio.dirty; onClicked:root.studio.revert() }
    StudioButton { text:"Save"; Layout.fillWidth:true; highlighted:true; enabled:root.studio && !root.studio.pendingSave; onClicked:root.studio.save() }
   }
   Text { Layout.fillWidth:true; wrapMode:Text.WordWrap; text:root.studio?(root.studio.compositorStatus || root.studio.status):"Enable the Surface Studio bar to use this editor."; color:Color.popups.text; opacity:0.7; font.pixelSize:12 }
  }
 }
}
