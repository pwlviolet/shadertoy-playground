// https://www.youtube.com/watch?v=0RWaR7zApEo&ab_channel=TheArtofCode
#define IS_IN_SHADERTOY 0
#if IS_IN_SHADERTOY==1
#define iChannel0Cube iChannel0
#endif
#define SHOW_ISOLINE 0

// consts
const float PI=3.14159265359;

const float TWO_PI=6.28318530718;

// sdf ops
float opUnion(float d1,float d2)
{
    return min(d1,d2);
}

vec2 opUnion(vec2 d1,vec2 d2)
{
    return(d1.x<d2.x)?d1:d2;
}

// ray
vec2 normalizeScreenCoords(vec2 screenCoord,vec2 resolution)
{
    vec2 result=2.*(screenCoord/resolution.xy-.5);
    result.x*=resolution.x/resolution.y;// Correct for aspect ratio
    return result;
}

mat3 setCamera(in vec3 ro,in vec3 ta,float cr)
{
    vec3 cw=normalize(ta-ro);
    vec3 cp=vec3(sin(cr),cos(cr),0.);
    vec3 cu=normalize(cross(cw,cp));
    vec3 cv=(cross(cu,cw));
    return mat3(cu,cv,cw);
}

vec3 getRayDirection(vec2 p,vec3 ro,vec3 ta,float fl){
    mat3 ca=setCamera(ro,ta,0.);
    vec3 rd=ca*normalize(vec3(p,fl));
    return rd;
}

// lighting
// https://learnopengl.com/Lighting/Basic-Lighting

float saturate(float a){
    return clamp(a,0.,1.);
}

float diffuse(vec3 n,vec3 l){
    float diff=saturate(dot(n,l));
    return diff;
}

float specular(vec3 n,vec3 l,float shininess){
    float spec=pow(saturate(dot(n,l)),shininess);
    return spec;
}

// rotate
mat2 rotation2d(float angle){
    float s=sin(angle);
    float c=cos(angle);
    
    return mat2(
        c,-s,
        s,c
    );
}

mat4 rotation3d(vec3 axis,float angle){
    axis=normalize(axis);
    float s=sin(angle);
    float c=cos(angle);
    float oc=1.-c;
    
    return mat4(
        oc*axis.x*axis.x+c,oc*axis.x*axis.y-axis.z*s,oc*axis.z*axis.x+axis.y*s,0.,
        oc*axis.x*axis.y+axis.z*s,oc*axis.y*axis.y+c,oc*axis.y*axis.z-axis.x*s,0.,
        oc*axis.z*axis.x-axis.y*s,oc*axis.y*axis.z+axis.x*s,oc*axis.z*axis.z+c,0.,
        0.,0.,0.,1.
    );
}

vec2 rotate(vec2 v,float angle){
    return rotation2d(angle)*v;
}

vec3 rotate(vec3 v,vec3 axis,float angle){
    return(rotation3d(axis,angle)*vec4(v,1.)).xyz;
}

mat3 rotation3dX(float angle){
    float s=sin(angle);
    float c=cos(angle);
    
    return mat3(
        1.,0.,0.,
        0.,c,s,
        0.,-s,c
    );
}

vec3 rotateX(vec3 v,float angle){
    return rotation3dX(angle)*v;
}

mat3 rotation3dY(float angle){
    float s=sin(angle);
    float c=cos(angle);
    
    return mat3(
        c,0.,-s,
        0.,1.,0.,
        s,0.,c
    );
}

vec3 rotateY(vec3 v,float angle){
    return rotation3dY(angle)*v;
}

mat3 rotation3dZ(float angle){
    float s=sin(angle);
    float c=cos(angle);
    
    return mat3(
        c,s,0.,
        -s,c,0.,
        0.,0.,1.
    );
}

vec3 rotateZ(vec3 v,float angle){
    return rotation3dZ(angle)*v;
}

// gamma
const float gamma=2.2;

float toGamma(float v){
    return pow(v,1./gamma);
}

vec2 toGamma(vec2 v){
    return pow(v,vec2(1./gamma));
}

vec3 toGamma(vec3 v){
    return pow(v,vec3(1./gamma));
}

vec4 toGamma(vec4 v){
    return vec4(toGamma(v.rgb),v.a);
}

