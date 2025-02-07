// @ART-label: "$CTL_GRAPHICAL_EQUALIZER_BY_LUMINANCE;Graphical equalizer by luminance"
// @ART-colorspace: "rec2020"

import "_artlib";

const float xyz_m[3][3] = transpose_f33(mult_f33_f33(d65_d50, xyz_rec2020));
const float xyz_invm[3][3] = invert_f33(xyz_m);


float[3] to_hsl(float r, float g, float b)
{
    float rgb[3] = { r, g, b };
    float xyz[3] = mult_f3_f33(rgb, xyz_m);
    float oklab[3] = d65xyz2oklab(xyz);
    return oklab2hcl(oklab);
}


float[3] to_rgb(float hsl[3])
{
    float oklab[3] = hcl2oklab(hsl);
    float xyz[3] = oklab2d65xyz(oklab);
    return mult_f3_f33(xyz, xyz_invm);
}


float tolin(float y, float base)
{
    float v = (y - 0.5) * 2.0;
    return sgn(v) * clamp(log2lin(fabs(v), base), 0, 1);
}

// @ART-param: ["hcurve", "H", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "$CTL_CHANNEL;Channel"]
// @ART-param: ["scurve", "S", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "$CTL_CHANNEL;Channel"]
// @ART-param: ["lcurve", "L", 1, ["ControlPoints", 0.0, 0.5, 0.35, 0.35, 1, 0.5, 0.35, 0.35], [[0.0, 0.0, 0.0, 0.0], [0.16666666666666666, 0.01941186441032164, 0.01941186441032164, 0.01941186441032164], [0.3333333333333333, 0.08919350686224782, 0.08919350686224782, 0.08919350686224782], [0.5, 0.217637640824031, 0.217637640824031, 0.217637640824031], [0.6666666666666666, 0.40982573843632336, 0.40982573843632336, 0.40982573843632336], [0.8333333333333334, 0.6695781277796022, 0.6695781277796022, 0.6695781277796022], [1.0, 1.0, 1.0, 1.0]], 0, "$CTL_CHANNEL;Channel"]
void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float hcurve[256], float scurve[256], float lcurve[256])
{
    float hsl[3] = to_hsl(r, g, b);
    float y = pow(clamp(hsl[2], 0, 1), 1.0/2.2);
    float v = luteval(hcurve, y);
    float f = tolin(v, 50) * M_PI;
    hsl[0] = hsl[0] + f;
    v = luteval(scurve, y);
    f = tolin(v, 2);
    float s = fmax(1.0 + f, 0);
    hsl[1] = hsl[1] * s;
    v = luteval(lcurve, y) - 0.5;
    f = 1 + sgn(v) * pow(v, 2) * 5;
    hsl[2] = hsl[2] * f;
    float rgb[3] = to_rgb(hsl);
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
