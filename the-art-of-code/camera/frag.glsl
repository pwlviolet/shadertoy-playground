// https://www.youtube.com/watch?v=PBxuVlp7nuM&t=4s&ab_channel=TheArtofCode
float dLine(vec3 ro,vec3 rd,vec3 p)
{
    // para area=|rop x rd|=|rd|*h
    // h=|rop x rd|/|rd|
    return length(cross(p-ro,rd))/length(rd);
}

float drawPoint(vec3 ro,vec3 rd,vec3 p)
{
    float d=dLine(ro,rd,p);
    d=smoothstep(.06,.05,d);
    return d;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    float t=iTime;
    
    vec3 ro=vec3(3.*sin(t),2.,-3.*cos(t));
    
    vec3 lookat=vec3(.5);
    
    float zoom=1.;
    
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
    
    // rd=i-ro
    vec3 rd=i-ro;
    
    float d=0.;
    
    d+=drawPoint(ro,rd,vec3(0.,0.,0.));
    d+=drawPoint(ro,rd,vec3(0.,0.,1.));
    d+=drawPoint(ro,rd,vec3(0.,1.,0.));
    d+=drawPoint(ro,rd,vec3(0.,1.,1.));
    d+=drawPoint(ro,rd,vec3(1.,0.,0.));
    d+=drawPoint(ro,rd,vec3(1.,0.,1.));
    d+=drawPoint(ro,rd,vec3(1.,1.,0.));
    d+=drawPoint(ro,rd,vec3(1.,1.,1.));
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}