# SeeThroughEffect
Simple see through effect for Unity. Does an extra pass in the Standard shader that draws if ztest fails, basically. Also does an optional stencil check against xray blocking objects.

![example](https://d2ujflorbtfzji.cloudfront.net/key-image/ef0a58de-0897-47e1-8095-4d129023819c.jpg)

### XRay

To add to a normal setup, just use the provided StandardXRay and StandardSpecularXRay on anything you want to be visible through walls.

If you need the xray effect on a custom shader, just add the following Pass into your shader. Note the `#include "XRay.cginc"`- the stencil check is optional (use it if you want to use the `*BlockXRay` materials). 

```
Pass {
  Name "XRay"

  Blend SrcAlpha OneMinusSrcAlpha
  Cull Back
  ZWrite Off
  ZTest GEqual

  Stencil{
    Ref 0
    Comp Equal
    Pass IncrSat
  }

  CGPROGRAM
    #include "XRay.cginc"
    #pragma vertex vert
    #pragma fragment frag
  ENDCG
}
```

### Blocker

The blocker works by writing to the Stencil Buffer. As you can see above, the XRay in my implementation is only checking if it's zero. So, just make it not zero! 

Add the following to any shader pass to make it an XRay Blocker. 

```
Stencil{
  Ref 1
  Comp Always
  Pass replace
}
```
