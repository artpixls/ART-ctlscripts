// subtractive color mixing method from
//   http://scottburns.us/subtractive-color-mixture/
// original author: Scott Allen Burns
// license: Creative Commons Attribution-ShareAlike 4.0 International License.

// @ART-colorspace: "rec2020"
// @ART-label: "Subtractive color mixing"
// @ART-lut: 32

import "_artlib";

// precomputed "T" matrix for converting from a reflectance curve
// to a linear sRGB value.
// 
// See http://scottburns.us/subtractive-color-mixture-2/
// for more derivation and more information.
// 
const float T[3][36] = {
    {5.47813E-05, 0.000184722, 0.000935514, 0.003096265, 0.009507714, 0.017351596, 0.022073595, 0.016353161, 0.002002407, -0.016177731, -0.033929391, -0.046158952, -0.06381706, -0.083911194, -0.091832385, -0.08258148, -0.052950086, -0.012727224, 0.037413037, 0.091701812, 0.147964686, 0.181542886, 0.210684154, 0.210058081, 0.181312094, 0.132064724, 0.093723787, 0.057159281, 0.033469657, 0.018235464, 0.009298756, 0.004023687, 0.002068643, 0.00109484, 0.000454231, 0.000255925},
    {-4.65552E-05, -0.000157894, -0.000806935, -0.002707449, -0.008477628, -0.016058258, -0.02200529, -0.020027434, -0.011137726, 0.003784809, 0.022138944, 0.038965605, 0.063361718, 0.095981626, 0.126280277, 0.148575844, 0.149044804, 0.14239936, 0.122084916, 0.09544734, 0.067421931, 0.035691251, 0.01313278, -0.002384996, -0.009409573, -0.009888983, -0.008379513, -0.005606153, -0.003444663, -0.001921041, -0.000995333, -0.000435322, -0.000224537, -0.000118838, -4.93038E-05, -2.77789E-05},
    {0.00032594, 0.001107914, 0.005677477, 0.01918448, 0.060978641, 0.121348231, 0.184875618, 0.208804428, 0.197318551, 0.147233899, 0.091819086, 0.046485543, 0.022982618, 0.00665036, -0.005816014, -0.012450334, -0.015524259, -0.016712927, -0.01570093, -0.013647887, -0.011317812, -0.008077223, -0.005863171, -0.003943485, -0.002490472, -0.001440876, -0.000852895, -0.000458929, -0.000248389, -0.000129773, -6.41985E-05, -2.71982E-05, -1.38913E-05, -7.35203E-06, -3.05024E-06, -1.71858E-06}
};


// Matrix "B12" which converts linear sRGB values (0-1) to a
// "representative" reflectance curve (over wavelengths
// 380 to 730 nm, in 10 nm intervals).
//
// See http://scottburns.us/reflectance-curves-from-srgb/
// for more derivation and more information.
const float B12[36][3] = {
   {0.0933, -0.1729, 1.0796},
   {0.0933, -0.1728, 1.0796},
   {0.0932, -0.1725, 1.0794},
   {0.0927, -0.1710, 1.0783},
   {0.0910, -0.1654, 1.0744},
   {0.0854, -0.1469, 1.0615},
   {0.0723, -0.1031, 1.0308},
   {0.0487, -0.0223, 0.9736},
   {0.0147, 0.0980, 0.8873},
   {-0.0264, 0.2513, 0.7751},
   {-0.0693, 0.4234, 0.6459},
   {-0.1080, 0.5983, 0.5097},
   {-0.1374, 0.7625, 0.3749},
   {-0.1517, 0.9032, 0.2486},
   {-0.1437, 1.0056, 0.1381},
   {-0.1080, 1.0581, 0.0499},
   {-0.0424, 1.0546, -0.0122},
   {0.0501, 0.9985, -0.0487},
   {0.1641, 0.8972, -0.0613},
   {0.2912, 0.7635, -0.0547},
   {0.4217, 0.6129, -0.0346},
   {0.5455, 0.4616, -0.0071},
   {0.6545, 0.3238, 0.0217},
   {0.7421, 0.2105, 0.0474},
   {0.8064, 0.1262, 0.0675},
   {0.8494, 0.0692, 0.0814},
   {0.8765, 0.0330, 0.0905},
   {0.8922, 0.0121, 0.0957},
   {0.9007, 0.0006, 0.0987},
   {0.9052, -0.0053, 0.1002},
   {0.9073, -0.0082, 0.1009},
   {0.9083, -0.0096, 0.1012},
   {0.9088, -0.0102, 0.1014},
   {0.9090, -0.0105, 0.1015},
   {0.9091, -0.0106, 0.1015},
   {0.9091, -0.0107, 0.1015}
};


