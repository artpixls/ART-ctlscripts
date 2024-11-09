// GHT filter ported from Siril.
// 
// see https://siril.org/tutorials/ghs/ for more info
// 
// Copyright of the original code follows
/*
 * Copyright (C) 2005-2011 Francois Meyer (dulle at free.fr)
 * Copyright (C) 2012-2023 team free-astro (see more in AUTHORS file)
 * Reference site is https://free-astro.org/index.php/Siril
 *
 * Siril is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Siril is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Siril. If not, see <http://www.gnu.org/licenses/>.
 */

import "_artlib";

// @ART-colorspace: "rec2020"
// @ART-label: "$CTL_GENERALISED_HYPERBOLIC_STRETCH;Generalised hyperbolic stretch"

// @ART-param: ["mode", "$CTL_MODE;Mode", ["RGB", "$CTL_LUMINANCE;Luminance", "$CTL_SATURATION;Saturation"], 0]
// @ART-param: ["D", "$CTL_STRETCH_FACTOR;Stretch factor (D)", 0, 10, 0, 0.001]
// @ART-param: ["B", "$CTL_LOCAL_STRETCH_INTENSITY;Local stretch intensity (b)", -5, 15, 0, 0.001]
// @ART-param: ["SP", "$CTL_SYMMETRY_POINT;Symmetry point (SP)", 0, 1, 0, 0.00001]
// @ART-param: ["LP", "$CTL_SHADOW_PROTECTION_POINT;Shadow protection point (LP)", 0, 1, 0, 0.00001]
// @ART-param: ["HP", "$CTL_HIGHLIGHT_PROTECTION_POINT;Highlight protection point (HP)", 0, 1, 1, 0.00001]

struct ght_compute_params {
    float qlp;
    float q0;
    float qwp;
    float q1;
    float q;
    float b1;
    float a1;
    float a2;
    float b2;
    float c2;
    float d2;
    float e2;
    float a3;
    float b3;
    float c3;
    float d3;
    float e3;
    float a4;
    float b4;
    float LPT;
    float SPT;
    float HPT;
};


ght_compute_params GHT_setup(float in_B, float D, float LP, float SP, float HP)
{
    ght_compute_params c;
    float B = in_B;
    if (B == -1.0) {
        //B = -B;
        c.qlp = -1.0*log(1 + D*(SP - LP));
        c.q0 = c.qlp - D * LP / (1.0 + D * (SP - LP));
        c.qwp = log(1 + D * (HP - SP));
        c.q1 = c.qwp + D * (1.0 - HP) / (1.0 + D * (HP - SP));
        c.q = 1.0 / (c.q1 - c.q0);
        c.b1 = (1.0 + D * (SP - LP)) / (D * c.q);
        c.a2 = (-c.q0) * c.q;
        c.b2 = -c.q;
        c.c2 = 1.0 + D * SP;
        c.d2 = -D;
        c.a3 = (-c.q0) * c.q;
        c.b3 = c.q;
        c.c3 = 1.0 - D * SP;
        c.d3 = D;
        c.a4 = (c.qwp - c.q0 - D * HP / (1.0 + D * (HP - SP))) * c.q;
        c.b4 = c.q * D / (1.0 + D * (HP - SP));
    } else if (B < 0.0) {
        B = -B;
        c.qlp = (1.0 - pow((1.0 + D * B * (SP - LP)), (B - 1.0) / B)) / (B - 1.0);
        c.q0 = c.qlp - D * LP * (pow((1.0 + D * B * (SP - LP)), -1.0 / B));
        c.qwp = (pow((1.0 + D * B * (HP - SP)), (B - 1.0) / B) - 1.0) / (B - 1.0);
        c.q1 = c.qwp + D * (1.0 - HP) * (pow((1.0 + D * B * (HP - SP)), -1.0 / B));
        c.q = 1.0 / (c.q1 - c.q0);
        c.b1 = D * pow(1.0 + D * B * (SP - LP), -1.0 / B) *c.q;
        c.a2 = (1.0/(B-1.0)-c.q0) * c.q;
        c.b2 = -c.q/(B-1.0);
        c.c2 = 1.0 + D * B * SP;
        c.d2 = -D * B;
        c.e2 = (B - 1.0)/B;
        c.a3 = (-1.0/(B-1.0) - c.q0) *c.q;
        c.b3 = c.q/(B-1.0);
        c.c3 = 1.0 - D * B * SP;
        c.d3 = D * B;
        c.e3 = (B - 1.0) / B;
        c.a4 = (c.qwp - c.q0 - D * HP * pow((1.0 + D * B * (HP - SP)), -1.0 / B)) * c.q;
        c.b4 = D * pow((1.0 + D * B * (HP - SP)), -1.0 / B) * c.q;
    } else if (B == 0.0) {
        c.qlp = exp(-D * (SP - LP));
        c.q0 = c.qlp - D * LP * exp(-D*(SP - LP));
        c.qwp = 2.0 - exp(-D * (HP -SP));
        c.q1 = c.qwp + D * (1.0 - HP) * exp (-D * (HP - SP));
        c.q = 1.0 / (c.q1 - c.q0);
        c.a1 = 0.0;
        c.b1 = D * exp (-D * (SP - LP)) * c.q;
        c.a2 = -c.q0 * c.q;
        c.b2 = c.q;
        c.c2 = -D * SP;
        c.d2 = D;
        c.a3 = (2.0 - c.q0) * c.q;
        c.b3 = -c.q;
        c.c3 = D * SP;
        c.d3 = -D;
        c.a4 = (c.qwp - c.q0 - D * HP * exp(-D * (HP - SP))) * c.q;
        c.b4 = D * exp(-D * (HP - SP)) * c.q;
    } else if (B > 0.0) {
        c.qlp = pow((1.0 + D * B * (SP - LP)), -1.0/B);
        c.q0 = c.qlp - D * LP * pow((1 + D * B * (SP - LP)), -(1.0 + B) / B);
        c.qwp = 2.0 - pow(1.0 + D * B * (HP - SP), -1.0 / B);
        c.q1 = c.qwp + D * (1.0 - HP) * pow((1.0 + D * B * (HP - SP)), -(1.0 + B) / B);
        c.q = 1.0 / (c.q1 - c.q0);
        c.b1 = D * pow((1.0 + D * B * (SP - LP)), -(1.0+B)/B) * c.q;
        c.a2 = -c.q0 * c.q;
        c.b2 = c.q;
        c.c2 = 1.0 + D * B * SP;
        c.d2 = -D * B;
        c.e2 = -1.0 / B;
        c.a3 = (2.0 - c.q0) * c.q;
        c.b3 = -c.q;
        c.c3 = 1.0 - D * B * SP;
        c.d3 = D * B;
        c.e3 = -1.0 / B;
        c.a4 = (c.qwp - c.q0 - D * HP * pow((1.0 + D * B * (HP - SP)), -(B + 1.0) / B)) * c.q;
        c.b4 = (D * pow((1.0 + D * B * (HP - SP)), -(B + 1.0) / B)) * c.q;
    }

    return c;
}


