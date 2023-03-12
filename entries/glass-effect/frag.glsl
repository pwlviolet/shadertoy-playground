vec2 glassDistort(vec2 p){
    float center=distance(p,vec2(.5));
    
    // gl_FragColor=vec4(center,0.,0.,1.);
    
    // out edge
    float r=.49;
    float gOut=pow(center/r,110.);
    
    // gl_FragColor=vec4(gOut,0.,0.,1.);
    
    float magOut=.5-cos(gOut-1.);
    
    // gl_FragColor=vec4(magOut,0.,0.,1.);
    
    vec2 uvOut=center>r?p+magOut*(p-vec2(.5)):p;
    
    // gl_FragColor=vec4(uvOut,0.,1.);
    
    // in edge
    float gIn=pow(center/r,-7.);
    
    // gl_FragColor=vec4(gIn,0.,0.,1.);
    
    vec2 gInPower=vec2(sin(p.x-.5),sin(p.y-.5));
    
    // gl_FragColor=vec4(gInPower,0,1.);
    
    float magIn=.5-cos(gIn-1.);
    
    // gl_FragColor=vec4(magIn,0.,0.,1.);
    
    vec2 uvIn=center>r?p:magIn*(p-vec2(.5))*gInPower;
    
    // gl_FragColor=vec4(uvIn,0.,1.);
    
    vec2 dp=p+uvOut*.1+uvIn*.1;
    
    // gl_FragColor=vec4(dp,0.,1.);
    
    return dp;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv.x-=.25;
    uv.x*=iResolution.x/iResolution.y;
    
    float center=distance(uv,vec2(.5));
    
    if(center>.5){
        discard;
    }
    
    uv=glassDistort(uv);
    
    vec4 col=texture(iChannel0,uv);
    
    fragColor=col;
}