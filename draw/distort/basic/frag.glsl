// https://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g35d90bbe39_0_53

float circle(vec2 p,float r){
    return step(r,distance(vec2(.5),p));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    uv.x+=sin(uv.y*20.)*.05;
    
    float d=circle(uv,.3);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}