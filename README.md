# MATLABで光周波数コムのデータ処理
**光岡 佑馬 (Yuma Mitsuoka)** | 東京電機大学 工学研究科 電子システム工学専攻 光応用工学研究室

Mail: 25kmh28@ms.dendai.ac.jp (学校用) / yuma.0706.1510111@outlook.jp (個人用)

## 目次
1. [内容](#内容)
2. [卒業研究内容](#卒業研究内容)
3. [プログラムに必要なもの](#プログラムに必要なもの)


## 内容
MathWorks社が提供するMATLABを用いて, データ処理からグラフ表示までを一括して行うプログラムを生成します.
<br>
本ページでは, 私が修士課程で行った研究内容とともに, 基本知識について解説します.

### 卒業研究内容
[Bachelor's Research.pdf](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/Bachelor's%20Research.pdf)というファイル名で保存しているので, 詳細はそちらを参照してください.

学士論文は[こちら](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/2024%20Bachelor's%20thesis_Yuma%20Mitsuoka.pdf)

## プログラムに必要なもの
### 1. MATLAB
MATLABをインストールしてください.

  - Campus-Wide License を導入している大学では, **大学のメールアドレス**で MATLAB を入手できます.

    詳細は[こちら](https://jp.mathworks.com/academia/tah-support-program/eligibility.html) / 東京電機大学の学生は[こちら](https://www.mrcl.dendai.ac.jp/mrcl/it-service/software/matlab/)

### 2. 使用する MATLAB Toolbox
下記の Toolbox のインストールが必要です.

  - Signal Processing Toolbox
  - Curve Fitting Toolbox

MATLAB インストール時にまとめて追加できます. インストール済みの場合は「ホーム > アドオン」から検索し、インストールしてください.

### 3. HITRAN
HITRAN とは, 分子がどの波長(周波数)の光を, どれくらい吸収するかをまとめた分子分光データベースです. <br>
HITRAN on the Web のリンクは[こちら](https://hitran.iao.ru/)

※ データを作成するためには, まず**アカウントを作成する**必要があります. 右上の鍵マークからアカウントを作成してください.
    <img width="1676" height="328" alt="image" src="https://github.com/user-attachments/assets/3af9d48b-fd7a-4307-abf7-c1d7db4a7e4b" />

### 3.1. 濃度 100 % のガスの透過率スペクトルの取得方法について
アカウント作成後, 「Gas mixture > Mixtures of isotopologues」から混合したいガスを選択します. <br>
例として, 研究室で扱っている Wavelength References社 のシアン化水素ガス (HCN-13-H(5.5)-25-FCAPC) の透過率スペクトルを取得してみます. <br>
データシートは[こちら](https://www.wavelengthreferences.com/wp-content/uploads/Data-HCN.pdf)


## 研究内容と基本知識について
### 1. 光周波数コム(光コム)とは
周波数軸上に等間隔に並ぶ成分(モード)からなる櫛形のスペクトルを持った光信号です.
光コムの"**コム**"は
