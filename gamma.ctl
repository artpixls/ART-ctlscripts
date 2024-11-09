// @ART-label: "$CTL_GAMMA_SLOPE;Gamma/slope"
// @ART-colorspace: "rec2020"

import "_artlib";


// @ART-param: ["direction", "$CTL_DIRECTION;Direction", ["$CTL_FORWARD;Forward", "$CTL_REVERSE;Reverse"], 0]
// @ART-param: ["gamma", "$CTL_EXPONENT;Exponent", 1.0, 10.0, 1, 0.01]
// @ART-param: ["k", "$CTL_OFFSET;Offset", 0.0, 1.5, 0, 0.0001]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float gamma, float k, int direction)
{
    float rgb[3] = { fmax(r, 0), fmax(g, 0), fmax(b, 0) };
    float hsl[3] = rgb2hsl(r, g, b);
    const float g1 = 1 / gamma;
    if (k > 0) {
        const float xbreak = k / (gamma - 1);
        const float ybreak = pow((k * gamma) / ((gamma - 1) * (1 + k)), gamma);
        const float s = ybreak / xbreak;
        const float k1 = k + 1;
        if (direction == 0) {
            for (int i = 0; i < 3; i = i+1) {
                if (rgb[i] >= ybreak) {
                    rgb[i] = k1 * pow(rgb[i], g1) - k;
                } else {
                    rgb[i] = rgb[i] / s;
                }
            }
        } else {
            for (int i = 0; i < 3; i = i+1) {
                if (rgb[i] >= xbreak) {
                    rgb[i] = pow((rgb[i] + k) / k1, gamma);
                } else {
                    rgb[i] = rgb[i] * s;
                }
            }
        }
    } else if (direction == 0) {
        for (int i = 0; i < 3; i = i+1) {
            rgb[i] = pow(rgb[i], g1);
        }
    } else {
        for (int i = 0; i < 3; i = i+1) {
            rgb[i] = pow(rgb[i], gamma);
        }
    }

    float hue = hsl[0];
    hsl = rgb2hsl(rgb[0], rgb[1], rgb[2]);
    hsl[0] = hue;
    rgb = hsl2rgb(hsl);
    
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
