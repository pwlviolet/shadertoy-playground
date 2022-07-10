// https://www.youtube.com/watch?v=u5HAYVHsasc&t=27s&ab_channel=TheArtofCode
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    float d=length(uv);
    
    // float c=d;
    // if(d<.3){
        //     c=1.;
    // }else{
        //     c=0.;
    // }
    
    float r=.3;
    float c=smoothstep(r,r-.02,d);
    
    vec3 col=vec3(c);
    
    fragColor=vec4(col,1.);
}