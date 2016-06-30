precision mediump float;

#define beat1 (texture2D(iChannel0, vec2(0.1)).r * 2.)
#define beat2 (texture2D(iChannel0, vec2(0.8)).r * 2.)

vec2 doModel(vec3 p, vec2 beats);

vec2 calcRayIntersection_2_0(vec3 rayOrigin, vec3 rayDir, float maxd, float precis, vec2 beats) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 90; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = doModel(rayOrigin + rayDir * dist, beats);

    latest = result.x;
    type   = result.y;
    dist  += latest;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_2_0(vec3 rayOrigin, vec3 rayDir, vec2 beats) {
  return calcRayIntersection_2_0(rayOrigin, rayDir, 20.0, 0.001, beats);
}



vec3 calcNormal_4_1(vec3 pos, float eps, vec2 beats) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * doModel( pos + v1*eps, beats ).x +
                    v2 * doModel( pos + v2*eps, beats ).x +
                    v3 * doModel( pos + v3*eps, beats ).x +
                    v4 * doModel( pos + v4*eps, beats ).x );
}

vec3 calcNormal_4_1(vec3 pos, vec2 beats) {
  return calcNormal_4_1(pos, 0.002, beats);
}

vec4 texcube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}



float orenNayarDiffuse_3_2(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float roughness,
  float albedo) {

  float LdotV = dot(lightDirection, viewDirection);
  float NdotL = dot(lightDirection, surfaceNormal);
  float NdotV = dot(surfaceNormal, viewDirection);

  float s = LdotV - NdotL * NdotV;
  float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

  float sigma2 = roughness * roughness;
  float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
  float B = 0.45 * sigma2 / (sigma2 + 0.09);

  return albedo * max(0.0, NdotL) * (A + B * s / t) / 3.14159265;
}


float gaussianSpecular_5_3(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float shininess) {
  vec3 H = normalize(lightDirection + viewDirection);
  float theta = acos(dot(H, surfaceNormal));
  float w = theta / shininess;
  return exp(-w*w);
}


//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec4 mod289_1_4(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289_1_4(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute_1_5(vec4 x) {
     return mod289_1_4(((x*34.0)+1.0)*x);
}

