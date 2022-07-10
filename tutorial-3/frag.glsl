// https://www.youtube.com/watch?v=bigjgiavOM0&ab_channel=TheArtofCode
float circle(vec2 uv,vec2 p,float r,float blur)
{
    float d=length(uv-p);
    float c=smoothstep(r,r-blur,d);
    return c;
}

float smiley(vec2 uv,vec2 p,float size)
{
    uv-=p;
    uv/=size;
    
    float mask=circle(uv,vec2(0.),.4,.01);
    
    mask-=circle(uv,vec2(-.13,.2),.07,.01);
    mask-=circle(uv,vec2(.13,.2),.07,.01);
    
    float mouth=circle(uv,vec2(0.,0.),.3,.02);
    mouth-=circle(uv,vec2(0.,.1),.3,.02);
    
    mask-=mouth;
    return mask;
}

float band(float t,float start,float end,float blur)
{
    float step1=smoothstep(start-blur,start+blur,t);
    float step2=smoothstep(end+blur,end-blur,t);
    return step1*step2;
}

float rect(vec2 uv,float left,float right,float bottom,float top,float blur)
{
    float band1=band(uv.x,left,right,blur);
    float band2=band(uv.y,bottom,top,blur);
    return band1*band2;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    uv-=vec2(.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col=vec3(0.);
    
    // float mask=smiley(uv,vec2(0.,0.),1.);
    // float mask=band(uv.x,-.2,.2,.01);
    float mask=rect(uv,-.2,.2,-.3,.3,.01);
    col=vec3(1.,1.,1.)*mask;
    
    fragColor=vec4(col,1.);
}