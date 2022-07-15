float circle(vec2 p,float r){
    return step(r,distance(vec2(.5),p));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    float t=iTime;
    
    float x=2.*uv.y+sin(t*5.);
    float distort=sin(t*10.)*.1*
    sin(5.*x)*(-(x-1.)*(x-1.)+1.);
    
    uv.x+=distort;
    
    vec3 col=vec3(circle(uv-vec2(0.,distort)*.3,.3),
    circle(uv+vec2(0.,distort)*.3,.3),
    circle(uv+vec2(distort,0.)*.3,.3));
    
    fragColor=vec4(col,1.);
}