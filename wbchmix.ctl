/**
 *  ART CTL script for white balance and color primaries correction
 *
 *  Copyright 2023 Alberto Griggio <alberto.griggio@gmail.com>
 *
 *  ART is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  ART is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with ART.  If not, see <http://www.gnu.org/licenses/>.
 */

// @ART-label: "$CTL_WB_AND_PRIMARIES_CORRECTION;WB and primaries correction"
// @ART-colorspace: "rec2020"

import "_artlib";


const float red[3] = { 1, 0, 0 };
const float green[3] = { 0, 1, 0 };
const float blue[3] = { 0, 0, 1 };
const float red_xy[3] = rgb2xy(red);
const float green_xy[3] = rgb2xy(green);
const float blue_xy[3] = rgb2xy(blue);


float[3] tweak_xy(float xy[3], float hue, float sat, float hrange, float srange)
{
    float x = xy[0] - D50_xy[0];
    float y = xy[1] - D50_xy[1];
    float radius = hypot(x, y) * (1.0 + sat * srange);
    float angle = atan2(y, x) + hue * hrange;
    float xx = radius * cos(angle) + D50_xy[0];
    float yy = radius * sin(angle) + D50_xy[1];
    float res[3] = { xx, yy, 1 - xx - yy };
    return res;
}


const float rec2020_xyz_t[3][3] = transpose_f33(invert_f33(xyz_rec2020));
const float white_temp_k = 5000;
const float ref_white_xy[3] = temp_to_xy(white_temp_k);
const float ref_mul[3] = mult_f3_f33(
    mkfloat3(ref_white_xy[0] / ref_white_xy[1], 1,
             ref_white_xy[2] / ref_white_xy[1]),
    rec2020_xyz_t);

float[3][3] get_wb_matrix(float temp, float tint)
{
    float temp_k = white_temp_k;
    if (temp > 0) {
        temp_k = temp_k - 20 * temp;
    } else {
        temp_k = temp_k - 50 * temp;
    }
    const float white[3] = temp_tint_to_xy(temp_k, -tint / 1000);
    float xw = white[0] / white[1];
    float zw = white[2] / white[1];
    float mul[3] = mult_f3_f33(mkfloat3(xw, 1, zw), rec2020_xyz_t);
    for (int i = 0; i < 3; i = i+1) {
        mul[i] = mul[i] / ref_mul[i];
    }
    float m = luminance(mul[0], mul[1], mul[2]);
    const float wb[3][3] = {
        {mul[0] / m, 0, 0},
        {0, mul[1] / m, 0},
        {0, 0, mul[2] / m}
    };
    return wb;
}


float[3][3] get_primaries_matrix(float rhue, float rsat, float ghue, float gsat,
                                 float bhue, float bsat)
{
    const float M[3][3] =
        matrix_from_primaries(red_xy, green_xy, blue_xy, D50_xy);
    const float N[3][3] = matrix_from_primaries(
        tweak_xy(red_xy, rhue / 100, rsat / 100, 0.47, 0.3),
        tweak_xy(green_xy, ghue / 100, gsat / 100, 0.63, 0.5),
        tweak_xy(blue_xy, bhue / 100, bsat / 100, 0.47, 0.5),
        D50_xy);
    const float res[3][3] = mult_f33_f33(invert_f33(M), N);
    return res;
}


float[3][3] get_matrix(float rhue, float rsat, float ghue, float gsat,
                       float bhue, float bsat, float temp, float tint)
{
    return mult_f33_f33(get_wb_matrix(temp, tint),
                        get_primaries_matrix(rhue, rsat, ghue, gsat,
                                             bhue, bsat));
}


// @ART-param: ["temp", "$TP_WBALANCE_TEMPERATURE", -100, 100, 0, 0.1, "$TP_WBALANCE_LABEL"]
// @ART-param: ["tint", "$TP_WBALANCE_GREEN", -100, 100, 0, 0.1, "$TP_WBALANCE_LABEL"]
// @ART-param: ["rhue", "$TP_CHMIXER_HUE", -250, 250, 0, 1, "$TP_CHMIXER_PRIMARY_R"]
// @ART-param: ["rsat", "$TP_CHMIXER_SAT", -100, 100, 0, 1, "$TP_CHMIXER_PRIMARY_R"]
// @ART-param: ["ghue", "$TP_CHMIXER_HUE", -250, 250, 0, 1, "$TP_CHMIXER_PRIMARY_G"]
// @ART-param: ["gsat", "$TP_CHMIXER_SAT", -100, 100, 0, 1, "$TP_CHMIXER_PRIMARY_G"]
// @ART-param: ["bhue", "$TP_CHMIXER_HUE", -250, 250, 0, 1, "$TP_CHMIXER_PRIMARY_B"]
// @ART-param: ["bsat", "$TP_CHMIXER_SAT", -100, 100, 0, 1, "$TP_CHMIXER_PRIMARY_B"]
// @ART-param: ["blkhue", "$CTL_HUE;Hue", 0, 360, 0, 1, "$CTL_SHADOWS_TINT;Shadows tint"]
// @ART-param: ["blksat", "$CTL_SATURATION;Saturation", 0.0, 1.0, 0.0, 0.01, "$CTL_SHADOWS_TINT;Shadows tint"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float temp, float tint,
              float rhue, float rsat,
              float ghue, float gsat,
              float bhue, float bsat,
              float blkhue, float blksat)
{
    const float M[3][3] =
        get_matrix(rhue, rsat, ghue, gsat, bhue, bsat, temp, tint);
    const float blkhsl[3] = { blkhue / 180.0 * M_PI, blksat * 0.02, 0 };
    const float blk[3] = hsl2rgb(blkhsl);
    
    float rgb[3] = { r, g, b };
    rgb = mult_f3_f33(rgb, M);

    rout = rgb[0] + blk[0];
    gout = rgb[1] + blk[1];
    bout = rgb[2] + blk[2];
}
