#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec2 uv0;
in vec2 t;

out vec4 fragColor;

void main() {
    // default
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

    // Reproduce overlay of leather armor.
    if ((uv0.x >= 11 && uv0.x < 13 && uv0.y >= 0 && uv0.y < 11) || (uv0.x >= 27 && uv0.x < 29 && uv0.y >= 8 && uv0.y < 15) || (uv0.x >= 8 && uv0.x < 12 && uv0.y >= 16 && uv0.y < 20)) {
        #ifndef EMISSIVE
            color *= lightMapColor;
        #endif
    }
    // Cutout extra pixels.
    if (t.x < -1 || t.x > 1 || t.y < -1 || t.y > 1) {
        discard;
    }

    // default
    color *= vertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
