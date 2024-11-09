// @ART-colorspace: "rec2020"
// @ART-label: "$CTL_SIMPLE_SPLIT_TONING;Simple split toning"

float pow0(float x, float e) { if (x < 0) return x; else return pow(x, e); }

// @ART-param: ["hhue", "$CTL_HUE;Hue", 0, 360, 0, 0.1, "$CTL_HIGHLIGHTS;Highlights"]
// @ART-param: ["hsat", "$CTL_STRENGTH;Strength", 0, 1, 0, 0.01, "$CTL_HIGHLIGHTS;Highlights"]
// @ART-param: ["shue", "$CTL_HUE;Hue", 0, 360, 0, 0.1, "$CTL_SHADOWS;Shadows"]
// @ART-param: ["ssat", "$CTL_STRENGTH;Strength", 0, 1, 0, 0.01, "$CTL_SHADOWS;Shadows"]
void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float hhue, float hsat, float shue, float ssat)
{
    const float hue[2] = { hhue * M_PI / 180.0, shue * M_PI / 180.0 };
    const float sat[2] = { hsat, ssat / 5 };

    const float gamma = 2.2;
    const float igamma = 1 / gamma;
    
    float rgb[3] = {
        pow0(r, igamma), pow0(g, igamma), pow0(b, igamma)
    };
    
    float luma = rgb[0] * 0.299 + rgb[1] * 0.587 + rgb[2] * 0.114;
    float chroma[2] = { luma - rgb[2], rgb[0] - luma };
    
    float tint[2] = {
        luma * sat[0] * sin(hue[0]) + sat[1] * sin(hue[1]),
        luma * sat[0] * cos(hue[0]) + sat[1] * cos(hue[1])
    };

    rout = pow0(chroma[1] + tint[1] + luma, gamma);
    gout = g;
    bout = pow0(luma - (chroma[0] + tint[0]), gamma);
}
