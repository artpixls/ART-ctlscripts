// ACES-style gamut compression
//
// @ART-colorspace: "rec2020"
// @ART-label: "Gamut compression"

import "_artlib";

const float to_p3[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_p3),
                                                     xyz_rec2020));
const float from_p3[3][3] = invert_f33(to_p3);

const float to_rec709[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_rec709),
                                                         xyz_rec2020));
const float from_rec709[3][3] = invert_f33(to_rec709);

const float to_ap1[3][3] = transpose_f33(mult_f33_f33(invert_f33(xyz_ap1),
                                                      xyz_rec2020));
const float from_ap1[3][3] = invert_f33(to_ap1);

// @ART-param: ["colorspace", "Target gamut", ["Rec.2020", "Rec.709 / sRGB", "DCI-P3", "ACES AP1"], 3]
// @ART-param: ["th_c", "Cyan", 0.0, 1, 0.815, 0.001, "Threshold"]
// @ART-param: ["th_m", "Magenta", 0.0, 1, 0.803, 0.001, "Threshold"]
// @ART-param: ["th_y", "Yellow", 0.0, 1, 0.880, 0.001, "Threshold"]
// @ART-param: ["d_c", "Cyan", 1.001, 2, 1.147, 0.001, "Limit"]
// @ART-param: ["d_m", "Magenta", 1.001, 2, 1.264, 0.001, "Limit"]
// @ART-param: ["d_y", "Yellow", 1.001, 2, 1.312, 0.001, "Limit"]
// @ART-param: ["pwr", "Roll-off", 0.5, 2.0, 1.2, 0.01]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int colorspace,
              float th_c, float th_m, float th_y,
              float d_c, float d_m, float d_y,
              float pwr)
{ 
    float rgb[3] = {r, g, b};

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
    } else if (colorspace == 3) { // ACES AP1
        to_out = to_ap1;
        from_out = from_ap1;
    }

    float th[3] = { th_c, th_m, th_y };
    float dl[3] = { d_c, d_m, d_y };

    rgb = gamut_compress(rgb, th, dl, to_out, from_out, pwr);

    // Return output RGB
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
