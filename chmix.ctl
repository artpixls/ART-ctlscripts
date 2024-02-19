// @ART-label: "Channel mixer"

// @ART-param: ["rr", "Red", -2.5, 2.5, 1, 0.01, "Red"]
// @ART-param: ["rg", "Green", -2.5, 2.5, 0, 0.01, "Red"]
// @ART-param: ["rb", "Blue", -2.5, 2.5, 0, 0.01, "Red"]
// @ART-param: ["gr", "Red", -2.5, 2.5, 0, 0.01, "Green"]
// @ART-param: ["gg", "Green", -2.5, 2.5, 1, 0.01, "Green"]
// @ART-param: ["gb", "Blue", -2.5, 2.5, 0, 0.01, "Green"]
// @ART-param: ["br", "Red", -2.5, 2.5, 0, 0.01, "Blue"]
// @ART-param: ["bg", "Green", -2.5, 2.5, 0, 0.01, "Blue"]
// @ART-param: ["bb", "Blue", -2.5, 2.5, 1, 0.01, "Blue"]

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
