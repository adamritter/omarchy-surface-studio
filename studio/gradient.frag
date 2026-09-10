#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf {
 mat4 qt_Matrix;
 float qt_Opacity;
 vec4 c1; vec4 c2; vec4 c3; vec4 c4;
 vec4 baseColor;
 vec2 size;
 float mode; float angle; float strength; float alpha;
 float radius; float grain;
 float effects; float lightAngle; float bevelWidth; float bevelStrength;
 float rimStrength; float sheenStrength; float innerShadow;
 float rimWidth; float edgeProfile; float roughness; float lightX; float lightY; float lightSize; float tintAmount;
 float edgeTint; float edgeTintWidth;
 float rayGlass; float glassIor; float glassThickness; float glassMix;
};
// Bounded analytic ray tracing: a beveled entrance normal, planar rear
// interface and two virtual environment planes. No desktop texture or BVH.
vec3 virtualBackdrop(vec2 p) {
 vec2 t=clamp(p/max(size,vec2(1.0)),0.0,1.0);
 vec3 tint=mix(mix(c1.rgb,c2.rgb,t.x),mix(c3.rgb,c4.rgb,t.x),t.y);
 return mix(baseColor.rgb,tint,strength);
}
vec3 reflectedEnvironment(vec3 origin, vec3 direction) {
 // Analytic intersection with a front-facing softbox plane at z = 96.
 if(direction.z<=0.001) return vec3(0.035,0.045,0.065);
 vec2 hit=origin.xy+direction.xy*(96.0/direction.z);
 vec2 lamp=vec2(lightX,lightY)*size;
 vec2 extent=vec2(32.0+lightSize*180.0,16.0+lightSize*70.0);
 vec2 q=(hit-lamp)/extent;
 float spread=1.0+roughness*3.0;
 float softbox=exp(-dot(q,q)/spread)/sqrt(spread);
 return vec3(0.055,0.07,0.10)+vec3(0.84,0.90,1.0)*softbox;
}
vec3 traceGlass(vec2 pixel, vec3 normal, vec3 substrate) {
 vec3 incident=vec3(0.0,0.0,-1.0);
 float ior=clamp(glassIor,1.0,1.8);
 float f0=pow((ior-1.0)/(ior+1.0),2.0);
 float fresnel=f0+(1.0-f0)*pow(1.0-clamp(normal.z,0.0,1.0),5.0);
 vec3 transmitted=refract(incident,normal,1.0/ior);
 float distance=glassThickness/max(-transmitted.z,0.05);
 vec3 backHit=vec3(pixel,0.0)+transmitted*distance;
 vec3 outgoing=refract(transmitted,vec3(0.0,0.0,1.0),ior);
 vec3 reflected=reflectedEnvironment(vec3(pixel,0.0),reflect(incident,normal));
 // Total internal reflection at the rear surface: a single bounded bounce.
 if(dot(outgoing,outgoing)<0.001) {
  vec3 bounce=reflect(transmitted,vec3(0.0,0.0,1.0));
  return mix(substrate,reflectedEnvironment(backHit,bounce),0.65);
 }
 vec2 backdropHit=backHit.xy+outgoing.xy*(32.0/max(-outgoing.z,0.05));
 vec3 shifted=virtualBackdrop(backdropHit)-virtualBackdrop(pixel);
 vec3 attenuation=exp(-vec3(0.008,0.004,0.002)*distance);
 vec3 through=max(vec3(0.0),substrate+shifted*(1.0-roughness*0.7))*attenuation;
 return mix(through,reflected,fresnel);
}
void main() {
 vec2 uv=qt_TexCoord0;
 vec4 col;
 if(mode<0.5) col=mix(mix(c1,c2,uv.x),mix(c3,c4,uv.x),uv.y);
 else if(mode<1.5) {
  vec2 dir=vec2(cos(angle),sin(angle));
  float t=clamp(0.5+dot(uv-0.5,dir)/(abs(dir.x)+abs(dir.y)),0.0,1.0)*3.0;
  col=t<1.0?mix(c1,c2,t):(t<2.0?mix(c2,c3,t-1.0):mix(c3,c4,t-2.0));
 } else {
  float t=clamp(length((uv-vec2(0.32,0.25))*vec2(1.0,0.85))*1.5,0.0,1.0)*3.0;
  col=t<1.0?mix(c1,c2,t):(t<2.0?mix(c2,c3,t-1.0):mix(c3,c4,t-2.0));
 }
 if(effects>0.5) {
  float luminance=dot(col.rgb,vec3(0.2126,0.7152,0.0722));
  col.rgb=mix(vec3(luminance),col.rgb,tintAmount);
 }
 float r=min(radius,min(size.x,size.y)*0.5);
 vec2 d=abs(uv*size-size*0.5)-(size*0.5-vec2(r));
 float sd=length(max(d,0.0))+min(max(d.x,d.y),0.0)-r;
 // Preserve full tint at the edges while calming the center.
 float edgeWeight=exp(-max(0.0,-sd)/max(edgeTintWidth,1.0));
 float localStrength=strength*mix(1.0,edgeWeight,edgeTint);
 col=mix(baseColor,col,localStrength);
 float noise=fract(sin(dot(uv*size,vec2(12.9898,78.233)))*43758.5453)-0.5;
 col.rgb=clamp(col.rgb+noise*grain*0.035,0.0,1.0);
 // The item bounds already clip straight edges. Antialiasing those edges
 // makes the outer pixel translucent, especially at fractional display scales.
 // Only curved corner pixels need the signed-distance coverage ramp.
 float coverage=(r<=0.0 || d.x<=0.0 || d.y<=0.0)
   ? 1.0 : 1.0-smoothstep(-0.7,0.7,sd);
 if(effects>0.5) {
  vec2 centered=uv*size-size*0.5;
  vec2 corner=max(abs(centered)-(size*0.5-vec2(r)),0.0);
  vec2 normal;
  if(corner.x>0.0 && corner.y>0.0) normal=normalize(corner)*sign(centered);
  else if(size.x*0.5-abs(centered.x)<size.y*0.5-abs(centered.y)) normal=vec2(sign(centered.x),0.0);
  else normal=vec2(0.0,sign(centered.y));
  float inside=max(0.0,-sd);
  float profile=clamp(1.0-inside/max(bevelWidth,1.0),0.0,1.0);
  float tilt=edgeProfile<0.5?0.0:(edgeProfile<1.5?sin(profile*1.5707963):pow(profile,2.0));
  vec3 N=normalize(vec3(normal*tilt,1.0-tilt*0.65));
  vec2 lamp=vec2(lightX,lightY);
  vec3 L=normalize(vec3((lamp-uv)*1.6,0.65+lightSize));
  vec3 H=normalize(L+vec3(0.0,0.0,1.0));
  float effectiveRough=clamp(roughness+lightSize*0.22,0.05,1.0);
  float exponent=mix(150.0,4.0,effectiveRough*effectiveRough);
  float specular=pow(max(dot(N,H),0.0),exponent);
  float flatSpecular=pow(max(H.z,0.0),exponent);
  float edgeSpecular=max(0.0,specular-flatSpecular*0.8);
  vec2 lightDir=vec2(cos(lightAngle),sin(lightAngle));
  float diffuse=dot(normal,normalize((lamp-uv)+lightDir*0.25));
  float rim=exp(-inside/max(rimWidth,0.25));
  vec3 lightColor=vec3(0.94,0.97,1.0);
  col.rgb+=lightColor*(max(diffuse,0.0)*tilt*bevelStrength*0.18+edgeSpecular*bevelStrength*0.65);
  col.rgb+=lightColor*rim*rimStrength*(0.18+0.35*max(diffuse,0.0));
  col.rgb*=1.0-max(-diffuse,0.0)*(tilt*bevelStrength*0.25+exp(-inside/7.0)*innerShadow*0.45);
  col.rgb+=lightColor*flatSpecular*sheenStrength*0.20;
  if(rayGlass>0.5) {
   // A curved optical edge; preserve the existing silhouette and alpha mask.
   float opticalTilt=sin(profile*1.45);
   vec3 opticalNormal=normalize(vec3(normal*opticalTilt,cos(profile*1.45)));
   col.rgb=mix(col.rgb,traceGlass(uv*size,opticalNormal,col.rgb),glassMix);
  }
  col.rgb=clamp(col.rgb,0.0,1.0);
 }
 float a=alpha*coverage*qt_Opacity;
 fragColor=vec4(col.rgb*a,a);
}
