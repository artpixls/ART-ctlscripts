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

const float xyz_rec2020_t[3][3] = transpose_f33(xyz_rec2020);


float luminance(float r, float g, float b)
{
    return r * xyz_rec2020[1][0] + g * xyz_rec2020[1][1] + b * xyz_rec2020[1][2];
}


float[3] rgb2hsl(float r, float g, float b)
{
    float l = luminance(r, g, b);
    float u = l - b;
    float v = r - l;
    float h = atan2(u, v);
    float s = hypot(u, v);
    float res[3] = { h, s, l };
    return res;
}


float[3] hsl2rgb(float hsl[3])
{
    float u = hsl[1] * sin(hsl[0]);
    float v = hsl[1] * cos(hsl[0]);
    float l = hsl[2];
    float b = l - u;
    float r = v + l;
    float g = (l - r * xyz_rec2020[1][0] - b * xyz_rec2020[1][2]) / xyz_rec2020[1][1];
    float res[3] = { r, g, b };
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


const float log2_val = log(2);

float log2(float x)
{
    float y = x;
    if (y < 0) {
        y = 0;
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
