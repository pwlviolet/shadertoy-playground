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

float sdSphere(vec3 p,float s)
{
    return length(p)-s;
}

vec2 centerUv(vec2 uv,vec2 resolution){
    uv-=vec2(.5);
    float aspect=resolution.x/resolution.y;
    uv.x*=aspect;
    return uv;
}

float sdGyroid(vec3 p,float scale,float thickness,float bias){
    p*=scale;
    float d=dot(sin(p),cos(p.zxy));
    float g=abs(d-bias);
    return g/scale-thickness;
}

float opIntersection(float d1,float d2)
{
    return max(d1,d2);
}

vec3 cosPalette(float t,vec3 a,vec3 b,vec3 c,vec3 d){
    return a+b*cos(6.28318*(c*t+d));
}

float saturate(float a){
    return clamp(a,0.,1.);
}

vec3 sphereColor(vec3 p){
    float amount=saturate((1.5-length(p))/2.);
    vec3 uBrightness=vec3(128.,128.,128.)/255.;
    vec3 uContrast=vec3(128.,128.,128.)/255.;
    vec3 uOscilation=vec3(217.,252.,251.)/255.;
    vec3 uPhase=vec3(60.,79.,130.)/255.;
    float uOscilationPower=1.8;
    vec3 col=cosPalette(amount,uBrightness,uContrast,uOscilationPower*uOscilation,uPhase);
    return col*amount;
}

vec2 sdf(vec3 p){
    vec3 p1=rotate(p,vec3(0.,1.,1.),2.*iTime*.1);
    float sphere=sdSphere(p1,1.);
    float scale=10.+sin(.2*iTime);
    float pattern=sdGyroid(p1,scale,.03,0.);
    float result=opIntersection(sphere,pattern);
    float objType=1.;
    return vec2(result,objType);
}

float rayMarch(out vec4 fragColor,vec3 eye,vec3 ray,float end){
    float depth=0.;
    for(int i=0;i<256;i++){
        vec3 pos=eye+depth*ray;
        float dist=sdf(pos).x;
        depth+=dist;
        if(dist<.0001||dist>=end){
            break;
        }
        fragColor.rgb+=.1*sphereColor(pos);
    }
    return depth;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv=fragCoord/iResolution.xy;
    vec2 p=uv;
    vec2 m=iMouse.xy/iResolution.xy;
    
    vec3 bgColor=vec3(7.,17.,29.)/255.;
    vec4 col=vec4(bgColor,1.);
    
    p.x-=(m.x*.02);
    p.y-=(m.y*.02);
    
    vec2 cP=centerUv(p,iResolution.xy)*3.;
    vec3 eye=vec3(0.,0.,8.);
    vec3 ray=normalize(vec3(cP,-eye.z));
    float end=8.;
    float depth=rayMarch(col,eye,ray,end);
    
    fragColor=col;
}