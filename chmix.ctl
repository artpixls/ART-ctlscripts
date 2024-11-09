// @ART-label: "$CTL_CHANNEL_MIXER;Channel mixer"

// @ART-param: ["rr", "$CTL_RED;Red", -2.5, 2.5, 1, 0.01, "$CTL_RED;Red"]
// @ART-param: ["rg", "$CTL_GREEN;Green", -2.5, 2.5, 0, 0.01, "$CTL_RED;Red"]
// @ART-param: ["rb", "$CTL_BLUE;Blue", -2.5, 2.5, 0, 0.01, "$CTL_RED;Red"]
// @ART-param: ["gr", "$CTL_RED;Red", -2.5, 2.5, 0, 0.01, "$CTL_GREEN;Green"]
// @ART-param: ["gg", "$CTL_GREEN;Green", -2.5, 2.5, 1, 0.01, "$CTL_GREEN;Green"]
// @ART-param: ["gb", "$CTL_BLUE;Blue", -2.5, 2.5, 0, 0.01, "$CTL_GREEN;Green"]
// @ART-param: ["br", "$CTL_RED;Red", -2.5, 2.5, 0, 0.01, "$CTL_BLUE;Blue"]
// @ART-param: ["bg", "$CTL_GREEN;Green", -2.5, 2.5, 0, 0.01, "$CTL_BLUE;Blue"]
// @ART-param: ["bb", "$CTL_BLUE;Blue", -2.5, 2.5, 1, 0.01, "$CTL_BLUE;Blue"]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float rr, float rg, float rb,
              float gr, float gg, float gb,
              float br, float bg, float bb)
{
    rout = r * rr + g * rg + b * rb;
    gout = r * gr + g * gg + b * gb;
    bout = r * br + g * bg + b * bb;
}
