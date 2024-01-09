// 
// @ART-colorspace: "rec2020"
// @ART-label: "Softlight"
// 

// @ART-param: ["strength", "Strength", 0.0, 100.0, 0.0, 0.1]
// @ART-param: ["pivot", "Shadows/Highlights balance", -1, 1, 0, 0.01]

import "_artlib";

const float m = 0.18;
const float b = (1.0 / m) * (1.0 - m) * m;
const float g = pow((m + b), 2.0) / b;
const float lg = log(g);

float tm(float x)
{
    if (x <= m) {
        return x;
    } else {
        float y = m * pow(x / m, g);
        return y / (y + b);
    }
}

// see https://en.wikipedia.org/wiki/Blend_modes#Soft_Light
float sl(float x)
{
    float v = fmax(x, 0);
    float a = v;
    float b = v;
    float bb = 2*b;
    v = (1 - bb) * a*a + bb*a;
    v = fmax(v, 0);
    return v;
}


void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float strength, float pivot)
{
    const float s = strength / 100;
    const float p = fmax(pow(0.5 - pivot / 2, 2.4), 0.001);
    const float f = p / intp(s, sl(p), p);
    float rgb[3] = { r, g, b };
    float l = luminance(r, g, b);
    float m = ite(l <= 0.18, 1, tm(l) / l);
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = intp(s, sl(rgb[i] / m) * m, rgb[i]) * f;
    }
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
