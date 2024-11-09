// @ART-colorspace: "rec2020"
// @ART-label: "$CTL_COLOR_MIXING;Color mixing"

import "_artlib";

const float to_rec2020[3][3] =
    transpose_f33(mult_f33_f33(invert_f33(xyz_rec2020), xyz_rec709));

// @ART-param: ["mr", "$CTL_RED;Red", 0, 255, 0, "$CTL_COLOR_TO_MIX;Color to mix"]
// @ART-param: ["mg", "$CTL_GREEN;Green", 0, 255, 0, "$CTL_COLOR_TO_MIX;Color to mix"]
// @ART-param: ["mb", "$CTL_BLUE;Blue", 0, 255, 0, "$CTL_COLOR_TO_MIX;Color to mix"]
// @ART-param: ["amount", "$CTL_AMOUNT;Amount", 0, 1, 0, 0.001]
// @ART-param: ["mode", "$CTL_BLEND_MODE;Blend mode", ["$CTL_NORMAL;Normal", "$CTL_ADD;Add", "$CTL_SUBTRACT;Subtract", "$CTL_MULTIPLY;Multiply", "$CTL_HUE;Hue", "$CTL_COLOR;Color"], 0]
// @ART-param: ["norm", "$CTL_PRESERVE_LUMINANCE;Preserve luminance", false]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int mr, int mg, int mb, float amount, int mode, bool norm)
{
    float rgb[3] = { r, g, b };
    float tomix[3] = { mr / 255.0, mg / 255.0, mb / 255.0 };
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = fmax(rgb[i], 0);
        tomix[i] = pow(tomix[i], 2.4);
    }
    tomix = mult_f3_f33(tomix, to_rec2020);

    float res[3];
    if (mode == 0) { // normal
        res = tomix;
    } else if (mode == 1) { // add
        for (int i = 0; i < 3; i = i+1) {
            res[i] = rgb[i] + tomix[i];
        }
    } else if (mode == 2) { // subtract
        for (int i = 0; i < 3; i = i+1) {
            res[i] = rgb[i] - tomix[i];
        }
    } else if (mode == 3) { // multiply
        for (int i = 0; i < 3; i = i+1) {
            res[i] = rgb[i] * tomix[i];
        }
    } else { // color or hue
        res = rgb2hsl(tomix[0], tomix[1], tomix[2]);
        float hsl[3] = rgb2hsl(rgb[0], rgb[1], rgb[2]);
        res[2] = hsl[2];
        if (mode == 4) { // hue
            res[1] = hsl[1];
        }
        res = hsl2rgb(res);
    }

    if (norm) {
        float l = fmax(luminance(rgb[0], rgb[1], rgb[2]), 0);
        float l2 = fmax(luminance(res[0], res[1], res[2]), 0);
        if (l2 > 0) {
            float f = l / l2;
            for (int i = 0; i < 3; i = i+1) {
                res[i] = res[i] * f;
            }
        }
    }
    
    for (int i = 0; i < 3; i = i+1) {
        res[i] = intp(amount, res[i], rgb[i]);
    }

    rout = res[0];
    gout = res[1];
    bout = res[2];
}
