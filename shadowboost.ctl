// @ART-colorspace: "rec2020"
// @ART-label: "$CTL_SHADOW_LIFTING;Shadow lifting"

import "_artlib";

float boost(float x, float base, float logb)
{
    float l = pow(clamp(x, 0, 1), 0.1);
    float y = log(x * (base - 1) + 1) / logb;
    return intp(l, x, (pow(100, y) - 1) / (100 - 1));
}


// @ART-param: ["strength", "$CTL_STRENGTH;Strength", -100, 100, 0]
void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int strength)
{
    const float base = ite(strength > 0, 1000 + 100 * strength, 1000 + 9 * strength);
    const float logb = log(base);

    float hue = rgb2hsl(r, g, b)[0];
    
    float rgb[3] = { fmax(r, 0), fmax(g, 0), fmax(b, 0) };
    float f = 0.18 / boost(0.18, base, logb);
    float off = 1e-4 - boost(1e-4, base, logb);

    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = fmax(boost(rgb[i], base, logb) * f + off, 0);
    }

    float hsl[3] = rgb2hsl(rgb[0], rgb[1], rgb[2]);
    hsl[0] = hue;
    rgb = hsl2rgb(hsl);
    
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}

