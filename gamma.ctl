// @ART-label: "Gamma/slope"

import "_artlib";


// @ART-param: ["direction", "Direction", ["Forward", "Reverse"], 0]
// @ART-param: ["gamma", "Exponent", 1.0, 5.0, 1, 0.01]
// @ART-param: ["k", "Offset", 0.0, 0.5, 0, 0.0001]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float gamma, float k, int direction)
{
    float rgb[3] = { fmax(r, 0), fmax(g, 0), fmax(b, 0) };
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
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
