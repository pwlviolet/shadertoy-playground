float heart(vec2 p){
    p-=vec2(.5,.38);
    p*=vec2(2.1,2.8);
    return pow(p.x,2.)+pow(p.y-sqrt(abs(p.x)),2.);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float d=heart(uv);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}