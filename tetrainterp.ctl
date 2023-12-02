// Tetrahedral Interpolation for Davinci Resolve, ported to ART
// copyright of the original code follows
// 
// MIT License

// Copyright (c) 2021 calvinsilly, Ember Light, Nick Eason

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// https://github.com/hotgluebanjo

// @ART-colorspace: "rec2020"
// @ART-label: "Tetrahedral interpolation"

// @ART-param: ["BLK_R", "Red", -0.1, 0.1, 0.0, 0.0001, "Black"]
// @ART-param: ["BLK_G", "Green", -0.1, 0.1, 0.0, 0.0001, "Black"]
// @ART-param: ["BLK_B", "Blue", -0.1, 0.1, 0.0, 0.0001, "Black"]

// @ART-param: ["WHT_R", "Red",0.0, 1.25, 1.0,  0.001, "White"]
// @ART-param: ["WHT_G", "Green",0.0, 1.25, 1.0,  0.001, "White"]
// @ART-param: ["WHT_B", "Blue",0.0, 1.25, 1.0,  0.001, "White"]

// @ART-param: ["RED_R", "Red", -1.0, 3.0, 1.0, 0.001, "Red"]
// @ART-param: ["RED_G", "Green", -2.0, 2.0, 0.0, 0.001, "Red"]
// @ART-param: ["RED_B", "Blue", -2.0, 2.0, 0.0, 0.001, "Red"]

// @ART-param: ["GRN_R", "Red", -2.0, 2.0,  0.0, 0.001, "Green"]
// @ART-param: ["GRN_G", "Green", -1.0, 3.0,  1.0, 0.001, "Green"]
// @ART-param: ["GRN_B", "Blue", -2.0, 2.0,  0.0, 0.001, "Green"]

// @ART-param: ["BLU_R", "Red", -2.0, 2.0,  0.0, 0.001, "Blue"]
// @ART-param: ["BLU_G", "Green", -2.0, 2.0,  0.0, 0.001, "Blue"]
// @ART-param: ["BLU_B", "Blue", -1.0, 3.0,  1.0, 0.001, "Blue"]

// @ART-param: ["CYN_R", "Red", -2.0, 2.0,  0.0, 0.001, "Cyan"]
// @ART-param: ["CYN_G", "Green", -1.0, 3.0,  1.0, 0.001, "Cyan"]
// @ART-param: ["CYN_B", "Blue", -1.0, 3.0,  1.0, 0.001, "Cyan"]

// @ART-param: ["MAG_R", "Red", -1.0, 3.0,  1.0, 0.001, "Magenta"]
// @ART-param: ["MAG_G", "Green", -2.0, 2.0,  0.0, 0.001, "Magenta"]
// @ART-param: ["MAG_B", "Blue", -1.0, 3.0,  1.0, 0.001, "Magenta"]

// @ART-param: ["YEL_R", "Red", -1.0, 3.0,  1.0, 0.001, "Yellow"]
// @ART-param: ["YEL_G", "Green", -1.0, 3.0,  1.0, 0.001, "Yellow"]
// @ART-param: ["YEL_B", "Blue", -2.0, 2.0,  0.0, 0.001, "Yellow"]

void ART_main(varying float p_R, varying float p_G, varying float p_B,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float BLK_R, float BLK_G, float BLK_B,
              float WHT_R, float WHT_G, float WHT_B,
              float RED_R, float RED_G, float RED_B,
              float GRN_R, float GRN_G, float GRN_B,
              float BLU_R, float BLU_G, float BLU_B,
              float CYN_R, float CYN_G, float CYN_B,
              float MAG_R, float MAG_G, float MAG_B,
              float YEL_R, float YEL_G, float YEL_B)
{
    float rgb[3];

    float blk[3] = {BLK_R, BLK_G, BLK_B};
    float wht[3] = {WHT_R, WHT_G, WHT_B};
    float red[3] = {RED_R, RED_G, RED_B}; 
    float grn[3] = {GRN_R, GRN_G, GRN_B};
    float blu[3] = {BLU_R, BLU_G, BLU_B};
    float cyn[3] = {CYN_R, CYN_G, CYN_B};
    float mag[3] = {MAG_R, MAG_G, MAG_B};
    float yel[3] = {YEL_R, YEL_G, YEL_B};

    if (p_R > p_G) {
        if (p_G > p_B) {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (red[i] - blk[i]) + blk[i] + p_G * (yel[i] - red[i]) + p_B * (wht[i] - yel[i]);
            }
        } else if (p_R > p_B) {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (red[i] - blk[i]) + blk[i] + p_G * (wht[i] - mag[i]) + p_B * (mag[i] - red[i]);
            }
        } else {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (mag[i] - blu[i]) + p_G * (wht[i] - mag[i]) + p_B * (blu[i] - blk[i]) + blk[i];
            }
        }
    } else {
        if (p_B > p_G) {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (wht[i] - cyn[i]) + p_G * (cyn[i] - blu[i]) + p_B * (blu[i] - blk[i]) + blk[i];
            }
        } else if (p_B > p_R) {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (wht[i] - cyn[i]) + p_G * (grn[i] - blk[i]) + blk[i] + p_B * (cyn[i] - grn[i]);
            }
        } else {
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = p_R * (yel[i] - grn[i]) + p_G * (grn[i] - blk[i]) + blk[i] + p_B * (wht[i] - yel[i]);
            }
        }
    }

    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
