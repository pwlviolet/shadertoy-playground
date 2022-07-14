const float PI=3.14159265359;

float getTheta(vec2 st){
    return atan(st.y,st.x);
}

float sakuraPetal(float x){
    return min(abs(cos(x*2.5))+.4,
    abs(sin(x*2.5))+1.1)*.32;
}

float sakuraPetal(float a,vec2 p){
    float d=sakuraPetal(a);
    float r=length(p);
    return step(r,d);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 st=.5-uv;
    
    float a=getTheta(st);
    
    float r=length(st);
    
    vec3 col=vec3(0.);
    
    // bg
    col+=mix(vec3(.8),vec3(.0,.4,1.),uv.y);
    
    // petal
    float petal=sakuraPetal(a,st);
    col=mix(col,mix(vec3(1.,.3,1.),vec3(1.),r*2.5),petal);
    
    // cap
    float cap=step(distance(vec2(0.),st),.07);
    col=mix(col,vec3(.99,.78,0.),cap);
    
    fragColor=vec4(col,1.);
}