// @ART-label: "$CTL_COLOR_BALANCE_RGB;Color balance RGB"
// @ART-colorspace: "rec2020"

// adapted (with simplifications/shortcuts) from colorbalancergb.c of
// darktable. copyright of the original code follows
/*
    Copyright (C) 2020-2024 darktable developers.

    darktable is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    darktable is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with darktable.  If not, see <http://www.gnu.org/licenses/>.
*/

import "_artlib";

const float shadows_weight = 2.0 + 1.0 * 2.0;
const float highlights_weight = 2.0 + 1.0 * 2.0;
const float white_fulcrum = 1.0;
const float midtones_weight = sqr(shadows_weight) * sqr(highlights_weight) / (sqr(shadows_weight) + sqr(highlights_weight));
const float grey_fulcrum = 0.1845;
const float mask_grey_fulcrum = pow(grey_fulcrum, 0.4101205819200422);
    
float[3] opacity_masks(float x)
{
    float out[3];
    
    float x_offset = (x - mask_grey_fulcrum);
    float x_offset_norm = x_offset / mask_grey_fulcrum;
    float alpha = 1.0 / (1.0 + exp(x_offset_norm * shadows_weight));    // opacity of shadows
    float beta = 1.0 / (1.0 + exp(-x_offset_norm * highlights_weight)); // opacity of highlights
    float alpha_comp = 1.0 - alpha;
    float beta_comp = 1.0 - beta;
    float gamma = exp(-sqr(x_offset) * midtones_weight / 4.0) * sqr(alpha_comp) * sqr(beta_comp) * 8.0; // opacity of midtones

    out[0] = alpha;
    out[1] = gamma;
    out[2] = beta;

    return out;
}


float[3] to_perceptual(float hsl[3])
{
    float rgb[3] = hsl2rgb(hsl);
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = pow(fmax(rgb[i], 0), 1.0/2.2);
    }
    float res[3] = rgb2hsl(rgb[0], rgb[1], rgb[2]);
    res[2] = res[2] * (pow(res[1], 1.33) + 1);
    return res;
}


float[3] from_perceptual(float hsl[3])
{
    float res[3] = hsl;
    res[2] = res[2] / (pow(res[1], 1.33) + 1);
    float rgb[3] = hsl2rgb(res);
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = pow(fmax(rgb[i], 0), 2.2);
    }
    return rgb2hsl(rgb[0], rgb[1], rgb[2]);
}


float soft_clip(float x, float soft_threshold, float hard_threshold)
{
    float norm = hard_threshold - soft_threshold;
    if (x > soft_threshold) {
        return soft_threshold + (1.0 - exp(-(x - soft_threshold) / norm)) * norm;
    } else {
        return x;
    }
}


// @ART-param: ["hue", "$CTL_HUE_SHIFT;Hue shift", -180, 180, 0, 0.01]
// @ART-param: ["vib", "$CTL_VIBRANCE;Vibrance", -1, 1, 0, 0.01]
// @ART-param: ["contr", "$CTL_CONTRAST;Contrast", -1, 1, 0, 0.01]

// @ART-param: ["chroma", "$CTL_GLOBAL_CHROMA;Global chroma", -1, 1, 0, 0.01, "$CTL_LINEAR_CHROMA_GRADING;Linear chroma grading"]
// @ART-param: ["schroma", "$CTL_SHADOWS;Shadows", -1, 1, 0, 0.01, "$CTL_LINEAR_CHROMA_GRADING;Linear chroma grading"]
// @ART-param: ["mchroma", "$CTL_MIDTONES;Midtones", -1, 1, 0, 0.01, "$CTL_LINEAR_CHROMA_GRADING;Linear chroma grading"]
// @ART-param: ["hchroma", "$CTL_HIGHLIGHTS;Highlights", -1, 1, 0, 0.01, "$CTL_LINEAR_CHROMA_GRADING;Linear chroma grading"]

