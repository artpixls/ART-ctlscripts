// customized tone mapping with bits taken from
//  https://github.com/thatcherfreeman/utility-dctls/
//
// Copyright of the original code
/*
MIT License

Copyright (c) 2023 Thatcher Freeman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// 
// @ART-colorspace: "rec2020"
// @ART-label: "ART output transform"
// 

// @ART-param: ["evgain", "Gain (Ev)", 0.0, 4.0, 0.0, 0.01]
// @ART-param: ["contrast", "Contrast", -100, 100, 0]
// @ART-param: ["white_point", "White point", 0.8, 40.0, 1.0, 0.1]
// @ART-param: ["scale_mid_gray", "Scale mid gray with white point", false]
// @ART-param: ["gc_colorspace", "Target space", ["None", "Rec.2020", "Rec.709 / sRGB", "DCI-P3", "Adobe RGB"], 2, "Gamut compression"]
// @ART-param: ["gc_strength", "Strength", 0.7, 2, 1, 0.01, "Gamut compression"]
// @ART-param: ["hue_preservation", "Hue preservation", 0, 1, 0, 0.1]

import "_artlib";

const float to_rec709[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_rec709),
                                                         xyz_rec2020));
const float from_rec709[3][3] = invert_f33(to_rec709);

const float to_p3[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_p3),
                                                     xyz_rec2020));
const float from_p3[3][3] = invert_f33(to_p3);

const float to_adobe[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_adobe),
                                                        xyz_rec2020));
const float from_adobe[3][3] = invert_f33(to_adobe);

float powf(float base, float exp)
{
    return pow(fmax(base, 0), exp);
}


float scene_contrast(float x, float mid_gray, float gamma)
{
    return mid_gray * powf(x / mid_gray, gamma);
}


float display_contrast(float x, float a, float b, float w, float o)
{
    float y = pow(fmax(x - o, 0) / w, a);
    float r = log(y * (b - 1) + 1) / log(b);
    return r * w + o;
}


// g(x) = a * (x / (x+b)) + c
float rolloff_function(float x, float a, float b, float c)
{
    return a * (x / (x + b)) + c;
}


float[3] tonemap(float p_R, float p_G, float p_B,
                 float target_slope, float white_point, float black_point,
                 float mid_gray_in, float mid_gray_out)
{
    float out[3] = { p_R, p_G, p_B };
    for (int i = 0; i < 3; i = i+1) {
        out[i] = out[i] * mid_gray_out / mid_gray_in;
    }

    // Constraint 1: h(0) = black_point
    float c = black_point;
    // Constraint 2: h(infty) = white_point
    float a = white_point - c;
    // Constraint 3: h(mid_out) = mid_out
    float b = (a / (mid_gray_out - c)) *
        (1.0 - ((mid_gray_out - c) / a)) * mid_gray_out;
    // Constraint 4: h'(mid_out) = target_slope
    float gamma = target_slope * powf((mid_gray_out + b), 2.0) / (a * b);

    // h(x) = g(m_i * ((x/m_i)**gamma))
    for (int i = 0; i < 3; i = i+1) {
        out[i] = rolloff_function(scene_contrast(out[i], mid_gray_out, gamma),
                                  a, b, c);
    }
    return out;
}


const float rhue = rgb2hsl(1, 0, 0)[0];
const float bhue = rgb2hsl(0, 0, 1)[0];
const float yhue = rgb2hsl(1, 1, 0)[0];
const float ohue = rgb2hsl(1, 0.5, 0)[0];
const float yrange = fabs(ohue - yhue) * 0.8;
const float rrange = fabs(ohue - rhue);
const float brange = rrange;

float[3] creative_hue_shift(float amount, float in_r, float in_g, float in_b,
                            float white_point, float rgb[3])
{
    float hue = rgb2hsl(in_r, in_g, in_b)[0];
    const float base_shift = 15.0 * amount;
    float hue_shift = base_shift * M_PI / 180.0 * gauss(rhue, rrange, hue);
    hue_shift = hue_shift + -base_shift * M_PI / 180.0 * gauss(bhue, brange, hue);
    hue_shift = hue_shift * clamp((rgb[0] + rgb[1] + rgb[2]) / (3.0 * white_point), 0, 1);
    hue = hue + hue_shift;
    
    float hsl[3] = rgb2hsl(rgb[0], rgb[1], rgb[2]);
    hsl[0] = hue;
    float res[3] = hsl2rgb(hsl);
    return res;
}


// hand-tuned gamut compression parameters
const float base_dl[3] = {1.1, 1.2, 1.5};
const float base_th[3] = {0.85, 0.75, 0.95};

const float mid_gray_in = 0.18;
const float usr_mid_gray_out = 0.18;
const float black_point = 1.0/4096.0;


void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float evgain,
              int contrast, float white_point,
              bool scale_mid_gray, int gc_colorspace, float gc_strength,
              float hue_preservation)
{
    float gain = pow(2, evgain);
    float rgb[3] = { r * gain, g * gain, b * gain };
    
    if (gc_colorspace > 0) {
        float dl[3] = base_dl;
        float th[3] = base_th;
        for (int i = 0; i < 3; i = i+1) {
            dl[i] = dl[i] * gc_strength;
            th[i] = th[i] / sqrt(gc_strength);
        }
        
        float to_out[3][3] = identity_33;
        float from_out[3][3] = identity_33;
        if (gc_colorspace == 2) {
            to_out = to_rec709;
            from_out = from_rec709;
        } else if (gc_colorspace == 3) {
            to_out = to_p3;
            from_out = from_p3;
        } else if (gc_colorspace == 4) {
            to_out = to_adobe;
            from_out = from_adobe;
        }

        rgb = gamut_compress(rgb, th, dl, to_out, from_out);
    }

    float mid_gray_out;
    if (scale_mid_gray) {
        const float dr = white_point - black_point;
        mid_gray_out = usr_mid_gray_out * dr + black_point;
    } else {
        mid_gray_out = usr_mid_gray_out;
    }
    
    const float target_slope = 1.0;
    float res[3] = tonemap(rgb[0], rgb[1], rgb[2],
                           target_slope, white_point, black_point,
                           mid_gray_in, mid_gray_out);

    if (contrast != 0) {
        const float pivot = mid_gray_out / white_point;
        const float c = pow(fabs(contrast / 100.0), 1.5) * 16.0;
        const float b = ite(contrast > 0, 1 + c, 1.0 / (1 + c));
        const float a = log((exp(log(b) * pivot) - 1) / (b - 1)) / log(pivot);
        for (int i = 0; i < 3; i = i+1) {
            res[i] = display_contrast(res[i], a, b, white_point, black_point);
        }
    }

    res = creative_hue_shift(1.0 - hue_preservation, r, g, b, white_point, res);

    rout = clamp(res[0], 0, white_point);
    gout = clamp(res[1], 0, white_point);
    bout = clamp(res[2], 0, white_point);
}
