// https://www.youtube.com/watch?v=dKA5ZVALOhs&t=17s&ab_channel=TheArtofCode
float dLine(vec3 ro,vec3 rd,vec3 p)
{
    // para area=|rop x rd|=|rd|*h
    // h=|rop x rd|/|rd|
    return length(cross(p-ro,rd))/length(rd);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    float t=iTime;
    
    vec3 ro=vec3(0.,0.,-2.);
    
    // rd=d-ro
    vec3 rd=vec3(uv.x,uv.y,0.)-ro;
    
    vec3 p=vec3(sin(t),0.,1.+cos(t));
    
    float d=dLine(ro,rd,p);
    d=smoothstep(.1,.09,d);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}