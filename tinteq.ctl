/**
 *  Tint by luminance ART CTL script.
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

// @ART-label: "Tint by luminance"
// @ART-colorspace: "rec2020"

import "_artlib";


float lum(float rgb[3])
{
    float Y = luminance(rgb[0], rgb[1], rgb[2]);
    return clamp(Y, 1e-5, 32.0);
}


const float centers[12] = {
    -16.0, -14.0, -12.0, -10.0, -8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0
};


float gauss_sum()
{
    float res = 0;
    for (int i = 0; i < 12; i = i+1) {
        res = res + gauss(centers[i], 2, 0);
    }
    return res;
}

const float w_sum = gauss_sum();

const float luma_lo = -14.0;
const float luma_hi = 4.0;


float[12] get_factors(float bands[5])
{
    float res[12] = {
        bands[0], 
        bands[0], 
        bands[0], 
        bands[0], 
        bands[0], 
        bands[1],
        bands[2],
        bands[3],
        bands[4],
        bands[4],
        bands[4],
        bands[4]
    };
    return res;
}


float get_gain(float y, float factors[12])
{
    float luma = clamp(log2(y), luma_lo, luma_hi);
    float correction = 0;
    for (int c = 0; c < 12; c = c+1) {
        correction = correction + gauss(centers[c], 2, luma) * factors[c];
    }
    return correction / w_sum;
}


void hs2uv(float h, float s, output float u, output float v)
{
    float a = h / 180.0 * M_PI;
    float f = s * 1.5;
    u = f * sin(a);
    v = f * cos(a);
}


// @ART-param: ["blacks_h", "Hue", 0, 360, 0, 0.1, "$TP_TONE_EQUALIZER_BAND_0"]
// @ART-param: ["blacks_s", "Strength", 0, 1, 0, 0.01, "$TP_TONE_EQUALIZER_BAND_0"]
// @ART-param: ["shadows_h", "Hue", 0, 360, 0, 0.1, "$TP_TONE_EQUALIZER_BAND_1"]
// @ART-param: ["shadows_s", "Strength", 0, 1, 0, 0.01, "$TP_TONE_EQUALIZER_BAND_1"]
// @ART-param: ["midtones_h", "Hue", 0, 360, 0, 0.1, "$TP_TONE_EQUALIZER_BAND_2"]
// @ART-param: ["midtones_s", "Strength", 0, 1, 0, 0.01, "$TP_TONE_EQUALIZER_BAND_2"]
// @ART-param: ["highlights_h", "Hue", 0, 360, 0, 0.1, "$TP_TONE_EQUALIZER_BAND_3"]
// @ART-param: ["highlights_s", "Strength", 0, 1, 0, 0.01, "$TP_TONE_EQUALIZER_BAND_3"]
// @ART-param: ["whites_h", "Hue", 0, 360, 0, 0.1, "$TP_TONE_EQUALIZER_BAND_4"]
// @ART-param: ["whites_s", "Strength", 0, 1, 0, 0.01, "$TP_TONE_EQUALIZER_BAND_4"]
// @ART-param: ["pivot", "$TP_TONE_EQUALIZER_PIVOT", -4, 4, 0, 0.05]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float blacks_h,
              float blacks_s,
              float shadows_h,
              float shadows_s,
              float midtones_h,
              float midtones_s,
              float highlights_h,
              float highlights_s,
              float whites_h,
              float whites_s,
              float pivot)
{
    const float gain = 1.0 / pow(2, -pivot);
    const float bands_h[5] =
        { blacks_h, shadows_h, midtones_h, highlights_h, whites_h };
    const float bands_s[5] =
        { blacks_s, shadows_s, midtones_s, highlights_s, whites_s };
    
    float bands_u[5];
    float bands_v[5];
    for (int i = 0; i < 5; i = i+1) {
        hs2uv(bands_h[i], bands_s[i], bands_u[i], bands_v[i]);
    }
   
    const float u_factors[12] = get_factors(bands_u);
    const float v_factors[12] = get_factors(bands_v);
    float rgb[3] = { r * gain, g * gain, b * gain };
    float Y = lum(rgb);
    float v_f = get_gain(Y, v_factors);
    float u_f = get_gain(Y, u_factors);

    float luv[3] = rgb2luv(r, g, b);
    rgb = luv2rgb(luv[0], luv[1] + u_f * luv[0], luv[2] + v_f * luv[0]);
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
