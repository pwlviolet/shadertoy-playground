// https://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g3689912efb_0_8

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    float n=2.;
    
    vec2 st=fract(uv*vec2(n));
    
    vec3 col=vec3(st,0.);
    
    fragColor=vec4(col,1.);
}