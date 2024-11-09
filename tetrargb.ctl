// @ART-colorspace: "rec2020"
// @ART-label: "$CTL_TETRAHEDRAL_COLOR_WARPING_RGB;Tetrahedral color warping (RGB)"

import "_tetrainterp";

// @ART-param: ["RED_R", "$CTL_RED;Red", -1.0, 3.0, 1.0, 0.001, "$CTL_RED;Red"]
// @ART-param: ["RED_G", "$CTL_GREEN;Green", -2.0, 2.0, 0.0, 0.001, "$CTL_RED;Red"]
// @ART-param: ["RED_B", "$CTL_BLUE;Blue", -2.0, 2.0, 0.0, 0.001, "$CTL_RED;Red"]

// @ART-param: ["GRN_R", "$CTL_RED;Red", -2.0, 2.0, 0.0, 0.001, "$CTL_GREEN;Green"]
// @ART-param: ["GRN_G", "$CTL_GREEN;Green", -1.0, 3.0, 1.0, 0.001, "$CTL_GREEN;Green"]
// @ART-param: ["GRN_B", "$CTL_BLUE;Blue", -2.0, 2.0, 0.0, 0.001, "$CTL_GREEN;Green"]

// @ART-param: ["BLU_R", "$CTL_RED;Red", -2.0, 2.0, 0.0, 0.001, "$CTL_BLUE;Blue"]
// @ART-param: ["BLU_G", "$CTL_GREEN;Green", -2.0, 2.0, 0.0, 0.001, "$CTL_BLUE;Blue"]
// @ART-param: ["BLU_B", "$CTL_BLUE;Blue", -1.0, 3.0, 1.0, 0.001, "$CTL_BLUE;Blue"]

// @ART-param: ["CYN_R", "$CTL_RED;Red", -2.0, 2.0, 0.0, 0.001, "$CTL_CYAN;Cyan"]
// @ART-param: ["CYN_G", "$CTL_GREEN;Green", -1.0, 3.0, 1.0, 0.001, "$CTL_CYAN;Cyan"]
// @ART-param: ["CYN_B", "$CTL_BLUE;Blue", -1.0, 3.0, 1.0, 0.001, "$CTL_CYAN;Cyan"]

// @ART-param: ["MAG_R", "$CTL_RED;Red", -1.0, 3.0, 1.0, 0.001, "$CTL_MAGENTA;Magenta"]
// @ART-param: ["MAG_G", "$CTL_GREEN;Green", -2.0, 2.0, 0.0, 0.001, "$CTL_MAGENTA;Magenta"]
// @ART-param: ["MAG_B", "$CTL_BLUE;Blue", -1.0, 3.0, 1.0, 0.001, "$CTL_MAGENTA;Magenta"]

// @ART-param: ["YEL_R", "$CTL_RED;Red", -1.0, 3.0, 1.0, 0.001, "$CTL_YELLOW;Yellow"]
// @ART-param: ["YEL_G", "$CTL_GREEN;Green", -1.0, 3.0, 1.0, 0.001, "$CTL_YELLOW;Yellow"]
// @ART-param: ["YEL_B", "$CTL_BLUE;Blue", -2.0, 2.0, 0.0, 0.001, "$CTL_YELLOW;Yellow"]

// @ART-param: ["BLK_R", "$CTL_RED;Red", -0.1, 0.1, 0.0, 0.0001, "$CTL_BLACK;Black"]
// @ART-param: ["BLK_G", "$CTL_GREEN;Green", -0.1, 0.1, 0.0, 0.0001, "$CTL_BLACK;Black"]
// @ART-param: ["BLK_B", "$CTL_BLUE;Blue", -0.1, 0.1, 0.0, 0.0001, "$CTL_BLACK;Black"]

// @ART-param: ["WHT_R", "$CTL_RED;Red", 0.5, 1.5, 1, 0.001, "$CTL_WHITE;White"]
// @ART-param: ["WHT_G", "$CTL_GREEN;Green", 0.5, 1.5, 1, 0.001, "$CTL_WHITE;White"]
// @ART-param: ["WHT_B", "$CTL_BLUE;Blue", 0.5, 1.5, 1, 0.001, "$CTL_WHITE;White"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float RED_R, float RED_G, float RED_B,
              float GRN_R, float GRN_G, float GRN_B,
              float BLU_R, float BLU_G, float BLU_B,
              float CYN_R, float CYN_G, float CYN_B,
              float MAG_R, float MAG_G, float MAG_B,
              float YEL_R, float YEL_G, float YEL_B,
              float BLK_R, float BLK_G, float BLK_B,
              float WHT_R, float WHT_G, float WHT_B)
{
    float blk[3] = {BLK_R, BLK_G, BLK_B};
    float wht[3] = {WHT_R, WHT_G, WHT_B};
    float red[3] = {RED_R, RED_G, RED_B}; 
    float grn[3] = {GRN_R, GRN_G, GRN_B};
    float blu[3] = {BLU_R, BLU_G, BLU_B};
    float cyn[3] = {CYN_R, CYN_G, CYN_B};
    float mag[3] = {MAG_R, MAG_G, MAG_B};
    float yel[3] = {YEL_R, YEL_G, YEL_B};

    float rgb[3] = tetrainterp(r, g, b, blk, wht, red, grn, blu, cyn, mag, yel);

    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
