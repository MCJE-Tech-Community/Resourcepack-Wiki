<!-- omit in toc -->
# Minecraft JE Resourcepack Wiki
Minecraftのテクスチャ、カスタムモデル、カスタムシェーダーについてのネタを集めたwikiです。

<!-- omit in toc -->
# 解説Wiki
### [技術解説wiki](https://github.com/MCJE-Tech-Shares/Resourcepack-Wiki/wiki)
github wikiに、ここで掲載している物も含めいろいろと技術的な解説を載せています。(予定)  

<!-- omit in toc -->
# 配布物
- [シェーダー](#シェーダー)
  - [スキンオーバーレイ](#スキンオーバーレイ)
  - [ブロック透視コアシェーダー](#ブロック透視コアシェーダー)


# シェーダー
　シェーダーを使った小ネタ

## スキンオーバーレイ

<img src="https://github.com/MCJE-Tech-Shares/Resourcepack-Wiki/blob/main/04_Shader/skin_overlay/skin_overlay.gif" height="250px"></img>  
▲動作の様子  

### 説明
　特定の色を付けた皮防具に特定のスキンを反映させ、着せた対象のスキンをオーバーレイさせられるシェーダー。コアシェーダーでアーマーのモデルを縮めることで体にぴったりとくっつけている。

### 使い方
　[`skin_overlay`](https://github.com/MCJE-Tech-Shares/Resourcepack-Wiki/tree/main/04_Shader/skin_overlay)下にある`shaders`と`textures`を`data/`下に入れ、リソースパックをリロード。下記のようなコマンドで色付きの皮防具を取得。
```
/give @s leather_helmet{display:{color:1}}
```

`color`の部分を1~10と変えると、`textures/leather_layer_1.png`に追加されているスキンが上から順番に表示される。スキンを変更したい場合は、`textures/leather_layer_1.png`の対象スキンを変更すればよい。

(2023/07/26)

## ブロック透視コアシェーダー

<img src="https://github.com/MCJE-Tech-Shares/Resourcepack-Wiki/blob/main/04_Shader/seeing_through/seeing_through.gif" height="250px"></img>  
▲動作の様子  

### 説明
　暗視エフェクトを付けると周囲のブロックが透け、向こう側が見えるようになるコアシェーダー。

### 使い方
　[`seeing_through`](https://github.com/MCJE-Tech-Shares/Resourcepack-Wiki/tree/main/04_Shader/seeing_through)下にある`core`と`include`を`data/`下に入れ、リソースパックをリロード。暗視エフェクトを付けると透視が発動する。

(2023/07/26)
