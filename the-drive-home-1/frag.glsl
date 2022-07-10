// https://www.youtube.com/watch?v=eKtsY7hYTPg&t=24s&ab_channel=TheArtofCode

struct ray{
    vec3 o;
    vec3 d;
};

ray getRay(vec2 uv,vec3 camPos,vec3 lookat,float zoom){
    ray a;
    vec3 ro=camPos;
    a.o=ro;
    // lookat=ro+f
    // F=lookat-ro
    vec3 f=normalize(lookat-ro);
    // R=Y x F
    vec3 r=cross(vec3(0.,1.,0.),f);
    // U=F x R
    vec3 u=cross(f,r);
    // C=ro+F*zoom
    vec3 c=ro+f*zoom;
    
    // i=C+uv.x*RIGHT+uv.y*UP
    vec3 i=c+uv.x*r+uv.y*u;
    vec3 rd=normalize(i-ro);
    a.d=rd;
    return a;
}

float dRay(ray r,vec3 p){
    // para area=|rop x rd|=|rd|*h
    // h=|rop x rd|/|rd|
    return length(cross(p-r.o,r.d))/length(r.d);
}

float bokeh(ray r,vec3 p,float size,float blur){
    float d=dRay(r,p);
    float c=smoothstep(size,size*(1.-blur),d);
    float ring=smoothstep(size*.8,size,d);
    c*=mix(.6,1.,ring);
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 camPos=vec3(0.,.2,0.);
    vec3 lookat=vec3(0.,.2,1.);
    
    ray r=getRay(uv,camPos,lookat,2.);
    
    vec3 p=vec3(0.,0.,5.);
    
    float c=bokeh(r,p,.3,.1);
    
    vec3 col=vec3(1.,.7,.3)*c;
    
    fragColor=vec4(col,1.);
}