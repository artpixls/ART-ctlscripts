// @ART-label: "B&W mixer"

// @ART-param: ["rr", "Red", -2.5, 2.5, 0.33, 0.01]
// @ART-param: ["gg", "Green", -2.5, 2.5, 0.33, 0.01]
// @ART-param: ["bb", "Blue", -2.5, 2.5, 0.33, 0.01]

void ART_main(varying float r, varying float g, varying float b,
              output varying float rout,
              output varying float gout,
              output varying float bout,
              float rr, float gg, float bb)
{
    float l = r * rr + g * gg + b * bb;
    rout = l;
    gout = l;
    bout = l;
}
