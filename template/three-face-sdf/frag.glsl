// Ref: https://www.shadertoy.com/view/MsdBDj

#define SHAPE 0
#define AA 1// Anti-aliasing box size

// Primitives

float sdBox(in vec2 p,in vec2 b)
{
    vec2 d=abs(p)-b;
    return length(max(d,0.))+min(max(d.x,d.y),0.);
}

// Operations

float opUnion(float d1,float d2)
{
    return min(d1,d2);
}

float opIntersection(float d1,float d2)
{
    return max(d1,d2);
}

float opSubtraction(float d1,float d2)
{
    return max(-d1,d2);
}

// Shapes

#if SHAPE==0

float sdXFace(vec2 p,float scale)
{
    p/=scale;
    
    vec2 d1p=p;
    d1p-=vec2(0.,.1);
    float d1=sdBox(d1p,vec2(.16,.3));
    
    vec2 d2p=p;
    d2p-=vec2(0.,-.25);
    float d2=sdBox(d2p,vec2(.1,.3));
    
    d1=opSubtraction(d2,d1);
    
    float dXFace=d1;
    
    dXFace*=scale;
    
    return dXFace;
}

float sdYFace(vec2 p,float scale)
{
    p/=scale;
    
    vec2 d1p=p;
    float d1=sdBox(p,vec2(.2,.15));
    
    float dYFace=d1;
    
    dYFace*=scale;
    
    return dYFace;
}

float sdZFace(vec2 p,float scale)
{
    p/=scale;
    
    vec2 d1p=p;
    d1p-=vec2(0.,.1);
    float d1=sdBox(d1p,vec2(.16,.3));
    
    vec2 d2p=p;
    d2p-=vec2(0.,-.25);
    float d2=sdBox(d2p,vec2(.1,.3));
    
    d1=opSubtraction(d2,d1);
    
    vec2 d3p=p;
    d3p-=vec2(.1,.4);
    float d3=sdBox(d3p,vec2(.19,.3));
    
    d1=opSubtraction(d3,d1);
    
    float dZFace=d1;
    
    dZFace*=scale;
    
    return dZFace;
}

#endif

float sdThreeFace(vec3 p)
{
    return min(p.y+.1,max(sdZFace(p.xy,.5),max(sdYFace(p.xz,.5),sdXFace(p.zy,.5))));
}

// The signed distance field.
float map(vec3 p)
{
    float dt=sdThreeFace(p);
    return dt;
}

// Orthonormal basis, based on code from PBRT.
mat3 coordinateSystem(vec3 w)
{
    vec3 u=cross(w,vec3(1,0,0));
    if(dot(u,u)<1e-6)
    u=cross(w,vec3(0,1,0));
    return mat3(normalize(u),normalize(cross(u,w)),normalize(w));
}

// Signed distance field normal direction.
vec3 calcNormal(vec3 p)
{
    float d=map(p);
    const vec2 e=vec2(1e-3,0);
    vec3 n=vec3(map(p+e.xyy)-d,map(p+e.yxy)-d,map(p+e.yyx)-d);
    return n;
}

// An approximate 'curvature' value (basically the amount of local change in the field normal).
// It's not perfect, but I'm still working on it...
float curvature(vec3 p)
{
    vec3 n=calcNormal(p);
    
    mat3 m=coordinateSystem(n);
    
    const float e=1e-4;
    vec3 n1=calcNormal(p+m[0]*e);
    vec3 n2=calcNormal(p+m[1]*e);
    vec3 n3=calcNormal(p-m[0]*e);
    vec3 n4=calcNormal(p-m[1]*e);
    
    return(length((n1-n3)/e)+length((n2-n4)/e))*5.;
}

// From IQ.
float ao(vec3 p,vec3 n)
{
    const int steps=9;
    const float delta=.18;
    
    float a=0.;
    float weight=.5;
    for(int i=1;i<=steps;i++){
        float d=(float(i)/float(steps))*delta;
        a+=weight*(d-map(p+n*d));
        weight*=.99;
    }
    return clamp(1.-a,0.,1.);
}

vec3 distanceColourMap(float d)
{
    float lines=mix(.5,1.,smoothstep(-.5,.5,(min(fract(d*64.),1.-fract(d*64.))-.5)*3.)*2.);
    return clamp(mix(vec3(lines)*vec3(.1),vec3(.5,.5,1.),step(d,0.))+d/3.+(1.-smoothstep(.00,.002,abs(d)-.002)),0.,1.);
}

