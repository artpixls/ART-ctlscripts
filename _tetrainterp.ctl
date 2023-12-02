// Tetrahedral Interpolation for Davinci Resolve, ported to ART
// copyright of the original code follows
//
// Taken from https://github.com/hotgluebanjo/TetraInterp-DCTL
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

float[3] tetrainterp(varying float p_R, varying float p_G, varying float p_B,
                     float blk[3], float wht[3],
                     float red[3], float grn[3], float blu[3],
                     float cyn[3], float mag[3], float yel[3])
{
    float rgb[3];

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

    return rgb;
}
