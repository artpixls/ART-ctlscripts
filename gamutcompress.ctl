// ACES-style gamut compression
//
// tweaked from the original from https://github.com/jedypod/gamut-compress

// @ART-colorspace: "rec2020"
// @ART-label: "Gamut compression"

import "_artlib";

const float primaries_p3[3][2] = {
    {0.680, 0.320},
    {0.265, 0.690},
    {0.150, 0.060}
};

const float xyz_p3[3][3] = {
    {0.4451, 0.2771, 0.1723},
    {0.2095, 0.7216, 0.06891},
    {0.0, 0.047, 0.9073}
};

const float to_p3[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_p3),
                                                     xyz_rec2020));
const float from_p3[3][3] = invert_f33(to_p3);

const float to_rec709[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_rec709),
                                                         xyz_rec2020));
const float from_rec709[3][3] = invert_f33(to_rec709);

// @ART-param: ["colorspace", "Target gamut", ["Rec.2020", "Rec.709 / sRGB", "DCI-P3"]]
// @ART-param: ["th_c", "Cyan", 0.0, 0.75, 0.1, 0.01, "Threshold"]
// @ART-param: ["th_m", "Magenta", 0.0, 0.75, 0.2, 0.01, "Threshold"]
// @ART-param: ["th_y", "Yellow", 0.0, 0.75, 0.5, 0.01, "Threshold"]
// @ART-param: ["d_c", "Cyan", 0.0, 0.4, 0.15, 0.01, "Distance"]
// @ART-param: ["d_m", "Magenta", 0.0, 0.4, 0.25, 0.01, "Distance"]
// @ART-param: ["d_y", "Yellow", 0.0, 0.4, 0.05, 0.01, "Distance"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int colorspace,
              float th_c, float th_m, float th_y,
              float d_c, float d_m, float d_y)
{ 
    float rgb[3] = {r, g, b};
  
    // Amount of outer gamut to affect
    float th[3] = {1.0 - th_c, 1.0 - th_m, 1.0 - th_y};

    // Distance limit: How far beyond the gamut boundary to compress
    float dl[3] = {1.0 + d_c, 1.0 + d_m, 1.0 + d_y};

    // Calculate scale so compression function passes through distance limit: (x=dl, y=1)
    float s[3];
    for (int i = 0; i < 3; i = i+1) {
        s[i] = (1.0  - th[i])/sqrt(fmax(1.001, dl[0])-1.0);
    }

    // convert to target colorspace
    if (colorspace == 1) { // rec709
        rgb = mult_f3_f33(rgb, to_rec709);
    } else if (colorspace == 2) { // DCI P3
        rgb = mult_f3_f33(rgb, to_p3);
    }
  
    // Achromatic axis
    float ac = fmax(rgb[0], fmax(rgb[1], rgb[2]));

    // Inverse RGB Ratios: distance from achromatic axis
    float d[3] = {0, 0, 0};
    if (ac != 0) {
        for (int i = 0; i < 3; i = i+1) {
            d[i] = (ac - rgb[i]) / fabs(ac);
        }
    }

    float cd[3] = { d[0], d[1], d[2] }; // Compressed distance
    // Parabolic compression function: https://www.desmos.com/calculator/nvhp63hmtj
    for (int i = 0; i < 3; i = i+1) {
        if (d[i] >= th[i]) {
            cd[i] = s[i] * sqrt(d[i] - th[i] + s[i]*s[i]/4.0) - s[i] * sqrt(s[i] * s[i] / 4.0) + th[i];
        }
    }

    // Inverse RGB Ratios to RGB
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = ac - cd[i] * fabs(ac);
    }

    // Linear to working colorspace
    if (colorspace == 1) {
        rgb = mult_f3_f33(rgb, from_rec709);
    } else if (colorspace == 2) {
        rgb = mult_f3_f33(rgb, from_p3);
    }

    // Return output RGB
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
