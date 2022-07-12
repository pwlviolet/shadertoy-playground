float sdBox(in vec2 p,in vec2 b)
{
    vec2 d=abs(p)-b;
    return length(max(d,0.))+min(max(d.x,d.y),0.);
}

float sdCharG(vec2 p){
    p*=2.;
    float d=sdBox(p,vec2(.25,1.));
    d=min(d,sdBox(p-vec2(.75,.75),vec2(1.,.25)));
    d=min(d,sdBox(p-vec2(.75,-.75),vec2(1.,.25)));
    d=min(d,sdBox(p-vec2(1.5,-.5),vec2(.25,.5)));
    d=min(d,sdBox(p-vec2(1.25,0.),vec2(.5,.125)));
    return d;
}

vec2 opSymX(vec2 p){
    p.x=abs(p.x);
    return p;
}

float map(vec2 p){
    p=opSymX(p);
    p-=vec2(.1,.0);
    float dt=sign(sdCharG(p*2.)/2.);
    return dt;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    float d=map(uv);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}