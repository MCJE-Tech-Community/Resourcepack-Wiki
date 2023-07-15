
int color(vec3 Color) {
    return (int(Color.r *255) <<16) +(int(Color.g *255) <<8) + int(Color.b *255);
}

int check_trigger(sampler2D Sampler2, float FogStart) {
    int value = 0;
    if (color(texture(Sampler2, vec2(0, 0.0042)).rgb) > 13421772 ) { value += 3;}
    if (FogStart == 1) {value += 1;}
    if (FogStart == 5) {value += 2;}
    return value;
}