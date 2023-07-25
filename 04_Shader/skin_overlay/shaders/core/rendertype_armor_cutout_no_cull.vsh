#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat3 IViewRotMat;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 vertexShadow;
out vec2 texCoord0;
out vec2 texCoord1;
out vec4 normal;
out vec2 uv0;
out vec2 t;

int rgb2Int(vec4 color) {
    return (int(color.r *255) <<16) +(int(color.g *255) <<8) + int(color.b *255);
}

void main() {
    // default
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    // Additional output
    vertexShadow = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1)) * texelFetch(Sampler2, UV2 / 16, 0);
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
        int faceID = gl_VertexID / 4;
        vec2 d = ivec2((((gl_VertexID -1) %4) /2 *2 -1), ((gl_VertexID %4) /2 *2 -1)); // Direction for expand.
        
        uv0 = UV0 *vec2(64, 32); // Local pixel coordinates.
        texCoord0 = uv0 /size;

        // When colorID is in range.
        if (colorID >0 && colorID <20) {
            // Send vertexColor excluding tintindex color.
            vertexColor = vertexShadow;

            // Get some parameters.
            if ((uv0.x >= 40 && faceID >= 12 && faceID < 18) || (uv0.x <= 16 && faceID >= 6 && faceID < 12)) { d.y *= -1; } // Where uv fliped.
            if ((faceID % 6) == 1) { d.y *= -1; } // Also where uv fliped (bottom of cube).
            vec2 _uv0 = uv0 - 0.5 *d; // px center pos.
            vec2 area = vec2(4.0, 12.0); // XY size of face.
                if (_uv0.y >= 0 && _uv0.y < 16) { // Head.
                    area = vec2(8.0, 8.0);
                }
                else if (_uv0.y >= 16 && _uv0.y < 64) { // Body and Legs.
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