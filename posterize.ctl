// @ART-label: "Posterization"
// @ART-colorspace: "rec709"

import "_artlib";

float lim(float a, float f)
{
    float res = a * f;
    if (res >= f) {
        res = f-1;
    }
    return res;
}


// @ART-param: ["bits", "Bits per channel", 1, 16, 8]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int bits)
{
    float f = pow(2, bits);
    const float gamma = 2.2;
    const float igamma = 1 / gamma;
    int rgb[3] = {
        lim(pow(fmax(r, 0), igamma), f),
        lim(pow(fmax(g, 0), igamma), f),
        lim(pow(fmax(b, 0), igamma), f)
    };
    rout = pow(rgb[0] / f, gamma);
    gout = pow(rgb[1] / f, gamma);
    bout = pow(rgb[2] / f, gamma);
}
