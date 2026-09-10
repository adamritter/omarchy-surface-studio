import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import Quickshell.Hyprland
Item {
 id: root
 required property var bar
 property var baseDefaults: ({barHoverEnabled:false,barHoverStrength:0.08,barHoverRadius:6,barModuleGap:0,edgeTint:0,edgeTintWidth:5,enabled:true,panels:true,bar:true,mode:0,c1:"#24416b",c2:"#493d68",c3:"#193d49",c4:"#292f50",angle:25,strength:0.55,grain:0.15,borderCustom:false,borderPanels:true,borderBar:false,borderGradient:false,borderWidth:2,borderRadius:8,borderColor1:"#89b4fa",borderColor2:"#cba6f7",borderAngle:45,effectsEnabled:false,coherentLight:false,rayGlass:false,glassIor:1.45,glassThickness:4,glassMix:0.55,surfaceOpacity:1.0,lightAngle:225,bevelWidth:3,bevelStrength:0.35,rimStrength:0.25,sheenStrength:0.12,innerShadow:0.12,shadowStrength:0.35,shadowBlur:18,shadowOffset:6,followLight:false,lightFollowAmount:0.65,rimWidth:0.65,edgeProfile:1,roughness:0.6,lightX:0.2,lightY:0.05,lightSize:0.55,tintAmount:1,contactStrength:0.12,contactBlur:3,contactOffset:1,backdropBlur:false,controlsEnabled:false,controlColorsEnabled:false,controlIdleColor:"#292536",controlActiveColor:"#45405f",controlHoverColor:"#534863",controlRadius:8,controlSpacing:1,controlContrast:0.7,textNeutrality:0.5,outerGap:10,innerPadding:18})
 property var profileKeys: ["coherentLight","edgeTint","edgeTintWidth","mode","c1","c2","c3","c4","angle","strength","grain","borderCustom","borderGradient","borderWidth","borderRadius","borderColor1","borderColor2","borderAngle","effectsEnabled","rayGlass","glassIor","glassThickness","glassMix","surfaceOpacity","lightAngle","bevelWidth","bevelStrength","rimStrength","sheenStrength","innerShadow","shadowStrength","shadowBlur","shadowOffset","followLight","lightFollowAmount","rimWidth","edgeProfile","roughness","lightX","lightY","lightSize","tintAmount","contactStrength","contactBlur","contactOffset","backdropBlur","controlsEnabled","controlColorsEnabled","controlIdleColor","controlActiveColor","controlHoverColor","controlRadius","controlSpacing","controlContrast","textNeutrality","outerGap","innerPadding"]
 function panelKey(k) { return "panel"+k.charAt(0).toUpperCase()+k.slice(1) }
 property var defaults: {
  var d=clone(baseDefaults)
  for(var k of profileKeys) d[panelKey(k)]=baseDefaults[k]
  return d
 }
 readonly property var panelSettings: {
  var d=clone(current)
  for(var k of profileKeys) d[k]=current[panelKey(k)]
  return d
 }
 readonly property var panelBorderSpec: makeBorder(panelSettings)
 function makeBorder(values) {
  var spec=Border.flat(values.borderColor1,values.borderWidth)
  if(values.borderGradient) spec.gradient={colors:[values.borderColor1,values.borderColor2],angle:values.borderAngle,enabled:true}
  return spec
 }
 property var current: clone(defaults)
 property var saved: clone(defaults)
 property var pendingSave: null
 property string settingsPath: Quickshell.env("HOME")+"/.config/omarchy/surface-studio.json"
 property bool ready: false
 property bool compositorBridgeEnabled: true
 property string compositorStatus: ""
 property string status: ""
 property var attachments: []
 property bool scanComplete: false
 readonly property var customBorderSpec: makeBorder(current)
 readonly property bool dirty: JSON.stringify(current) !== JSON.stringify(saved)
 function clone(v) { return JSON.parse(JSON.stringify(v)) }
 function normalized(v) {
  // Old saves used one shared palette. Seed the new panel profile from it.
  v=clone(v)
  for(var pk of profileKeys) if(v[panelKey(pk)]===undefined && v[pk]!==undefined) v[panelKey(pk)]=v[pk]
  var r=clone(defaults)
  for (var k in r) {
   if (typeof r[k] === "boolean") { if (typeof v[k] === "boolean") r[k]=v[k] }
   else if (typeof r[k] === "string") { if (/^#[0-9a-fA-F]{6}$/.test(v[k] || "")) r[k]=v[k] }
   else if (typeof v[k] === "number" && isFinite(v[k])) r[k]=v[k]
  }
  r.mode=Math.max(0,Math.min(2,Math.round(r.mode)))
  r.angle=Math.max(0,Math.min(360,r.angle))
  for(var n of ["strength","grain"]) r[n]=Math.max(0,Math.min(1,r[n]))
  r.borderWidth=Math.max(0,Math.min(12,r.borderWidth))
  r.borderRadius=Math.max(0,Math.min(40,r.borderRadius))
  r.borderAngle=Math.max(0,Math.min(360,r.borderAngle))
  r.panelMode=Math.max(0,Math.min(2,Math.round(r.panelMode)))
  for(var a of ["panelAngle","panelBorderAngle"]) r[a]=Math.max(0,Math.min(360,r[a]))
  for(var n of ["panelStrength","panelGrain"]) r[n]=Math.max(0,Math.min(1,r[n]))
  r.panelBorderWidth=Math.max(0,Math.min(12,r.panelBorderWidth))
  r.panelBorderRadius=Math.max(0,Math.min(40,r.panelBorderRadius))
  for(var prefix of ["","panel"]) {
   function ek(k) { return prefix ? root.panelKey(k) : k }
   for(var k of ["surfaceOpacity","bevelStrength","rimStrength","sheenStrength","innerShadow","shadowStrength"]) r[ek(k)]=Math.max(k==="surfaceOpacity"?0.15:0,Math.min(1,r[ek(k)]))
   r[ek("lightAngle")]=Math.max(0,Math.min(360,r[ek("lightAngle")]))
   r[ek("bevelWidth")]=Math.max(1,Math.min(12,r[ek("bevelWidth")]))
   r[ek("shadowBlur")]=Math.max(2,Math.min(40,r[ek("shadowBlur")]))
   r[ek("shadowOffset")]=Math.max(0,Math.min(20,r[ek("shadowOffset")]))
  }
  for(var panel of [false,true]) {
   function kk(k) { return panel?root.panelKey(k):k }
   var ranges={edgeTint:[0,1],edgeTintWidth:[1,20],glassIor:[1,1.8],glassThickness:[0.5,12],glassMix:[0,1],lightFollowAmount:[0,1],rimWidth:[0.25,3],edgeProfile:[0,2],roughness:[0.05,1],lightX:[0,1],lightY:[0,1],lightSize:[0.05,1],tintAmount:[0,1],contactStrength:[0,0.7],contactBlur:[1,10],contactOffset:[0,6],controlRadius:[0,20],controlSpacing:[0.7,1.5],controlContrast:[0.3,1.5],textNeutrality:[0,1],outerGap:[0,30],innerPadding:[8,30]}
   for(var k in ranges) r[kk(k)]=Math.max(ranges[k][0],Math.min(ranges[k][1],r[kk(k)]))
   r[kk("edgeProfile")]=Math.round(r[kk("edgeProfile")])
  }
  r.barHoverStrength=Math.max(0,Math.min(0.25,r.barHoverStrength))
  r.barHoverRadius=Math.max(0,Math.min(16,r.barHoverRadius))
  r.barModuleGap=Math.max(0,Math.min(8,r.barModuleGap))
  return r
 }
 function change(key,value) { var v=clone(current); v[key]=value; current=normalized(v); status="Live preview — not saved"; scanTimer.restart() }
 function preset(name, panel) {
  var v=clone(current)
  var colors=name===1?["#3f486a","#654b67","#244955","#394467"]:name===2?["#152532","#273046","#123536","#252638"]:["#24416b","#493d68","#193d49","#292f50"]
  function key(k) { return panel ? root.panelKey(k) : k }
  for(var i=0;i<4;i++) v[key("c"+(i+1))]=colors[i]
  v.enabled=true; v[key("mode")]=0; v[key("strength")]=0.55; v[key("grain")]=0.15
  current=v; status="Live preview — not saved"
 }
 function effectPreset(name,panel) {
  var v=clone(current)
  var presets=[
   {surfaceOpacity:0.86,bevelWidth:3,bevelStrength:0.38,rimStrength:0.55,sheenStrength:0.20,innerShadow:0.10,shadowStrength:0.32,shadowBlur:22,shadowOffset:6},
   {surfaceOpacity:1.0,bevelWidth:5,bevelStrength:0.30,rimStrength:0.20,sheenStrength:0.09,innerShadow:0.18,shadowStrength:0.30,shadowBlur:16,shadowOffset:5},
   {surfaceOpacity:0.96,bevelWidth:2,bevelStrength:0.18,rimStrength:0.32,sheenStrength:0.08,innerShadow:0.08,shadowStrength:0.55,shadowBlur:30,shadowOffset:10}
  ]
  var preset=presets[Math.max(0,Math.min(2,name))]
  for(var k in preset) v[panel?panelKey(k):k]=preset[k]
  v[panel?panelKey("effectsEnabled"):"effectsEnabled"]=true
  v[panel?panelKey("lightAngle"):"lightAngle"]=225
  current=normalized(v); status="Live effects preview — not saved"
 }
 function refinedPreset(panel) {
  var v=clone(current)
  var values={effectsEnabled:true,surfaceOpacity:0.88,bevelStrength:0.13,bevelWidth:4,rimStrength:0.14,rimWidth:0.55,edgeProfile:2,roughness:0.65,lightX:0.25,lightY:0.03,lightSize:0.65,sheenStrength:0.08,innerShadow:0.04,shadowStrength:0.20,shadowBlur:25,shadowOffset:7,contactStrength:0.12,contactBlur:3,contactOffset:1,tintAmount:0.35,backdropBlur:true,grain:0.08,borderCustom:true,borderWidth:1,borderGradient:false,borderColor1:"#657080"}
  if(panel) { values.borderRadius=14; values.controlsEnabled=true; values.controlRadius=8; values.controlContrast=0.65; values.controlSpacing=1.05; values.textNeutrality=0.65; values.outerGap=10; values.innerPadding=18 }
  else values.borderWidth=0
  for(var k in values) v[panel?panelKey(k):k]=values[k]
  v[panel?"borderPanels":"borderBar"]=true
  current=normalized(v); status="Refined glass · live preview, not saved"
 }
 function revert() { current=clone(saved); status="Saved appearance restored" }
 function save() {
  if (pendingSave) return
  pendingSave=clone(current)
  settingsFile.setText(JSON.stringify({version:1,settings:pendingSave},null,2)+"\n")
  status="Saving…"
 }
 FileView {
  id: settingsFile
  path: root.settingsPath
  atomicWrites: true
  printErrors: false
  onLoaded: {
   if(root.ready) return
   try { var data=JSON.parse(text()); if(data.version!==1 || !data.settings) throw new Error("Unknown format"); root.saved=root.normalized(data.settings); root.current=root.clone(root.saved); root.status="Saved appearance loaded" }
   catch(e) { root.status="Unable to read saved appearance; showing defaults" }
   root.ready=true
  }
  onLoadFailed: { root.ready=true; root.status="Windows-inspired defaults" }
  onSaved: { if(root.pendingSave) { root.saved=root.pendingSave; root.pendingSave=null; root.status=root.dirty?"Saved; additional preview changes remain":"Appearance saved" } }
  onSaveFailed: { root.pendingSave=null; root.status="Save failed; preview retained" }
 }
 Component { id: attachment; SurfaceAttachment {} }
 // Restrict adaptation to the active bar popup and its outer BorderSurface.
 // No global shell objects or package files are modified.
 function attachCard(card, popup) {
  if(!card || !("borderSpec" in card) || !("padding" in card) || !("radius" in card) || !("color" in card)) return
  for(var i=0;i<attachments.length;i++) if(attachments[i] && attachments[i].card===card) return
  var item=attachment.createObject(card,{controller:root,card:card,popup:popup})
  if(item) { var a=attachments.filter(function(x){return !!x}); a.push(item); attachments=a }
 }
 function scan() {
  if(!bar || !bar.activePopout) return
  var seen=[]
  var found=false
  function visit(o,depth) {
   if(!o || depth>12 || seen.indexOf(o)>=0 || seen.length>2000) return
   seen.push(o)
   if("anchorItem" in o && "contentWidth" in o && "open" in o && "contentItem" in o) {
    var list=o.contentItem
    if(list && list.length!==undefined) for(var i=0;i<list.length;i++) {
     var parent=list[i] ? list[i].parent : null
     for(var j=0;parent && j<5;j++,parent=parent.parent) {
      if("borderSpec" in parent && "padding" in parent) { attachCard(parent,o); found=true; break }
     }
    }
   }
   for(var prop of ["children","resources","data"]) {
    if(!(prop in o)) continue
    var nodes=o[prop]
    if(nodes && nodes.length!==undefined) for(var n=0;n<nodes.length;n++) visit(nodes[n],depth+1)
   }
   if("item" in o && o.item) visit(o.item,depth+1)
  }
  visit(bar.activePopout,0)
  scanComplete=found
 }
 Connections { target: root.bar; function onActivePopoutChanged() { root.scanComplete=false; scanTimer.restart() } }
 Timer { id: scanTimer; interval: 30; onTriggered: root.scan() }
 Timer { interval: 400; running: !!root.bar.activePopout && !root.scanComplete; repeat:true; onTriggered: root.scan() }
 MaterialCompositor { controller:root; enabled:root.compositorBridgeEnabled && root.ready }
 IpcHandler {
  target: "surface-studio"
  function status(): string { return JSON.stringify({current:root.current,saved:root.saved,dirty:root.dirty,status:root.status,compositorStatus:root.compositorStatus,panels:root.attachments.length}) }
  function preview(key: string,value: string): string { try { if(!(key in root.defaults)) return "unknown setting"; root.change(key,JSON.parse(value)); return "ok" } catch(e) { return "invalid value" } }
  function save(): void { root.save() }
  function revert(): void { root.revert() }
 }
 Component.onDestruction: { for(var i=0;i<attachments.length;i++) if(attachments[i]) attachments[i].destroy() }
}