// sdf
float sdBox(vec3 p,vec3 b)
{
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

float sdRhombicTriacontahedron(vec3 p)
{
    float d=sdBox(p,vec3(1));
    
    float c=cos(3.1415/5.),s=sqrt(.75-c*c);
    vec3 n=vec3(-.5,-c,s);
    
    p=abs(p);
    p-=2.*min(0.,dot(p,n))*n;
    
    p.xy=abs(p.xy);
    p-=2.*min(0.,dot(p,n))*n;
    
    p.xy=abs(p.xy);
    p-=2.*min(0.,dot(p,n))*n;
    
    d=p.z-1.;
    return d;
}

vec2 map(in vec3 pos)
{
    vec2 res=vec2(1e10,0.);
    
    {
        vec3 d1p=pos;
        // float d1=sdBox(d1p,vec3(.5));
        d1p.xz=rotate(d1p.xz,iTime*.1);
        float d1=sdRhombicTriacontahedron(d1p);
        res=opUnion(res,vec2(d1,114514.));
    }
    
    return res;
}

vec2 raycast(in vec3 ro,in vec3 rd,float side){
    vec2 res=vec2(-1.,-1.);
    float t=0.;
    for(int i=0;i<64;i++)
    {
        vec3 p=ro+t*rd;
        vec2 h=map(p)*side;
        if(abs(h.x)<.001*t)
        {
            res=vec2(t,h.y);
            break;
        };
        t+=h.x;
    }
    return res;
}

vec3 calcNormal(vec3 pos,float eps){
    const vec3 v1=vec3(1.,-1.,-1.);
    const vec3 v2=vec3(-1.,-1.,1.);
    const vec3 v3=vec3(-1.,1.,-1.);
    const vec3 v4=vec3(1.,1.,1.);
    
    return normalize(v1*map(pos+v1*eps).x+
    v2*map(pos+v2*eps).x+
    v3*map(pos+v3*eps).x+
    v4*map(pos+v4*eps).x);
}

vec3 calcNormal(vec3 pos){
    return calcNormal(pos,.002);
}

vec3 drawIsoline(vec3 col,vec3 pos){
    float d=map(pos).x;
    col*=1.-exp(-6.*abs(d));
    col*=.8+.2*cos(150.*d);
    col=mix(col,vec3(1.),1.-smoothstep(0.,.01,abs(d)));
    return col;
}

vec3 material(in vec3 col,in vec3 pos,in float m,in vec3 nor){
    col=vec3(1.);
    
    if(m==114514.){
        if(SHOW_ISOLINE==1){
            col=drawIsoline(col,vec3(pos.x*1.,pos.y*0.,pos.z*1.));
        }
    }
    
    return col;
}

vec3 getRdOut(vec3 rdIn,vec3 norExit,float ior){
    vec3 rdOut=refract(rdIn,norExit,ior);
    if(dot(rdOut,rdOut)==0.){
        rdOut=reflect(rdIn,norExit);
    }
    return rdOut;
}

vec3 RGBShift(samplerCube tex,vec3 rUv,vec3 gUv,vec3 bUv){
    float r=texture(tex,rUv).r;
    float g=texture(tex,gUv).g;
    float b=texture(tex,bUv).b;
    return vec3(r,g,b);
}

float fresnel(float bias,float scale,float power,vec3 I,vec3 N)
{
    return bias+scale*pow(1.+dot(I,N),power);
}

vec3 lighting(in vec3 col,in vec3 pos,in vec3 rd,in vec3 nor,in float t){
    vec3 lin=col;
    
    // refraction
    {
        float ior=1.49;
        float ca=.01;
        vec3 reflTex=vec3(0.);
        
        // Do Refraction
        vec3 rdIn=refract(rd,nor,1./ior);// ray direction when entering
        vec3 pEnter=pos-nor*.001*t*3.;
        float dIn=raycast(pEnter,rdIn,-1.).x;// inside the object
        
        vec3 pExit=pEnter+rdIn*dIn;// 3d position of exit
        vec3 norExit=-calcNormal(pExit);
        
        // vec3 rdOut=getRdOut(rdIn,norExit,ior);
        // reflTex=texture(iChannel0Cube,rdOut).xyz;
        
        // Chromatic Aberration
        vec3 rUv=getRdOut(rdIn,norExit,ior-ca);
        vec3 gUv=getRdOut(rdIn,norExit,ior);
        vec3 bUv=getRdOut(rdIn,norExit,ior+ca);
        vec3 rgbTex=RGBShift(iChannel0Cube,rUv,gUv,bUv);
        reflTex=rgbTex;
        
        // Color
        // vec3 gemColor=vec3(1.,.05,.2);
        // reflTex*=gemColor;
        
        // Optical Density
        float dens=.1;
        float optDist=exp(-dIn*dens);
        reflTex*=optDist;
        
        // Fresnel
        float fre=fresnel(0.,1.,5.,rd,nor);
        // reflTex=vec3(fre);
        vec3 reflOutside=texture(iChannel0Cube,reflect(rd,nor)).xyz;
        reflTex=mix(reflTex,reflOutside,fre);
        
        lin=reflTex;
    }
    
    return lin;
}

vec3 render(in vec3 ro,in vec3 rd){
    vec3 col=texture(iChannel0Cube,rd).xyz;
    
    vec2 res=raycast(ro,rd,1.);// outside of object
    float t=res.x;
    float m=res.y;
    
    if(m>-.5){
        vec3 pos=ro+t*rd;
        
        vec3 nor=(m<1.5)?vec3(0.,1.,0.):calcNormal(pos);
        
        col=material(col,pos,m,nor);
        
        col=lighting(col,pos,rd,nor,t);
    }
    
    return col;
}

vec3 getSceneColor(vec2 fragCoord){
    vec2 p=normalizeScreenCoords(fragCoord,iResolution.xy);
    
    vec3 ro=vec3(0.,4.,8.);
    vec3 ta=vec3(0.,0.,0.);
    const float fl=4.5;
    
    vec2 m=iMouse.xy/iResolution.xy;
    ro.yz=rotate(ro.yz,-m.y*PI+1.);
    ro.xz=rotate(ro.xz,-m.x*TWO_PI);
    
    vec3 rd=getRayDirection(p,ro,ta,fl);
    
    // render
    vec3 col=render(ro,rd);
    
    // gamma
    col=toGamma(col);
    
    return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec3 tot=vec3(0.);
    
    float AA_size=1.;
    float count=0.;
    for(float aaY=0.;aaY<AA_size;aaY++)
    {
        for(float aaX=0.;aaX<AA_size;aaX++)
        {
            tot+=getSceneColor(fragCoord+vec2(aaX,aaY)/AA_size);
            count+=1.;
        }
    }
    tot/=count;
    
    fragColor=vec4(tot,1.);
}