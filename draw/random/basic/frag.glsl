// https://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g364c54556a_39_0

float random(vec2 uv)
{
    return fract(sin(dot(uv,vec2(12.9898,78.233)))*43758.5453);
}

float box(vec2 st,float size)
{
    size=.5+size*.5;
    st=step(st,vec2(size))*step(1.-st,vec2(size));
    return st.x*st.y;
}

float wave(vec2 p,float t,float n){
    vec2 st=(floor(p*n)+.5)/n;
    float d=distance(vec2(.5),st);
    float offset=random(st)*5.;
    float c=(1.+sin(t*3.+offset))*.5;
    return c;
}

float boxWave(vec2 p,float t,float n){
    vec2 st=fract(p*n);
    float size=wave(p,t,n);
    float b=box(st,size);
    return b;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    float b=boxWave(uv,t,10.);
    
    vec3 col=vec3(b);
    
    fragColor=vec4(col,1.);
}