float permute_1_5(float x) {
     return mod289_1_4(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt_1_6(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt_1_6(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4_1_7(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;

  return p;
  }

// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise_1_8(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289_1_4(i);
  float j0 = permute_1_5( permute_1_5( permute_1_5( permute_1_5(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute_1_5( permute_1_5( permute_1_5( permute_1_5 (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0_1_9 = grad4_1_7(j0,   ip);
  vec4 p1 = grad4_1_7(j1.x, ip);
  vec4 p2 = grad4_1_7(j1.y, ip);
  vec4 p3 = grad4_1_7(j1.z, ip);
  vec4 p4 = grad4_1_7(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt_1_6(vec4(dot(p0_1_9,p0_1_9), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0_1_9 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt_1_6(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0_1_9, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }



float fogFactorExp2_6_10(
  const float dist,
  const float density
) {
  const float LOG2 = -1.442695;
  float d = density * dist;
  return 1.0 - clamp(exp2(d * d * LOG2), 0.0, 1.0);
}

//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise3(vec3 v)
  {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
  }



const float PI_7_11 = 3.14159265359;




vec3 ta = vec3(0, 0, iChannelTime[0] * 2.75);
vec3 ro = ta - vec3(0, 0, 2.5);
vec3 l1 = ro + vec3(0, sin(iChannelTime[0] * 5.) * 0.5, 11.25 + cos(iChannelTime[0] * 0.97) * 9.);
vec3 l2 = ta + vec3(0, 0, 5.25 + sin(iChannelTime[0] * 0.85) * 7.);
vec3 c1 = vec3(0.1, 0.3, 0.9) * 1.;
vec3 c2 = vec3(0.4, 0.1, 0.2) * 1.;
vec3 c3 = vec3(0.3, 0.08, 0.05) * 0.25;
vec3 bg = vec3(0.2, 0.5, 0.925);

vec2 path(float progress) {
  return 1.2 * vec2(cos(progress * 0.59), 1.5 * sin(progress * 0.5));
}

vec2 sU(vec2 p1, vec2 p2) {
  return p1.x > p2.x ? p2 : p1;
}

float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

vec2 doModel(vec3 p, vec2 beats) {
  float m = snoise3(p.xyz);
  float n  = beats.x * m * 0.2 + beats.x;

  float r  = n + 2.0 + sin(p.z + p.y * 2. + iChannelTime[0] * 2.) * 0.35;
  float d1 = r - length(p.xy - path(p.z));
  float d2 = length(p - l2) - 0.125 * beats.y;
  float d3 = length(p - l1) - 0.125 * beats.x;

  d1 = -d1;
  d1 = smin(d1, length(p - l2) - 3.0, 4.05);
  d1 = smin(d1, length(p - l1) - 3.0, 4.05);
  d1 = -d1;

  return sU(
    vec2(d1, clamp(n, 0., 0.99)),
    sU(
      vec2(d2, 1.0),
      vec2(d3, 2.0)
    )
  );
}

float attenuate(float d) {
  return pow(clamp(1.0 - d / 20.0, 0.0, 1.0), 2.95);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 color = bg;

  float rotation = 0.0;
  float height   = 0.0;
  float dist     = 5.9;

  vec2 uv = (fragCoord.xy - iResolution.xy * 0.5) / iResolution.y;

  ta.xy += path(ta.z);
  ro.xy += path(ro.z);
  l1.xy += path(l1.z);
  l2.xy += path(l2.z);

  float fov = PI_7_11 / 1.5;
  vec3 forward = normalize(ta - ro);
  vec3 right = normalize(vec3(forward.z, 0, -forward.x));
  vec3 up = cross(forward, right);
  vec3 rd = normalize(forward + fov * uv.x * right + fov * uv.y * up);

  vec2 beats = vec2(beat1, beat2);

  vec2 t = calcRayIntersection_2_0(ro, rd, 40., 0.001, beats);
  if (t.x > -0.5) {
    vec3 surface;

    if (t.y == 1.0) {
      surface = c2 * 5. * beat2;
    } else
    if (t.y == 2.0) {
      surface = c1 * 4. * beat1;
    } else {
      vec3 pos = ro + rd * t.x;
      vec3 nor = calcNormal_4_1(pos, beats);
      vec3 mat = vec3(1.0, 0.8, 0.7);

      vec3 d1 = normalize(l1 - pos);
      vec3 d2 = normalize(l2 - pos);

      float attn1 = attenuate(length(l1 - pos));
      float attn2 = attenuate(length(l2 - pos));
      float diff1 = orenNayarDiffuse_3_2(d1, -rd, nor, 0.29, 2.5 * beat1);
      float diff2 = orenNayarDiffuse_3_2(d2, -rd, nor, 0.29, 3.5 * beat2);
      float spec1 = gaussianSpecular_5_3(d1, -rd, nor, 0.08) * beat1;
      float spec2 = gaussianSpecular_5_3(d2, -rd, nor, 0.08) * beat2;

      float glow = max(0., pow(clamp(2. * (t.y - 0.8), 0., 1.), 1.5) * 3.);


      surface = (
        c3 * glow * max(0., dot(nor, normalize(ro - pos))) +
        (c1 * spec1 * attn1 + c2 * spec2 * attn2) +
        (c1 * diff1 * attn1 + c2 * diff2 * attn2) * mat
      );
    }

    color = mix(surface, color, fogFactorExp2_6_10(t.x, 0.055));
  }

  color = pow(color, vec3(0.75));
  color.r = smoothstep(-0.1, 0.975, color.r);
  color *= vec3(1.0) - dot(uv, uv) * 0.65;

  fragColor.rgb = color;
  fragColor.a   = 1.0;
}
