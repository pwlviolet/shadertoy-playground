float wave(vec2 p,float t,float n){
    vec2 st=(floor(p*n)+.5)/n;
    float d=distance(vec2(.5),st);
    float c=(1.+sin(d*3.-t*3.))*.5;
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    float n=10.;
    float d=wave(uv,t,n);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}