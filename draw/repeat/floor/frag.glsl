void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float n=2.;
    
    vec2 fst=fract(uv*vec2(n));
    
    vec2 ist=floor(uv*vec2(n));
    
    vec3 col=vec3(fst.x,fst.y,0.);
    
    fragColor=vec4(col,1.);
}