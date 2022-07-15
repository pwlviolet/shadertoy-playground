// https://docs.google.com/presentation/d/1NMhx4HWuNZsjNRRlaFOu2ysjo04NgcpFlEhzodE8Rlg/edit#slide=id.g35d90bbe39_0_53

float grid(vec2 p){
    return step(.8,mod(p.x*10.,1.))+step(.8,mod(p.y*10.,1.));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    vec2 st=uv;
    
    float x=2.*st.y+sin(t*5.);
    st.x+=sin(t*10.)*.1*
    sin(5.*x)*(-(x-1.)*(x-1.)+1.);
    
    float d=grid(st);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}