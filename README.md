# RayMarching Tutorial

## 環境設定

![](img/shadertoy.png)
Visual Studio CodeにこのExtensionをいれる。
Command Palette で `ShaderToy: Show GLSL Preview` を実行するとLive Previewが走る。

## RayMarchingのイメージ

![](img/01.jpg)

左下のカメラで右の球を撮りたい

![](img/02.jpg)
![](img/03.jpg)
カメラの中身はこんな感じ。
カメラ内のある点からイメージセンサーの各画素に向けて線を発射するイメージ。

![](img/04.jpg)
各線を延長して、シーン内のどこと交差するかをみる。

![](img/05.jpg)
交差した点の色の情報を画素に転写すると画像がレンダリングできる。
デモでは10 * 10ピクセルでやっているが、どんどんピクセルの数を上げていくと高精細な画像になっていく。