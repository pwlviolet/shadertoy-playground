void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float d=distance(vec2(.5),uv);
    d*=30.;
    d=abs(sin(d));
    d=step(.5,d);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}