// simple "film" density filter for ART

// @ART-label: "$CTL_FILM_DENSITY;Film density"
// @ART-colorspace: "rec2020"

import "_artlib";


float[3] process(float r, float g, float b, int sat, int density)
{
    float hsl[3] = rgb2hsl(r, g, b);
    float c = fmax(hsl[1], 0);
    hsl[2] = fmax(hsl[2], 0);
    float e = 1.0 + sat / 100.0;
    float s = intp(sqrt(fmin(c, 1)), c, c * e);
    float f = 1;
    if (c > 0 && s > c) {
        f = sqrt(s / c);
    }
    hsl[1] = s;
    hsl[2] = intp(density / 100.0, pow(hsl[2], f), hsl[2]); 
    float rgb[3] = hsl2rgb(hsl);
    return rgb;
}

// @ART-param: ["sat", "$CTL_SATURATION;Saturation", 0, 100, 0]
// @ART-param: ["density", "$CTL_DENSITY;Density", 0, 100, 0]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int sat, int density)
{
    float rgb[3] = process(r, g, b, sat, density);
    float scale = process(0.18, 0.18, 0.18, sat, density)[1] / 0.18;
    rout = rgb[0] / scale;
    gout = rgb[1] / scale;
    bout = rgb[2] / scale;
}
