import QtQuick
ShaderEffect {
 id: root
 property var settings: ({})
 property real cardWidth: parent ? parent.width : 0
 property real cardHeight: parent ? parent.height : 0
 property real radius: 0
 property real softness: settings.shadowBlur === undefined ? 18 : settings.shadowBlur
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