// This is the Least Slope Squared (LSS) algorithm for generating
// a "reasonable" reflectance curve from a given sRGB color triplet.
// The reflectance spans the wavelength range 380-730 nm in 10 nm increments.

// It solves min sum(rho_i+1 - rho_i)^2 s.t. T rho = rgb,
// using Lagrangian approach.

// B12 is upper-right 36x3 part of inv([D,T';T,zeros(3)])
// sRGB is a three-element vector of target D65-referenced sRGB values in 0-255 range,
// rho is a 36x1 vector of reflectance values over wavelengths 380-730 nm,

// Written by Scott Allen Burns, 4/25/15.
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International
// License (http://creativecommons.org/licenses/by-sa/4.0/).
// For more information, see http://www.scottburns.us/subtractive-color-mixture/

float[36] get_reflectance_curve(float rgb[3])
{
    float rho[36];
    for (int i = 0; i < 36; i = i+1) {
        float v = 0;
        for (int j = 0; j < 3; j = j+1) {
            v = v + B12[i][j] * rgb[j];
        }
        rho[i] = clamp(v, 0, 1);
    }
    return rho;
}


float[36] mix_reflectance_curves(float rho1[36], float rho2[36], float mix)
{
    float mix2 = (1 - mix);
    float res[36];
    for (int i = 0; i < 36; i = i+1) {
        res[i] = pow(rho1[i], mix) * pow(rho2[i], mix2);
    }
    return res;
}


float[3] get_rgb(float rho[36])
{
    float rgb[3];
    for (int i = 0; i < 3; i = i+1) {
        float v = 0;
        for (int j = 0; j < 36; j = j+1) {
            v = v + T[i][j] * rho[j];
        }
        rgb[i] = v;
    }
    return rgb;
}


const float sRGBd65_xyz[3][3] = {
    { 3.2404542, -1.5371385, -0.4985314},
    { -0.9692660,  1.8760108,  0.0415560},
    {0.0556434, -0.2040259,  1.0572252}
};

const float to_srgb[3][3] = transpose_f33(mult_f33_f33(sRGBd65_xyz,
                                                       xyz_rec2020));
const float to_rec2020[3][3] = invert_f33(to_srgb);

// @ART-param: ["mr", "Red", 0, 255, 0, "Color to mix"]
// @ART-param: ["mg", "Green", 0, 255, 0, "Color to mix"]
// @ART-param: ["mb", "Blue", 0, 255, 0, "Color to mix"]
// @ART-param: ["amount", "Amount", 0, 1, 0, 0.001]
// @ART-param: ["norm", "Preserve luminance", false]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int mr, int mg, int mb, float amount, bool norm)
{
    float rgb[3] = mult_f3_f33(mkfloat3(r, g, b), to_srgb);

    float tomix[3] = { mr / 255.0, mg / 255.0, mb / 255.0 };
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = fmax(rgb[i], 0);
        tomix[i] = pow(tomix[i], 2.4);
    }

    float rho_tomix[36] = get_reflectance_curve(tomix);
    float rho_rgb[36] = get_reflectance_curve(rgb);

    float rho[36] = mix_reflectance_curves(rho_tomix, rho_rgb, amount);
    rgb = get_rgb(rho);
    
    rgb = mult_f3_f33(rgb, to_rec2020);

    if (norm) {
        float l = fmax(luminance(r, g, b), 0);
        float l2 = fmax(luminance(rgb[0], rgb[1], rgb[2]), 0);
        if (l2 > 0) {
            float f = l / l2;
            for (int i = 0; i < 3; i = i+1) {
                rgb[i] = rgb[i] * f;
            }
        }
    }
    
    rout = rgb[0];
    gout = rgb[1];
    bout = rgb[2];
}
