// @ART-colorspace: "rec2020"
// @ART-label: "Tetrahedral Color Warping (HSL)"

import "_artlib";
import "_tetrainterp";


float spow(float b, float e)
{
    if (b >= 0) {
        return pow(b, e);
    } else {
        return -pow(-b, e);
    }
}


float[3] torgb(float r, float g, float b, float dh, float ds, float dl)
{
    float hsl[3] = rgb2hsl(r, g, b);
    hsl[0] = hsl[0] + spow(dh, 3) * M_PI;
    hsl[1] = hsl[1] + spow(ds, 3);
    hsl[2] = hsl[2] * pow(2, 2*dl);
    return hsl2rgb(hsl);
}

// @ART-param: ["RED_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Red"]
// @ART-param: ["RED_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Red"]
// @ART-param: ["RED_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Red"]

// @ART-param: ["GRN_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Green"]
// @ART-param: ["GRN_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Green"]
// @ART-param: ["GRN_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Green"]

// @ART-param: ["BLU_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Blue"]
// @ART-param: ["BLU_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Blue"]
// @ART-param: ["BLU_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Blue"]

// @ART-param: ["CYN_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Cyan"]
// @ART-param: ["CYN_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Cyan"]
// @ART-param: ["CYN_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Cyan"]

// @ART-param: ["MAG_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Magenta"]
// @ART-param: ["MAG_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Magenta"]
// @ART-param: ["MAG_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Magenta"]

// @ART-param: ["YEL_H", "Hue", -1.0, 1.0, 0.0, 0.001, "Yellow"]
// @ART-param: ["YEL_S", "Saturation", -1.0, 1.0, 0.0, 0.001, "Yellow"]
// @ART-param: ["YEL_L", "Lightness", -1.0, 1.0, 0.0, 0.001, "Yellow"]

// @ART-param: ["BLK_R", "Red", -0.1, 0.1, 0.0, 0.0001, "Black"]
// @ART-param: ["BLK_G", "Green", -0.1, 0.1, 0.0, 0.0001, "Black"]
// @ART-param: ["BLK_B", "Blue", -0.1, 0.1, 0.0, 0.0001, "Black"]

// @ART-param: ["WHT_R", "Red", 0.5, 1.5, 1, 0.001, "White"]
// @ART-param: ["WHT_G", "Green", 0.5, 1.5, 1, 0.001, "White"]
// @ART-param: ["WHT_B", "Blue", 0.5, 1.5, 1, 0.001, "White"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float RED_H, float RED_S, float RED_L,
              float GRN_H, float GRN_S, float GRN_L,
              float BLU_H, float BLU_S, float BLU_L,
              float CYN_H, float CYN_S, float CYN_L,
              float MAG_H, float MAG_S, float MAG_L,
              float YEL_H, float YEL_S, float YEL_L,
              float BLK_R, float BLK_G, float BLK_B,
              float WHT_R, float WHT_G, float WHT_B)              
{
    float blk[3] = {BLK_R, BLK_G, BLK_B};
    float wht[3] = {WHT_R, WHT_G, WHT_B};
    float red[3] = torgb(1, 0, 0, RED_H, RED_S, RED_L);
    float grn[3] = torgb(0, 1, 0, GRN_H, GRN_S, GRN_L);
    float blu[3] = torgb(0, 0, 1, BLU_H, BLU_S, BLU_L);
    float cyn[3] = torgb(0, 1, 1, CYN_H, CYN_S, CYN_L);
    float mag[3] = torgb(1, 0, 1, MAG_H, MAG_S, MAG_L);
    float yel[3] = torgb(1, 1, 0, YEL_H, YEL_S, YEL_L);

    float rgb[3] = tetrainterp(r, g, b, blk, wht, red, grn, blu, cyn, mag, yel);

    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
