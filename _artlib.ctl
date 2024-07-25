/**
 *
 *  This file is part of ART.
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

const float xyz_rec2020[3][3] = {
    {0.6734241,  0.1656411,  0.1251286},
    {0.2790177,  0.6753402,  0.0456377},
    { -0.0019300,  0.0299784, 0.7973330}
};

const float xyz_rec709[3][3] = {
    {0.4360747,  0.3850649, 0.1430804},
    {0.2225045,  0.7168786,  0.0606169},
    {0.0139322,  0.0971045,  0.7141733}
};

const float xyz_p3[3][3] = {
    {0.4451, 0.2771, 0.1723},
    {0.2095, 0.7216, 0.06891},
    {0.0, 0.047, 0.9073}
};

const float xyz_adobe[3][3] = {
    {0.6097559, 0.2052401, 0.1492240},
    {0.3111242, 0.6256560, 0.0632197},
    {0.0194811, 0.0608902, 0.7448387}
};

const float xyz_ap1[3][3] = {
    {0.689697, 0.149944, 0.124559},
    {0.284448, 0.671758  , 0.043794},
    {-0.006043, 0.009998, 0.820945}
};

const float xyz_rec2020_t[3][3] = transpose_f33(xyz_rec2020);

const float identity_33[3][3] = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1}
};


float luminance(float r, float g, float b)
{
    return r * xyz_rec2020[1][0] + g * xyz_rec2020[1][1] + b * xyz_rec2020[1][2];
}


float[3] rgb2luv(float r, float g, float b)
{
    float l = luminance(r, g, b);
    float u = l - b;
    float v = r - l;
    float res[3] = {l, u, v};
    return res;
}


float[3] rgb2hsl(float r, float g, float b)
{
    float luv[3] = rgb2luv(r, g, b);
    float l = luv[0];
    float u = luv[1];
    float v = luv[2];
    float h = atan2(u, v);
    float s = hypot(u, v);
    float res[3] = { h, s, l };
    return res;
}


float[3] luv2rgb(float l, float u, float v)
{
    float b = l - u;
    float r = v + l;
    float g = (l - r * xyz_rec2020[1][0] - b * xyz_rec2020[1][2]) / xyz_rec2020[1][1];
    float res[3] = { r, g, b };
    return res;
}    


float[3] hsl2rgb(float hsl[3])
{
    float u = hsl[1] * sin(hsl[0]);
    float v = hsl[1] * cos(hsl[0]);
    float l = hsl[2];
    return luv2rgb(l, u, v);
}


float[3] mkfloat3(float x, float y, float z)
{
    float res[3] = { x, y, z };
    return res;
}


float gauss(float mu, float sigma2, float x)
{
    return exp(-((x - mu)*(x - mu)) / (2 * sigma2));
}


float fmin(float a, float b)
{
    if (a < b) {
        return a;
    } else {
        return b;
    }
}


float fmax(float a, float b)
{
    if (a > b) {
        return a;
    } else {
        return b;
    }
}


float clamp(float x, float lo, float hi)
{
    return fmax(fmin(x, hi), lo);
}


float sgn(float x)
{
    if (x < 0) {
        return -1;
    } else {
        return 1;
    }
}


const float log2_val = log(2);

float log2(float x)
{
    float y = x;
    if (y < 0) {
        y = 1e-20;
    }
    return log(y) / log2_val;
}


float exp2(float x)
{
    return pow(2, x);
}


const float D50_xy[3] = { 0.34567, 0.35850, 1 - 0.34567 - 0.35850 };

float[3] rgb2xy(float rgb[3])
{
    float xyz[3] = mult_f3_f33(rgb, xyz_rec2020_t);
    float sum = xyz[0] + xyz[1] + xyz[2];
    if (sum == 0.0) {
        return D50_xy;
    }
    float x = xyz[0] / sum;
    float y = xyz[1] / sum;
    float res[3] = {x, y, 1.0 - x - y};
    return res;
}


float[3][3] matrix_from_primaries(float r_xy[3], float g_xy[3], float b_xy[3],
                                  float white[3])
{
    const float m[3][3] = {
        {r_xy[0], r_xy[1], r_xy[2]},
        {g_xy[0], g_xy[1], g_xy[2]},
        {b_xy[0], b_xy[1], b_xy[2]}
    };
    const float mi[3][3] = invert_f33(m);
    const float kr[3] = mult_f3_f33(white, mi);
    const float kr_m[3][3] = {
        {kr[0], 0, 0},
        {0, kr[1], 0},
        {0, 0, kr[2]}
    };
    float ret[3][3] = mult_f33_f33(kr_m, m);
    return ret;
}


float intp(float blend, float a, float b)
{
    return blend * a + (1 - blend) * b;
}


float ite(bool cond, float t, float e)
{
    if (cond) {
        return t;
    } else {
        return e;
    }
}


float sqr(float x)
{
    return x*x;
}


// ACES-style gamut compression
//
// tweaked from the original from https://github.com/jedypod/gamut-compress
float[3] gamut_compress(float rgb_in[3], float threshold[3],
                        float distance_limit[3],
                        float to_out[3][3], float from_out[3][3],
                        float pwr=0.0)
{
    float rgb[3] = rgb_in;
    
    // Calculate scale so compression function passes through distance limit:
    // (x=distance_limit, y=1)
    float s[3];
    for (int i = 0; i < 3; i = i+1) {
        s[i] = (1.0  - threshold[i])/sqrt(fmax(1.001, distance_limit[i])-1.0);
    }

    // convert to target colorspace
    rgb = mult_f3_f33(rgb, to_out);
  
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

    if (pwr == 0.0) {
        // Parabolic compression function:
        // https://www.desmos.com/calculator/nvhp63hmtj
        for (int i = 0; i < 3; i = i+1) {
            if (d[i] >= threshold[i]) {
                cd[i] = s[i] * sqrt(d[i] - threshold[i] + s[i]*s[i]/4.0) -
                    s[i] * sqrt(s[i] * s[i] / 4.0) + threshold[i];
            }
        }
    } else {
        for (int i = 0; i < 3; i = i+1) {
            if (d[i] < threshold[i]) {
                cd[i] = d[i];
            } else {
                float lim = distance_limit[i];
                float thr = threshold[i];
                float scl = (lim - thr) / pow(pow((1.0 - thr) / (lim - thr), -pwr) - 1.0, 1.0 / pwr);
                float nd = (d[i] - thr) / scl;
                float p = pow(nd, pwr);
                cd[i] = thr + scl * nd / (pow(1.0 + p, 1.0 / pwr));
            }
        }
    }

    // Inverse RGB Ratios to RGB
    for (int i = 0; i < 3; i = i+1) {
        rgb[i] = ac - cd[i] * fabs(ac);
    }

    // back to working colorspace
    rgb = mult_f3_f33(rgb, from_out);

    return rgb;
}


const float pq_m1 = 2610.0 / 16384.0;
const float pq_m2 = 2523.0 / 32.0;
const float pq_c1 = 107.0 / 128.0;
const float pq_c2 = 2413.0 / 128.0;
const float pq_c3 = 2392.0 / 128.0;

float pq_curve(float x, bool inv)
{
    if (!inv) {
        float y = fmax(x / 100.0, 0.0);
        float a = pow(y, pq_m1);
        return pow((pq_c1 + pq_c2 * a) / (1.0 + pq_c3 * a), pq_m2);
    } else {
        float p = pow(x, 1.0/pq_m2);
        float v = fmax(p - pq_c1, 0.0) / (pq_c2 - pq_c3 * p);
        return pow(v, 1.0 / pq_m1) * 100.0;
    }
}


float lin2log(float x, float base)
{
    return log(x * (base - 1) + 1) / log(base); 
}


float log2lin(float x, float base)
{
    return (pow(base, x) - 1) / (base - 1);
}
