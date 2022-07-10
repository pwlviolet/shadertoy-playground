// https://www.youtube.com/watch?v=vlD_KOrzGDc&ab_channel=TheArtofCode

float sat(float a)
{
    return clamp(a,0.,1.);
}

float remap01(float a,float b,float t)
{
    return sat((t-a)/(b-a));
}

vec2 remap01(vec2 a,vec2 b,vec2 t)
{
    return(t-a)/(b-a);
}

float remap(float a,float b,float c,float d,float t)
{
    return sat((t-a)/(b-a))*(d-c)+c;
}

vec2 within(vec2 uv,vec4 rect)
{
    return remap01(rect.xy,rect.zw,uv);
}

vec4 brow(vec2 uv,float smile)
{
    float offs=mix(.2,0.,smile);
    uv.y+=offs;
    
    float y=uv.y;
    uv.y+=uv.x*mix(.5,.8,smile)-mix(.1,.3,smile);
    uv.x-=mix(.0,.1,smile);
    uv-=.5;
    
    vec4 col=vec4(0.);
    
    float blur=.1;
    
    float d1=length(uv);
    float s1=smoothstep(.45,.45-blur,d1);
    float d2=length(uv-vec2(.1,-.2)*.7);
    float s2=smoothstep(.5,.5-blur,d2);
    
    float browMask=sat(s1-s2);
    
    float colMask=remap01(.7,.8,y)*.75;
    colMask*=smoothstep(.6,.9,browMask);
    colMask*=smile;
    vec4 browCol=mix(vec4(.4,.2,.2,1.),vec4(1.,.75,.5,1.),colMask);
    
    uv.y+=.15-offs*.5;
    blur+=mix(.0,.1,smile);
    d1=length(uv);
    s1=smoothstep(.45,.45-blur,d1);
    d2=length(uv-vec2(.1,-.2)*.7);
    s2=smoothstep(.5,.5-blur,d2);
    float shadowMask=sat(s1-s2);
    
    col=mix(col,vec4(0.,0.,0.,1.),smoothstep(.0,1.,shadowMask)*.5);
    
    col=mix(col,browCol,smoothstep(.2,.4,browMask));
    
    return col;
}

vec4 eye(vec2 uv)
{
    uv-=vec2(.5);
    
    float d=length(uv);
    
    vec4 col=vec4(1.);
    
    // iris
    vec3 irisCol=vec3(96.,156.,253.)/255.;
    col.rgb=mix(col.rgb,irisCol,smoothstep(.1,.7,d)*.5);
    
    col.rgb*=(1.-smoothstep(.45,.5,d)*.5*sat(-uv.y-uv.x));
    
    // pupil
    col.rgb=mix(col.rgb,vec3(0.,0.,0.)/255.,smoothstep(.3,.28,d));
    irisCol*=(1.+smoothstep(.3,.05,d));
    col.rgb=mix(col.rgb,irisCol,smoothstep(.28,.25,d));
    col.rgb=mix(col.rgb,vec3(0.,0.,0.)/255.,smoothstep(.16,.14,d));
    
    // highlight
    float highlight=smoothstep(.1,.09,length(uv-vec2(-.15,.15)));
    highlight+=smoothstep(.07,.05,length(uv-vec2(.08,-.08)));
    col.rgb=mix(col.rgb,vec3(255.,255.,255.)/255.,highlight);
    
    col.a=smoothstep(.5,.48,d);
    
    return col;
}

vec4 mouth(vec2 uv)
{
    uv-=vec2(.5);
    
    vec4 col=vec4(vec3(93.,0.,0.)/255.,1.);
    
    uv.y/=.66;
    uv.y-=uv.x*uv.x*2.;
    
    float d=length(uv);
    
    col.a=smoothstep(.5,.48,d);
    
    float td=length(uv-vec2(0.,.6));
    
    vec3 toothCol=vec3(255.,255.,255.)/255.*smoothstep(.6,.35,d);
    col.rgb=mix(col.rgb,toothCol,smoothstep(.4,.37,td));
    
    td=length(uv-vec2(0.,-.5));
    col.rgb=mix(col.rgb,vec3(255.,127.,127.)/255.,smoothstep(.5,.2,td));
    
    return col;
}

vec4 head(vec2 uv)
{
    vec4 col=vec4(vec3(250.,182.,11.)/255.,1.);
    
    float d=length(uv);
    
    // shape
    col.a=smoothstep(.5,.49,d);
    
    // radial grad
    float edgeShade=remap01(.35,.5,d);
    edgeShade*=edgeShade;
    col.rgb*=(1.-edgeShade*.5);
    
    // outline
    float outline=smoothstep(.47,.48,d);
    col.rgb=mix(col.rgb,vec3(203.,101.,0.)/255.,outline);
    
    // highlight grad
    float highlight=smoothstep(.41,.405,d);
    highlight*=remap(.41,-.1,.75,0.,uv.y);
    highlight*=smoothstep(.18,.19,length(uv-vec2(.21,.08)));
    col.rgb=mix(col.rgb,vec3(255.,255.,255.)/255.,highlight);
    
    d=length(uv-vec2(.25,-.2));
    // cheek
    float cheek=smoothstep(.2,.1,d)*.4;
    // slight edge
    cheek*=smoothstep(.17,.16,d);
    col.rgb=mix(col.rgb,vec3(253.,122.,4.)/255.,cheek);
    
    return col;
}

vec4 smiley(vec2 uv)
{
    vec4 col=vec4(0.);
    
    uv.x=abs(uv.x);
    
    vec4 headCol=head(uv);
    col=mix(col,headCol,headCol.a);
    
    vec4 eyeCol=eye(within(uv,vec4(.03,-.1,.37,.25)));
    col=mix(col,eyeCol,eyeCol.a);
    
    vec4 mouthCol=mouth(within(uv,vec4(-.3,-.4,.3,-.1)));
    col=mix(col,mouthCol,mouthCol.a);
    
    vec4 browCol=brow(within(uv,vec4(.03,.2,.4,.45)),0.);
    col=mix(col,browCol,browCol.a);
    
    return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=vec2(.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec4 col=vec4(0.);
    
    col=smiley(uv);
    
    fragColor=col;
}