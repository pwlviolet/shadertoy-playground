// https://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g370aabb90c_0_701

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float d=distance(vec2(.5),uv);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}