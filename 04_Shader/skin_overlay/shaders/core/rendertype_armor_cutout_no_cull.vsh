#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor1;
out vec4 vertexColor2;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec2 uv0;
out vec2 t;

int rgb2Int(vec4 color) {
    return (int(color.r *255) <<16) +(int(color.g *255) <<8) + int(color.b *255);
}

void main() {
    // default
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
#ifdef NO_CARDINAL_LIGHTING
    vertexColor = Color;
#else
    vertexColor1 = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    vertexColor2 = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1));
#endif
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

    // Additional output
    uv0 = vec2(0);
    t = vec2(0);

    // Check color
    vec2 size = textureSize(Sampler0, 0); // Get texture size.
    int gCorner = rgb2Int(texture(Sampler0, vec2(0,0))); // Global corner
    // When leather_layer_1
    if (gCorner == 16777215) {
        // Fix UV coordinates.
        int colorID = rgb2Int(Color);
        int skinID = colorID % 10; // Now, miximum is 10.
        int vertexID = gl_VertexID % 4;
        int faceID = gl_VertexID / 4; // 0~5:head,right_arm,left_leg, 6~11:cap,left_arm,right_leg, 12~17:body
        vec2 d = ivec2((((gl_VertexID -1) %4) /2 *2 -1), ((gl_VertexID %4) /2 *2 -1)); // Direction for expand.
        
        uv0 = UV0 *vec2(64, 32); // Local pixel coordinates.
        texCoord0 = uv0 /size;

        // When colorID is in range.
        if (colorID >0 && colorID <20) {

            vertexColor1 = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1));

            // Get some parameters.
                // Flip direction
                if ((faceID >= 6 && faceID < 8 && uv0.y >= 16)) { d.y *= -1; } // Where uv fliped (leg & arm).
                if ((faceID >= 8 && faceID < 12 && uv0.y >= 20)) { d.y *= -1; } // Where uv fliped (leg & arm).
                if ((faceID % 6) == 1) { d.y *= -1; } // Also where uv fliped (bottom of cube).
                if ((uv0.x <= 16 && uv0.y >= 20) && ((faceID >= 2 && faceID < 6) || (faceID >= 8 && faceID < 12))) { d.y *= -1;} 
                if ((uv0.x >= 4 && uv0.x <= 12 && uv0.y >= 16 && uv0.y <= 20) && ((faceID >= 0 && faceID < 2) || (faceID >= 6 && faceID < 8))) { d.y *= -1;} // All face of legs.
                // Set area
                vec2 _uv0 = uv0 - 0.5 *d; // px center pos.
                vec2 area = vec2(4.0, 12.0); // XY size of face.
                    if (_uv0.y >= 0 && _uv0.y < 16) { // Head.
                        area = vec2(8.0, 8.0);
                    }
                    else if (_uv0.y >= 16 && _uv0.y < 64) { // Body, Legs and arm.
                        if (_uv0.y < 20) { // Top and bottom face.
                            area.y = 4.0;
                            if ((_uv0.x >= 20 && _uv0.x < 36)) { area.x = 8.0;} // Body top and bottom face.
                        } else {
                            if ((_uv0.x >= 20 && _uv0.x < 28) || (_uv0.x >= 32 && _uv0.x < 40)) { area.x = 8.0;} // Body front and back face.
                        }
                    }

            // Resize constant.
            float a = 0.055;
            float b = 0.90;
            if (colorID > 10) { // For armor_stand, zombie and skeleton.
                a *= 1.1;
                b *= 1.04;
            }
            if (_uv0.x < 16 && _uv0.y >= 16) { // Boots
                a *= 0.85;
                b *= 0.83;
                if (((faceID %6 == 5) && (vertexID == 0 || vertexID == 3) )) { a -= 0.002; } // Back face of boots. (I don't know why, but it's distorted.)
            }
            if (abs(ProjMat[3][3] - 1.0) < 0.01) { // Inventory
                a *= 20;
            }

            // Shrink model
            gl_Position = ProjMat * ModelViewMat * vec4(Position - Normal*a, 1.0); // 1. Move faces in a perpendicular direction to fit the surface and the body.
            texCoord0 = (uv0 +skinID *vec2(0, 32) +d *b) /size; // 2. Expand UV coordinates to match texture.
            t = d + (d *b *2 /area); // 3. Remove the overhang with a fragment shader.
        }
    }
}