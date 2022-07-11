// https://www.youtube.com/watch?v=ewu5XrPRgxI&ab_channel=TheArtofCode

struct ray{
    vec3 o;
    vec3 d;
};

ray getRay(vec2 uv,vec3 camPos,vec3 lookat,float zoom){
    ray a;
    vec3 ro=camPos;
    a.o=ro;
    // lookat=ro+f
    // F=lookat-ro
    vec3 f=normalize(lookat-ro);
    // R=Y x F
    vec3 r=cross(vec3(0.,1.,0.),f);
    // U=F x R
    vec3 u=cross(f,r);
    // C=ro+F*zoom
    vec3 c=ro+f*zoom;
    
    // i=C+uv.x*RIGHT+uv.y*UP
    vec3 i=c+uv.x*r+uv.y*u;
    vec3 rd=normalize(i-ro);
    a.d=rd;
    return a;
}

float dRay(ray r,vec3 p){
    // para area=|rop x rd|=|rd|*h
    // h=|rop x rd|/|rd|
    return length(cross(p-r.o,r.d))/length(r.d);
}

float random(float t){
    return fract(sin(t*3456.)*6547.);
}

float bokeh(ray r,vec3 p,float size,float blur){
    float d=dRay(r,p);
    
    // keep size at perspective camera
    size*=length(p);
    
    // shape
    float c=smoothstep(size,size*(1.-blur),d);
    float ring=smoothstep(size*.8,size,d);
    c*=mix(.7,1.,ring);
    return c;
}

vec3 streetLights(ray r,float t){
    // side
    float side=step(r.d.x,0.);
    
    // mirror
    r.d.x=abs(r.d.x);
    
    float m=0.;
    int count=10;
    for(int i=0;i<count;i+=1){
        // ratio
        float s=float(i)/float(count);
        // offset
        float o=side*s*.5;
        // stagger
        float ti=fract(t+s+o);
        // pos
        vec3 p=vec3(2.,2.,100.-ti*100.);
        // bokeh
        float c=bokeh(r,p,.05,.1);
        // fade
        c*=pow(ti,3.);
        // add
        m+=c;
    }
    
    return vec3(1.,.7,.3)*m;
}

vec3 headLights(ray r,float t){
    t*=2.;
    
    float m=0.;
    int count=30;
    for(int i=0;i<count;i+=1){
        // ratio
        float s=float(i)/float(count);
        // noise
        float n=random(s);
        
        if(n>.1){
            continue;
        }
        
        // stagger
        float ti=fract(t+s);
        // pos
        float z=100.-ti*100.;
        float fade=pow(ti,5.);
        // focus
        float focus=smoothstep(.8,1.,ti);
        // bokeh
        float w1=.25;
        float w2=w1*1.2;
        float size=mix(.05,.03,focus);
        
        m+=bokeh(r,vec3(-1.-w1,.15,z),size,.1)*fade;
        m+=bokeh(r,vec3(-1.+w1,.15,z),size,.1)*fade;
        
        m+=bokeh(r,vec3(-1.-w2,.15,z),size,.1)*fade;
        m+=bokeh(r,vec3(-1.+w2,.15,z),size,.1)*fade;
        
        float ref=0.;
        ref+=bokeh(r,vec3(-1.-w2,-.15,z),size*3.,1.)*fade;
        ref+=bokeh(r,vec3(-1.+w2,-.15,z),size*3.,1.)*fade;
        
        m+=ref*focus;
    }
    
    return vec3(.9,.9,1.)*m;
}

vec3 tailLights(ray r,float t){
    t*=.25;
    
    float m=0.;
    int count=15;
    for(int i=0;i<count;i+=1){
        // ratio 0-1
        float s=float(i)/float(count);
        // noise
        float n=random(s);
        
        if(n>.5){
            continue;
        }
        
        // stagger
        float ti=fract(t+s);
        
        // ratio 0-0.5
        float lane=step(.25,n);// 0 1
        float laneShift=smoothstep(1.,.96,ti);
        
        // pos
        float z=100.-ti*100.;
        float fade=pow(ti,5.);
        // focus
        float focus=smoothstep(.8,1.,ti);
        // bokeh
        float w1=.25;
        float w2=w1*1.2;
        float size=mix(.05,.03,focus);
        
        float x=1.5-lane*laneShift;
        
        float blink=step(0.,sin(t*1000.))*7.*lane*step(.96,ti);
        
        m+=bokeh(r,vec3(x-w1,.15,z),size,.1)*fade;
        m+=bokeh(r,vec3(x+w1,.15,z),size,.1)*fade;
        
        m+=bokeh(r,vec3(x-w2,.15,z),size,.1)*fade;
        m+=bokeh(r,vec3(x+w2,.15,z),size,.1)*fade*(blink+1.);
        
        float ref=0.;
        ref+=bokeh(r,vec3(x-w2,-.15,z),size*3.,1.)*fade;
        ref+=bokeh(r,vec3(x+w2,-.15,z),size*3.,1.)*fade*(blink*.1+1.);
        
        m+=ref*focus;
    }
    
    return vec3(1.,.1,.0)*m;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    
    float t=iTime;
    vec2 m=iMouse.xy/iResolution.xy;
    
    vec3 camPos=vec3(.5,.2,0.);
    vec3 lookat=vec3(.5,.2,1.);
    float zoom=2.;
    
    // ray
    ray r=getRay(uv,camPos,lookat,zoom);
    
    vec3 col=vec3(0.);
    
    t*=.1;
    t+=m.x;
    
    col+=streetLights(r,t);
    col+=headLights(r,t);
    col+=tailLights(r,t);
    
    fragColor=vec4(col,1.);
}