// @ART-param: ["sat", "$CTL_GLOBAL_SATURATION;Global saturation", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_SATURATION_GRADING;Perceptual saturation grading"]
// @ART-param: ["ssat", "$CTL_SHADOWS;Shadows", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_SATURATION_GRADING;Perceptual saturation grading"]
// @ART-param: ["msat", "$CTL_MIDTONES;Midtones", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_SATURATION_GRADING;Perceptual saturation grading"]
// @ART-param: ["hsat", "$CTL_HIGHLIGHTS;Highlights", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_SATURATION_GRADING;Perceptual saturation grading"]

// @ART-param: ["bril", "$CTL_GLOBAL_BRILLIANCE;Global brilliance", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_BRILLIANCE_GRADING;Perceptual brilliance grading"]
// @ART-param: ["sbril", "$CTL_SHADOWS;Shadows", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_BRILLIANCE_GRADING;Perceptual brilliance grading"]
// @ART-param: ["mbril", "$CTL_MIDTONES;Midtones", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_BRILLIANCE_GRADING;Perceptual brilliance grading"]
// @ART-param: ["hbril", "$CTL_HIGHLIGHTS;Highlights", -1, 1, 0, 0.01, "$CTL_PERCEPTUAL_BRILLIANCE_GRADING;Perceptual brilliance grading"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float hue, float vib, float contr,
              float chroma, float schroma, float mchroma, float hchroma,
              float sat, float ssat, float msat, float hsat,
              float bril, float sbril, float mbril, float hbril)
{
    const float hue_angle = hue * M_PI / 180.0;
    const float contrast = 1 + sgn(contr) * pow(fabs(contr), 1.5);

    float hsl[3] = rgb2hsl(r, g, b);
    hsl[2] = fmax(hsl[2], 0);
    float masks[3] = opacity_masks(pow(hsl[2], 0.4101205819200422));

    hsl[0] = hsl[0] + hue_angle;
    float chroma_boost = chroma + masks[0] * schroma + masks[1] * mchroma + masks[2] * hchroma;
    float vibrance = vib * (1.0 - pow(hsl[1], fabs(vib)));
    float chroma_factor = fmax(1.0 + chroma_boost + vibrance, 0);
    hsl[1] = hsl[1] * chroma_factor;

    hsl[2] = grey_fulcrum * pow(hsl[2] / grey_fulcrum, contrast);
    
    hsl = to_perceptual(hsl);

    float radius = hypot(hsl[1], hsl[2]);
    float sin_T = ite(radius > 0, hsl[1] / radius, 0);
    float cos_T = ite(radius > 0, hsl[2] / radius, 0);
    float M_rot_inv[2][2] = { { cos_T,  sin_T }, { -sin_T, cos_T } };
    float P = fmax(FLT_MIN, hsl[1]); 
    float W = sin_T * hsl[1] + cos_T * hsl[2];

    float a = fmax(1.0 + sat + ssat * masks[0] + msat * masks[1] + hsat * masks[2], 0);
    float b = fmax(1.0 + bril + sbril * masks[0] + mbril * masks[1] + hbril * masks[2], 0);

    float max_a = hypot(P, W) / P;
    a = soft_clip(a, 0.5 * max_a, max_a);

    float P_prime = (a - 1) * P;
    float W_prime = sqrt(sqr(P) * (1.0 - sqr(a)) + sqr(W)) * b;

    hsl[1] = fmax(M_rot_inv[0][0] * P_prime + M_rot_inv[0][1] * W_prime, 0);
    hsl[2] = fmax(M_rot_inv[1][0] * P_prime + M_rot_inv[1][1] * W_prime, 0);

    hsl = from_perceptual(hsl);
    float rgb[3] = hsl2rgb(hsl);
    
    /* const float gc_thresh[3] = {0.85, 0.75, 0.95}; */
    /* const float gc_dist[3] = {1.1, 1.2, 1.5}; */
    /* rgb = gamut_compress(rgb, gc_thresh, gc_dist, identity_33, identity_33); */

    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
