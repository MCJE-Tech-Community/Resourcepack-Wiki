#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
in vec2 t;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    
    float r = vertexDistance /10;
    
    if (r < 1 && t.x != 0) {
        color = texture(Sampler0, texCoord0) * (vec4(1-r) +vertexColor *(r +0.2) /1.2) * ColorModulator; 
        float noise = fract(sin(dot(t.xy ,vec2(12.9898,78.233))) * 43758.5453);
        if (noise > (r+0.4)) {
            discard;
        }
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}