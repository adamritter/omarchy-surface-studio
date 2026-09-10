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
};
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
 col=mix(baseColor,col,strength);
 float noise=fract(sin(dot(uv*size,vec2(12.9898,78.233)))*43758.5453)-0.5;
 col.rgb=clamp(col.rgb+noise*grain*0.035,0.0,1.0);
 float r=min(radius,min(size.x,size.y)*0.5);
 vec2 d=abs(uv*size-size*0.5)-(size*0.5-vec2(r));
 float sd=length(max(d,0.0))+min(max(d.x,d.y),0.0)-r;
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
  col.rgb=clamp(col.rgb,0.0,1.0);
 }
 float a=alpha*coverage*qt_Opacity;
 fragColor=vec4(col.rgb*a,a);
}
