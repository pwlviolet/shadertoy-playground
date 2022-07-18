float wave(vec2 p,float t){
    float d=distance(vec2(.5),p);
    float c=(1.+sin(d*3.-t*3.))*.5;
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    float d=wave(uv,t);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}