float GHT(float x, float B, float D, float LP, float SP, float HP, ght_compute_params c)
{
    const float BP = 0.0;
    float out;
    /* float in = x; */
    /* in = fmax(0.0, (in - BP)/(1.0 - BP)); */
    float in = clamp(x, 0, 1);
    if (D == 0.0) {
        out = in;
    } else {
        if (B == -1.0) {
            if (in < LP) {
                out = c.b1 * in;
            } else if (in < SP) {
                out = c.a2 + c.b2 * log(c.c2 + c.d2 * in);
            } else if (in < HP) {
                out = c.a3 + c.b3 * log(c.c3 + c.d3 * in);
            } else {
                out = c.a4 + c.b4 * in;
            }
        } else if (B < 0.0) {
            if (in < LP) {
                out = c.b1 * in;
            } else if (in < SP) {
                out = c.a2 + c.b2 * pow((c.c2 + c.d2 * in), c.e2);
            } else if (in < HP) {
                out = c.a3 + c.b3 * pow((c.c3 + c.d3 * in), c.e3);
            } else {
                out = c.a4 + c.b4 * in;
            }
        } else if (B == 0.0) {
            if (in < LP) {
                out = c.a1 + c.b1 * in;
            } else if (in < SP) {
                out = c.a2 + c.b2 * exp(c.c2 + c.d2 * in);
            } else if (in < HP) {
                out = c.a3 + c.b3 * exp(c.c3 + c.d3 * in);
            } else {
                out = c.a4 + c.b4 * in;
            }
        } else /*if (B > 0)*/ {
            if (in < LP) {
                out = c.b1 * in;
            } else if (in < SP) {
                out = c.a2 + c.b2 * pow((c.c2 + c.d2 * in), c.e2);
            } else if (in < HP) {
                out = c.a3 + c.b3 * pow((c.c3 + c.d3 * in), c.e3);
            } else {
                out = c.a4 + c.b4 * in;
            }
        }
    }
    return out;
}


const int MODE_RGB = 0;
const int MODE_LUMINANCE = 1;
const int MODE_SATURATION = 2;

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              int mode,
              float B, float D, float LP, float SP, float HP)
{
    const ght_compute_params c = GHT_setup(B, D, LP, SP, HP);

    float out[3];
    if (mode != MODE_RGB) {
        out = rgb2hsl(r, g, b);
        if (mode == MODE_LUMINANCE) {
            out[2] = GHT(out[2], B, D, LP, SP, HP, c);
        } else {
            out[1] = GHT(out[1], B, D, LP, SP, HP, c);
        }
        out = hsl2rgb(out);
    } else {
        out = mkfloat3(r, g, b);
        for (int i = 0; i < 3; i = i+1) {
            out[i] = GHT(out[i], B, D, LP, SP, HP, c);
        }
    }
    rout = out[0];
    gout = out[1];
    bout = out[2];
}
