// ACES-style gamut compression
//
// tweaked from the original from https://github.com/jedypod/gamut-compress

// @ART-colorspace: "rec2020"
// @ART-label: "Gamut compression"

import "_artlib";

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

    float to_out[3][3] = {
        {1, 0, 0},
        {0, 1, 0},
        {0, 0, 1}
    };
    float from_out[3][3] = to_out;

    if (colorspace == 1) { // rec709
        to_out = to_rec709;
        from_out = from_rec709;
    } else if (colorspace == 2) { // DCI P3
        to_out = to_p3;
        from_out = from_p3;
    }

    rgb = gamut_compress(rgb, th, dl, to_out, from_out);

    // Return output RGB
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
