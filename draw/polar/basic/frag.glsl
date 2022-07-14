// htthttps://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g364407fc99_0_30

const float PI=3.14159265359;

float getTheta(vec2 st){
    return atan(st.y,st.x);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 st=.5-uv;
    
    float a=getTheta(st);
    
    vec3 col=vec3((a+PI)/(PI*2.));
    
    fragColor=vec4(col,1.);
}