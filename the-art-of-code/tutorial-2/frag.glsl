// https://www.youtube.com/watch?v=GgGBR4z8C9o&t=1s&ab_channel=TheArtofCode
float circle(vec2 uv,vec2 p,float r,float blur)
{
    float d=length(uv-p);
    float c=smoothstep(r,r-blur,d);
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    uv-=vec2(.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col=vec3(0.);
    
    float mask=circle(uv,vec2(0.),.4,.05);
    
    mask-=circle(uv,vec2(-.13,.2),.07,.01);
    mask-=circle(uv,vec2(.13,.2),.07,.01);
    
    float mouth=circle(uv,vec2(0.,0.),.3,.02);
    mouth-=circle(uv,vec2(0.,.1),.3,.02);
    
    //col=vec3(mouth);
    mask-=mouth;
    col=vec3(1.,1.,0.)*mask;
    
    fragColor=vec4(col,1.);
}