// Analytically triangle-filtered checkerboard, from IQ
// https://iquilezles.org/articles/morecheckerfiltering
vec3 pri(in vec3 x)
{
    // see https://www.shadertoy.com/view/MtffWs
    vec3 h=fract(x/2.)-.5;
    return x*.5+h*(1.-2.*abs(h));
}

float checkersTextureGradTri(in vec3 p,in vec3 ddx,in vec3 ddy)
{
    vec3 w=max(abs(ddx),abs(ddy))+.01;// filter kernel
    vec3 i=(pri(p+w)-2.*pri(p)+pri(p-w))/(w*w);// analytical integral (box filter)
    return.5-.5*i.x*i.y*i.z;// xor pattern
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    float an=.7;
    vec2 t=fragCoord/iResolution.xy*2.-1.;
    
    t.x*=iResolution.x/iResolution.y;
    
    if(abs(t.x)>1.)
    {
        fragColor=vec4(0,0,0,1);
        return;
    }
    
    float full=step(.5,iMouse.z);
    
    if(full>.5)
    {
        t=t*.5+.5;
    }
    
    // Check which quadrant the pixel is in.
    if(t.x<0.&&t.y<0.&&full<.5)
    {
        fragColor.rgb=distanceColourMap(sdXFace((t.xy*.5+.25)*1.5,.5));
    }
    else if(t.x<0.&&t.y>0.&&full<.5)
    {
        fragColor.rgb=distanceColourMap(sdYFace((t.xy*.5+.25*vec2(1,-1))*1.5,.5));
    }
    else if(t.x>0.&&t.y<0.&&full<.5)
    {
        fragColor.rgb=distanceColourMap(sdZFace((t.xy*.5+.25*vec2(-1,1))*1.5,.5));
    }
    else
    {
        // Anti-aliasing loop.
        vec3 c=vec3(0);
        for(int y=-AA;y<=AA;++y)
        for(int x=-AA;x<=AA;++x)
        {
            float u=float(x)*.25,v=float(y)*.25;
            
            // Set up the primary ray.
            vec3 ro=vec3(0.,0.,1);
            vec3 rd=normalize(vec3((t.xy+dFdx(t.xy)*u+dFdy(t.xy)*v)*.5-.25,-1.));
            
            rd.xz=mat2(cos(an),sin(an),sin(an),-cos(an))*rd.xz;
            ro.xz=mat2(cos(an),sin(an),sin(an),-cos(an))*ro.xz;
            
            // Get the ray directions of neighbouring pixels for this sample.
            vec3 ddx_rd=rd+dFdx(rd);
            vec3 ddy_rd=rd+dFdy(rd);
            
            float s=20.;
            
            // Trace primary ray.
            float t=0.,d=0.;
            for(int i=0;i<100;++i)
            {
                d=map(ro+rd*t);
                if(d<1e-3||t>10.)break;
                t+=d;
            }
            
            vec3 rp=ro+rd*t;
            vec3 n=normalize(calcNormal(rp));
            
            // Compute ray differentials (based on code from IQ)
            vec3 ddx_pos=ro-ddx_rd*dot(ro-rp,n)/dot(ddx_rd,n);
            vec3 ddy_pos=ro-ddy_rd*dot(ro-rp,n)/dot(ddy_rd,n);
            
            // Calc texture sampling footprint (based on code from IQ)
            vec3 uvw=rp*32.;
            vec3 ddx_uvw=ddx_pos*32.-uvw;
            vec3 ddy_uvw=ddy_pos*32.-uvw;
            
            // Basic light value.
            float l=.7+.3*dot(n,normalize(vec3(1)));
            
            // Ambient occlusion.
            l*=ao(rp,n);
            
            // Depth cueing.
            l*=exp(-t)*2.;
            
            // Darken the geometric edges.
            l*=clamp(1.-curvature(rp),0.,1.);
            
            // Get a directional shadow.
            t=0.;
            d=0.;
            ro=rp+n*1e-3;
            rd=normalize(vec3(1,.3,1));
            for(int i=0;i<40;++i)
            {
                d=map(ro+rd*t);
                if(d<1e-3||t>10.)break;
                t+=d;
            }
            
            if(d<1e-3)
            l*=.3;
            
            // Apply the filtered checkerboard texture.
            c+=l*(.5+.5*checkersTextureGradTri(uvw,ddx_uvw,ddy_uvw));
        }
        fragColor.rgb=c/((float(AA)*2.+1.)*(float(AA)*2.+1.));
    }
    
    if(full<.5)
    {
        // Add separation lines.
        fragColor.rgb=mix(fragColor.rgb,vec3(.1),step(min(abs(t.x),abs(t.y)),.004));
    }
    
    fragColor.rgb=sqrt(max(fragColor.rgb,0.));
}