void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float d=distance(vec2(.5),uv);
    
    float a=.4;
    
    float c=step(a,d);
    
    vec3 col=vec3(c);
    
    fragColor=vec4(col,1.);
}