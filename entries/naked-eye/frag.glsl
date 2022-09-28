void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 m=iMouse.xy/iResolution.xy;
    
    vec4 depth=texture2D(iChannel1,uv);
    vec2 parallax=m*depth.r*.025;
    vec2 newUv=uv+parallax;
    vec4 tex=texture2D(iChannel0,newUv);
    vec4 col=tex;
    
    fragColor=col;
}