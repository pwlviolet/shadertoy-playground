float box(vec2 st,float size)
{
    size=.5+size*.5;
    st=step(st,vec2(size))*step(1.-st,vec2(size));
    return st.x*st.y;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    vec2 st=uv;
    
    st*=1.+.1*sin(st.x*5.+t)+
    .1*sin(st.y*3.+t);
    
    float d=box(fract(st*10.),.8);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}