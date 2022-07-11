#define SHOW_ISOLINE 1

// consts
const float PI=3.14159265359;

const float TWO_PI=6.28318530718;

// utils
float minSon(vec2 v)
{
    return min(v.x,v.y);
}

float minSon(vec3 v)
{
    return min(v.x,min(v.y,v.z));
}

float maxSon(vec2 v){
    return max(v.x,v.y);
}

float maxSon(vec3 v){
    return max(v.x,max(v.y,v.z));
}

// sdf ops
float opRound(in float d,in float h)
{
    return d-h;
}

float opInverse(float d)
{
    float result=-d;
    return result;
}

float opOffset(float d,float v)
{
    return d-v;
}

float opIntersection(float d1,float d2)
{
    return max(d1,d2);
}

float opDifference(float d1,float d2)
{
    return opIntersection(d1,opInverse(d2));
}

float opClearance(float d1,float d2,float v)
{
    return opDifference(d1,opOffset(d2,v));
}

float opShell(float d1,float v)
{
    return opClearance(d1,d1,-abs(v));
}

float opExtrusion(in vec3 p,in float sdf,in float h)
{
    vec2 w=vec2(sdf,abs(p.z)-h);
    return min(max(w.x,w.y),0.)+length(max(w,0.));
}

float hypot(vec2 p)
{
    return sqrt(p.x*p.x+p.y*p.y);
}

float getRoundScale(float round){
    return 1.-min(round,.99);
}

float opUnion(float d1,float d2)
{
    return min(d1,d2);
}

vec2 opUnion(vec2 d1,vec2 d2)
{
    return(d1.x<d2.x)?d1:d2;
}

float opHalfX(float sdf,vec3 pos){
    return max(sdf,pos.x);
}

float opHalfY(float sdf,vec3 pos){
    return max(sdf,pos.y);
}

float opHalfZ(float sdf,vec3 pos){
    return max(sdf,pos.z);
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

// https://www.shadertoy.com/view/4scSW4
float fresnel(float bias,float scale,float power,vec3 I,vec3 N)
{
    return bias+scale*pow(1.+dot(I,N),power);
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
float sdEllipsoid(vec3 p,vec3 r)
{
    float k0=length(p/r);
    float k1=length(p/(r*r));
    return k0*(k0-1.)/k1;
}

float sdSphere(vec3 p,float r,vec3 scale,float zoom,float shell)
{
    float sc=minSon(scale);
    float ss=zoom-shell*sc*.3;
    float dt=sdEllipsoid(p/ss/scale,vec3(r))*ss*sc;
    if(shell>0.){
        dt=opShell(dt,shell);
    }
    return dt;
}

vec2 map(in vec3 pos)
{
    vec2 res=vec2(1e10,0.);
    
    {
        vec3 d1p=pos;
        // float d1=sdSphere(d1p,.5,vec3(1.,1.,1.),1.,0.);
        float d1=sdSphere(d1p,.5,vec3(2.,2.,1.),1.,.1);
        res=opUnion(res,vec2(d1,114514.));
    }
    
    return res;
}

vec2 raycast(in vec3 ro,in vec3 rd){
    vec2 res=vec2(-1.,-1.);
    float t=0.;
    for(int i=0;i<64;i++)
    {
        vec3 p=ro+t*rd;
        vec2 h=map(p);
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

float softshadow(in vec3 ro,in vec3 rd,in float mint,in float tmax)
{
    float res=1.;
    float t=mint;
    for(int i=0;i<16;i++)
    {
        float h=map(ro+rd*t).x;
        res=min(res,8.*h/t);
        t+=clamp(h,.02,.10);
        if(h<.001||t>tmax)break;
    }
    return clamp(res,0.,1.);
}

float ao(in vec3 pos,in vec3 nor)
{
    float occ=0.;
    float sca=1.;
    for(int i=0;i<5;i++)
    {
        float hr=.01+.12*float(i)/4.;
        vec3 aopos=nor*hr+pos;
        float dd=map(aopos).x;
        occ+=-(dd-hr)*sca;
        sca*=.95;
    }
    return clamp(1.-3.*occ,0.,1.);
}

vec3 drawIsoline(vec3 col,vec3 pos){
    float d=map(pos).x;
    col*=1.-exp(-6.*abs(d));
    col*=.8+.2*cos(150.*d);
    col=mix(col,vec3(1.),1.-smoothstep(0.,.01,abs(d)));
    return col;
}

vec3 material(in vec3 col,in vec3 pos,in float m,in vec3 nor){
    col=vec3(153.,204.,255.)/255.;
    
    if(m==1.){
        col=vec3(0.,0.,0.)/255.;
    }
    
    if(m==114514.){
        if(SHOW_ISOLINE==1){
            col=drawIsoline(col,vec3(pos.x*1.,pos.y*0.,pos.z*1.));
        }
    }
    
    return col;
}

vec3 lighting(in vec3 col,in vec3 pos,in vec3 rd,in vec3 nor){
    vec3 lin=col;
    
    // sun
    {
        vec3 lig=normalize(vec3(1.,1.,1.));
        float dif=diffuse(nor,lig);
        float spe=specular(nor,lig,3.);
        lin+=col*dif*spe;
    }
    
    // sky
    {
        lin*=col*.7;
    }
    
    return lin;
}

vec3 render(in vec3 ro,in vec3 rd){
    vec3 col=vec3(10.,10.,10.)/255.;
    
    vec2 res=raycast(ro,rd);
    float t=res.x;
    float m=res.y;
    
    if(m>-.5){
        vec3 pos=ro+t*rd;
        
        vec3 nor=(m<1.5)?vec3(0.,1.,0.):calcNormal(pos);
        
        col=material(col,pos,m,nor);
        
        col=lighting(col,pos,rd,nor);
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