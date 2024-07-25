// @ART-label: "Tone curve"
// @ART-colorspace: "rec2020"

import "_artlib";

const float c = 0;
const float a = 1;
const float b = (a / (0.18 - c)) * (1.0 - ((0.18 - c) / a)) * 0.18;
const float s = 1;
const float g = s * pow(0.18 + b, 2) / (a * b);
const float l = 50.0;

float ro(float x)
{
    return a * (x / (x + b)) + c;
}

float iro(float y)
{
    return (-b * ((y - c) / a)) / (((y - c) / a) - 1);
}

float contr(float x)
{
    return 0.18 * pow(x / 0.18, g);
}

float icontr(float y)
{
    return pow(y / 0.18, 1.0/g) * 0.18;
}

float lg(float x)
{
    return log(x * (l - 1.0) + 1.0) / log(l);
}


float ilg(float x)
{
    return (pow(l, x) - 1) / (l - 1.0);
}


float enc(float x)
{
    float y = ite(x <= 0.18, x, ro(contr(x)));
    return lg(y);
}


float dec(float x)
{
    float y = ilg(x);
    return ite(y <= 0.18, y, icontr(iro(y)));
}


// @ART-param: ["curve", "Curve"]
void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float curve[256])
{
    float rgb[3] = { r, g, b };
    for (int i = 0; i < 3; i = i+1) {
        float x = enc(rgb[i]);
        float y = lookupCubic1D(curve, 0, 1, x);
        rgb[i] = dec(y);
    }
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
