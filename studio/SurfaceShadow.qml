import QtQuick
ShaderEffect {
 id: root
 property var settings: ({})
 property real cardWidth: parent ? parent.width : 0
 property real cardHeight: parent ? parent.height : 0
 // Allowed drawing bounds in card-local coordinates.
 property vector4d clipBounds: Qt.vector4d(-100000,-100000,100000,100000)
 property real radius: 0
 property real softness: settings.shadowBlur === undefined ? 18 : settings.shadowBlur
 property vector2d shadowDirection: {
  if(!settings.coherentLight) return Qt.vector2d(0,1)
  var dx=0.5-(settings.lightX===undefined?0.2:settings.lightX)
  var dy=0.5-(settings.lightY===undefined?0.05:settings.lightY)
  var length=Math.sqrt(dx*dx+dy*dy)
  return length>0.001?Qt.vector2d(dx/length,dy/length):Qt.vector2d(0,1)
 }
 property real offset: settings.shadowOffset === undefined ? 6 : settings.shadowOffset
 property real strength: settings.shadowStrength || 0
 property real contactStrength: settings.contactStrength || 0
 property real contactBlur: settings.contactBlur === undefined ? 3 : settings.contactBlur
 property real contactOffset: settings.contactOffset === undefined ? 1 : settings.contactOffset
 property real padding: Math.max(softness*2+offset,contactBlur*2+contactOffset)+2
 property vector2d size: Qt.vector2d(width,height)
 property vector2d cardSize: Qt.vector2d(cardWidth,cardHeight)
 x:-padding; y:-padding
 width:cardWidth+padding*2; height:cardHeight+padding*2
 visible: !!settings.effectsEnabled && (strength>0 || contactStrength>0)
 fragmentShader:Qt.resolvedUrl("shadow.frag.qsb")
}
