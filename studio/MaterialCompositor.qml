import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
Item {
 id:root
 required property var controller
 property bool initialized:false
 property string sentState:""
 property bool nativeBase:false
 readonly property int barState:controller.current.effectsEnabled?(controller.current.backdropBlur?1:0):-1
 readonly property int panelState:controller.current.panelEffectsEnabled?(controller.current.panelBackdropBlur?1:0):-1
 onEnabledChanged:if(enabled) initialize()
 onBarStateChanged:if(enabled) schedule.restart()
 onPanelStateChanged:if(enabled) schedule.restart()
 Component.onCompleted:if(enabled) initialize()
 function initialize() { if(!baseRead.running) baseRead.running=true }
 function apply() {
  if(!enabled || !initialized || writer.running) return
  var code="_G.ssMaterialBlur = _G.ssMaterialBlur or {base="+(nativeBase?"true":"false")+"}; local s=_G.ssMaterialBlur; "
  code+="local function set(k,state,ns,popups) local tag=tostring(state)..tostring(popups); if s[k..'state']==tag then return end; if s[k] then pcall(function() s[k]:set_enabled(false) end) end; s[k]=nil; if state>=0 then s[k]=hl.layer_rule({name='surface-studio-'..k,match={namespace=ns},blur=state==1,blur_popups=popups,ignore_alpha=0.01}) end; s[k..'state']=tag end; "
  code+="set('bar',"+barState+",'^omarchy-bar$',"+(panelState===1?"true":"false")+"); set('panels',"+panelState+",'^omarchy-keyboard-panel$',false); "
  code+="hl.config({decoration={blur={enabled="+((barState===1 || panelState===1)?"true":"s.base")+"}}})"
  writer.command=["hyprctl","eval",code]
  sentState=barState+"/"+panelState
  writer.running=true
 }
 Timer { id:schedule; interval:100; onTriggered:root.apply() }
 Process {
  id:baseRead; command:["hyprctl","getoption","decoration:blur:enabled","-j"]
  stdout:StdioCollector { onStreamFinished: {
   try { root.nativeBase=JSON.parse(text).bool===true; root.initialized=true; schedule.restart() }
   catch(e) { root.controller.compositorStatus="Unable to read backdrop blur state." }
  } }
 }
 Process {
  id:writer
  stdout:StdioCollector { id:result }
  onExited:function(code,status) {
   if(root.sentState!==root.barState+"/"+root.panelState) schedule.restart()
   root.controller.compositorStatus=code===0 && result.text.trim()==="ok"?"":"Unable to apply backdrop blur."
  }
 }
 Connections {
  target:Hyprland
  function onRawEvent(event) { if(event.name==="configreloaded" && root.enabled) root.initialize() }
 }
}
