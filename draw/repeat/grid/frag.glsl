float box(vec2 st,float size)
{
    size=.5+size*.5;
    st=step(st,vec2(size))*step(1.-st,vec2(size));
    return st.x*st.y;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float n=10.;
    
    vec2 st=fract(uv*vec2(n));
    
    float d=box(st,.7);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}