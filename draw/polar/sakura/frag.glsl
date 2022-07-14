const float PI=3.14159265359;

float getTheta(vec2 st){
    return atan(st.y,st.x);
}

float sakura(float x){
    return min(abs(cos(x*2.5))+.4,
    abs(sin(x*2.5))+1.1)*.32;
}

float sakura(float a,vec2 p){
    float d=sakura(a);
    float r=length(p);
    return step(r,d);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 st=.5-uv;
    
    float a=getTheta(st);
    
    float d=sakura(a,st);
    
    vec3 col=vec3(d);
    
    fragColor=vec4(col,1.);
}