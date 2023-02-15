#define uScanTex iChannel0
#define uScanOrigin vec3(0.,0.,0.)
#define uScanSpeed 1.
#define uScanWaveRatio1 1.6
#define uScanWaveRatio2 1.4
#define uScanColorDark vec3(.48,1.,.94)
#define uScanColor vec3(0.,.85,1.)

float circleWave(vec3 p,vec3 origin,float distRatio){
    float t=iTime*uScanSpeed;
    
    float dist=distance(p,origin)*distRatio;
    
    float radialMove=fract(dist-t);
    
    float fadeOutMask=1.-smoothstep(1.,3.,dist);
    radialMove*=fadeOutMask;
    
    float cutInitialMask=1.-step(t,dist);
    radialMove*=cutInitialMask;
    
    // return dist;
    return radialMove;
    // return fadeOutMask;
    // return cutInitialMask;
}

vec3 getScanColor(vec3 worldPos,vec2 uv,vec3 col){
    // mask
    float scanMask=texture(uScanTex,uv).r;
    
    // waves
    float cw=circleWave(worldPos,uScanOrigin,uScanWaveRatio1);
    float cw2=circleWave(worldPos,uScanOrigin,uScanWaveRatio2);
    
    // scan
    float mask1=smoothstep(.3,0.,1.-cw);
    mask1*=(1.+scanMask*.7);
    
    float mask2=smoothstep(.07,0.,1.-cw2)*.8;
    mask1+=mask2;
    
    float mask3=smoothstep(.09,0.,1.-cw)*1.5;
    mask1+=mask3;
    
    // color
    vec3 scanCol=mix(uScanColorDark,uScanColor,mask1);
    col=mix(col,scanCol,mask1);
    
    return col;
    // return worldPos;
    // return scanMask;
    // return vec3(cw);
    // return vec3(mask1);
    // return scanCol;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 worldPosition=vec3(uv.x,uv.y,0.);
    vec2 texUv=uv*10.;
    
    vec3 col=vec3(0.);
    col=getScanColor(worldPosition,texUv,col);
    
    fragColor=vec4(col,1.);
}