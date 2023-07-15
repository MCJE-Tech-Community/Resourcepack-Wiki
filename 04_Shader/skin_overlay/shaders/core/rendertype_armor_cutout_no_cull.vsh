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
out vec2 texCoord0;
out vec2 texCoord1;
out vec4 normal;
out vec2 t;

void main() {
    
    // テクスチャのサイズ取得
    vec2 size = textureSize(Sampler0, 0);

    // デフォルト
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0 / (size / vec2(64, 32));
    texCoord1 = UV1;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    t = vec2(1);

    // スキン範囲のとき
    int colorID = (int(Color.r *255) <<16) +(int(Color.g *255) <<8) + int(Color.b *255);
    if (colorID >0 && colorID <20) {
        // アーマーカラーを消す
        vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1)) * texelFetch(Sampler2, UV2 / 16, 0);

        // id/uv情報
        int skinID = colorID % 10;
        int vertex = gl_VertexID % 4;
        int face = gl_VertexID / 4;
        vec2 uv = UV0 *vec2(64, 32) +skinID *vec2(64, 32);
        vec2 delta = ivec2((((gl_VertexID -1) %4) /2 *2 -1), ((gl_VertexID %4) /2 *2 -1)); // 拡大方向を計算
            if ((UV0.x >= 0.625 && face >= 12 && face < 18) || (UV0.x <= 0.25 && face >= 6 && face < 12)) { delta.y *= -1; } // テクスチャを反転させているところ 左腕と左足
            if ((face % 6) == 1) { delta.y *= -1; } // テクスチャが回転？しているところ 底面
        vec2 px = UV0 *vec2(64, 32) -0.5 *delta;
        vec2 area = vec2(4.0, 12.0); // 面のサイズを取得
            if (px.y >= 0 && px.y < 16) {
                area = vec2(8.0, 8.0);
            }
            else if (px.y >= 16 && px.y < 64) {
                if (px.y < 20) {
                    area.y = 4.0;
                    if ((px.x >= 20 && px.x < 36)) { area.x = 8.0;}
                } else {
                    if ((px.x >= 20 && px.x < 28) || (px.x >= 32 && px.x < 40)) { area.x = 8.0;}
                }
            }

        // パーツによって係数を変更
        float a = 0.055;
        float b = 0.90;
        if (colorID > 10) { // サイズ
            a *= 1.1;
            b *= 1.04;
        }
        if (px.x < 16 && px.y >= 16) { // ブーツ
            a *= 0.85;
            b *= 0.83;
            if (((face %6 == 5) && (vertex == 0 || vertex == 3) )) { a -= 0.002; } // なぜかブーツの一部が窪んでるので
        }
        if (abs(ProjMat[3][3] - 1.0) < 0.01) { // インベントリ内かどうか
            a *= 20;
        }

        // モデルの形状を変更させる
        gl_Position = ProjMat * ModelViewMat * vec4(Position - Normal*a, 1.0); // 垂線方向に移動させて面を体にくっつける
        texCoord0 = (uv +delta *b) /size; // テクスチャの範囲を広げ、相対的に範囲内にテクスチャが来るようにする
        t = delta + (delta *b *2 /area); // フラグメントシェーダーに情報を与える 残したい範囲が-1~1になるように計算
    }
}