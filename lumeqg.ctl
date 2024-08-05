// @ART-label: "Graphical equalizer by luminance"
// @ART-colorspace: "rec2020"

import "_artlib";

float tolin(float y, float base)
{
    float v = (y - 0.5) * 2.0;
    return sgn(v) * clamp(log2lin(fabs(v), base), 0, 1);
}

// @ART-param: ["hcurve", "H", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "Channel"]
// @ART-param: ["scurve", "S", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "Channel"]
// @ART-param: ["lcurve", "L", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "Channel"]
void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float hcurve[256], float scurve[256], float lcurve[256])
{
    float hsl[3] = rgb2hsl(r, g, b);
    float y = pow(clamp(hsl[2], 0, 1), 1.0/2.2);
    float v = lookupCubic1D(hcurve, 0, 1, y);
    float f = tolin(v, 50) * M_PI;
    hsl[0] = hsl[0] + f;
    v = lookupCubic1D(scurve, 0, 1, y);
    f = tolin(v, 2);
    float s = fmax(1.0 + f, 0);
    hsl[1] = hsl[1] * s;
    v = lookupCubic1D(lcurve, 0, 1, y) - 0.5;
    f = 1 + sgn(v) * pow(v, 2) * 5;
    hsl[2] = hsl[2] * f;
    float rgb[3] = hsl2rgb(hsl);
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
