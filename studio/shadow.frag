#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf {
 mat4 qt_Matrix; float qt_Opacity;
 vec2 size; vec2 cardSize;
 float padding; float radius; float softness; float offset; float strength;
 float contactStrength; float contactBlur; float contactOffset;
 vec4 clipBounds;
 vec2 shadowDirection;
 float naturalShadow;
};
float distanceToCard(vec2 p) {
 float r=min(radius,min(cardSize.x,cardSize.y)*0.5);
 vec2 d=abs(p-cardSize*0.5)-(cardSize*0.5-vec2(r));
 return length(max(d,0.0))+min(max(d.x,d.y),0.0)-r;
}
// Smooth half-plane occlusion approximation, unlike a saturated distance halo.
float occlusion(float distance, float spread) {
 float x=clamp(distance/max(spread,0.5),-12.0,12.0);
 return 1.0/(1.0+exp(x*1.7));
}
void main() {
 vec2 p=qt_TexCoord0*size-vec2(padding);
 // Keep full-screen popup shadows out of the bar, including its blur mask.
 if(p.x<clipBounds.x || p.y<clipBounds.y || p.x>=clipBounds.z || p.y>=clipBounds.w) {
  fragColor=vec4(0.0);
  return;
 }
 float original=distanceToCard(p);
 float shifted=distanceToCard(p-shadowDirection*offset);
 float falloff=exp(-pow(max(shifted,0.0)/max(softness*0.48,1.0),2.0));
 // Do not paint behind the translucent fill: the shadow is outside the card.
 float outside=smoothstep(-0.6,0.6,original);
 float nearDistance=distanceToCard(p-shadowDirection*contactOffset);
 float nearFalloff=exp(-pow(max(nearDistance,0.0)/max(contactBlur,1.0),2.0));
 float combined=1.0-(1.0-falloff*strength)*(1.0-nearFalloff*contactStrength);
 if(naturalShadow>0.5) {
  float r=min(radius,min(cardSize.x,cardSize.y)*0.5);
  vec2 centered=p-cardSize*0.5;
  vec2 corner=max(abs(centered)-(cardSize*0.5-vec2(r)),vec2(0.0));
  vec2 n;
  if(length(corner)>0.001) n=normalize(corner)*sign(centered);
  else n=(cardSize.x*0.5-abs(centered.x)<cardSize.y*0.5-abs(centered.y))
    ? vec2(sign(centered.x),0.0) : vec2(0.0,sign(centered.y));
  float downstream=smoothstep(-0.5,1.0,dot(n,shadowDirection));
  // The receiving side has a broad penumbra; the light-facing edge stays quiet.
  float spread=max(1.0,softness*mix(0.12,0.40,downstream));
  float ambient=occlusion(shifted,spread)*mix(0.16,0.85,downstream)*strength;
  float contact=occlusion(nearDistance,max(0.65,contactBlur*0.65))
    *mix(0.18,0.9,downstream)*contactStrength;
  combined=1.0-(1.0-ambient)*(1.0-contact);
  // Fade tails before the padded render boundary, avoiding a rectangular cutoff.
  float boundary=min(min(p.x+padding,p.y+padding),min(cardSize.x+padding-p.x,cardSize.y+padding-p.y));
  combined*=smoothstep(0.0,max(2.0,softness*0.25),boundary);
 }

 float a=combined*outside*qt_Opacity;
 fragColor=vec4(0.0,0.0,0.0,a);
}
