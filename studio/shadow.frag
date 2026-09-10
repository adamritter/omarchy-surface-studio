#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf {
 mat4 qt_Matrix; float qt_Opacity;
 vec2 size; vec2 cardSize;
 float padding; float radius; float softness; float offset; float strength;
 float contactStrength; float contactBlur; float contactOffset;
};
float distanceToCard(vec2 p) {
 float r=min(radius,min(cardSize.x,cardSize.y)*0.5);
 vec2 d=abs(p-cardSize*0.5)-(cardSize*0.5-vec2(r));
 return length(max(d,0.0))+min(max(d.x,d.y),0.0)-r;
}
void main() {
 vec2 p=qt_TexCoord0*size-vec2(padding);
 float original=distanceToCard(p);
 float shifted=distanceToCard(p-vec2(0.0,offset));
 float falloff=exp(-pow(max(shifted,0.0)/max(softness*0.48,1.0),2.0));
 // Do not paint behind the translucent fill: the shadow is outside the card.
 float outside=smoothstep(-0.6,0.6,original);
 float nearDistance=distanceToCard(p-vec2(0.0,contactOffset));
 float nearFalloff=exp(-pow(max(nearDistance,0.0)/max(contactBlur,1.0),2.0));
 float combined=1.0-(1.0-falloff*strength)*(1.0-nearFalloff*contactStrength);
 float a=combined*outside*qt_Opacity;
 fragColor=vec4(0.0,0.0,0.0,a);
}
