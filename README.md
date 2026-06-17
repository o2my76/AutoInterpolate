# MATLABで光周波数コムのデータ処理
**光岡 佑馬 (Yuma Mitsuoka)** | 東京電機大学大学院 工学研究科 電子システム工学専攻 光応用工学研究室

Mail: 25kmh28@ms.dendai.ac.jp (学校用) / yuma.0706.1510111@outlook.jp (個人用)

## 目次
- [内容](#内容)
- [プログラムに必要なもの](#プログラムに必要なもの)
- [データ処理プログラムの解説](#データ処理プログラムの解説)
- [その他のソフトウェアについて](#その他のソフトウェアについて) <br>
   - [HITRANによる混合ガスの透過率スペクトル取得方法について](#HITRANによる混合ガスの透過率スペクトル取得方法について)
- [免責事項](#免責事項)

>[!NOTE]
>**New：[（発展）MATLAB で Bin データ 及び 波長計 txt データの同時取得](#（発展）MATLAB-で-Bin-データ-及び-波長計-txt-データの同時取得)

## 内容
MathWorks社が提供するMATLABを用いて, データ処理からグラフ表示までを一括して行うプログラムを構築します.
<br>
本ページでは, 私が修士課程で行った研究内容とともに, プログラムについて解説します.

### 卒業研究内容
[Bachelor's Research.pdf](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/Bachelor's%20Research.pdf)というファイル名で保存しているので, 詳細はそちらを参照してください.

学士論文は[こちら](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/2024%20Bachelor's%20thesis_Yuma%20Mitsuoka.pdf)

### プログラムのダウンロード
MATLABプログラムは以下からリポジトリ全体をzip形式でダウンロードしてください. <br>
[Download Zip（最新版）](https://github.com/o2my76/AutoInterpolate/archive/refs/heads/main.zip) **（最終更新日：2026年 6月 3日）**

動作環境：MATLAB R2025b 以降

## プログラムに必要なもの
### 1. MATLAB
MATLABをインストールしてください.

> [!NOTE]
> Campus-Wide License を導入している大学では, **大学のメールアドレス**で MATLAB を入手できます.
> 詳細は[こちら](https://jp.mathworks.com/academia/tah-support-program/eligibility.html) / 東京電機大学の学生は[こちら](https://www.mrcl.dendai.ac.jp/mrcl/it-service/software/matlab/)

### 2. 使用する MATLAB Toolbox
下記の Toolbox のインストールが必要です.

| アイコン | Toolbox | 使用用途 |
| --- | --- | --- |
| <img width="199" height="142" alt="image" src="https://github.com/user-attachments/assets/963ec24e-512e-4074-82f4-cc21ae08d081" /> | Signal Processing Toolbox | 信号処理用の Toolbox です. 均一 / 不均一 にサンプリングされた信号の管理・解析・前処理・特徴抽出を行うことができます. |
| <img width="203" height="143" alt="image" src="https://github.com/user-attachments/assets/f5469b4d-a800-47ed-9cd6-1c733b6cee77" /> | Curve Fitting Toolbox | 測定データに対して曲線や曲面を当てはめるための Toolbox です. 本研究では, 測定データへの関数によるフィッティングのために使用しています. |

MATLAB インストール時にまとめて追加できます. インストール済みの場合は「ホーム > アドオン」から検索し、インストールしてください.

### 3. HITRAN
HITRAN とは, 分子がどの波長(周波数)の光を, どれくらい吸収するかをまとめた分子分光データベースです.

HITRAN on the Web のリンクは[こちら](https://hitran.iao.ru/)

### 4. Visual Studio Code
Visual Studio Code (VSCode) とは, Microsoft社が提供するコードエディタです. 
<br>
さまざまなプログラミング言語に対応しており, 拡張機能を用いることで MATLAB 言語にも対応可能です. 
<br>
さらに, GitHub と連携することでソースコードのバージョン管理と共有を行うことができます. 

Visual Studio Code のダウンロードリンクは[こちら](https://code.visualstudio.com/download)

### 5. 使用する VSCode 拡張機能
VSCode には様々な拡張機能がありますが, ここでは必須の拡張機能に加え, 便利な拡張機能を紹介します.

| アイコン | 拡張機能名 | 使用用途 |
| --- | --- | --- |
| <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/9d5fefbe-694a-43a8-af04-e98ad602bb6d" /> | MATLAB | VSCode で MATLAB を実行するための必須ツールです. |
| <img width="176" height="199" alt="image" src="https://github.com/user-attachments/assets/57180c1c-e0d1-4885-9019-02d92c3d4621" /> | Japanese Language Pack for Visual Studio Code | VSCode ではデフォルトの表示言語が英語になっているため, 表示言語を日本語にすることができるツールです. |
| <img width="185" height="192" alt="image" src="https://github.com/user-attachments/assets/2c719c8c-8090-4e8f-adb8-997761cd476b" /> | GitLens | VSCode 上でソースコードのコミット履歴等を確認することができる強力ツールです. |
| <img width="168" height="168" alt="image" src="https://github.com/user-attachments/assets/e868de76-bf25-4f3f-a17a-1af42a657bd7" /> | Indent Rainbow | VSCode でコードのインデントを色分けして表示してくれるツールです. |
| <img width="154" height="156" alt="image" src="https://github.com/user-attachments/assets/0b5e7fe0-f06a-48d3-b579-4c8d7f44ebd9" /> | Identicator | 現在カーソルがあるインデント階層を縦線で強調表示してくれるツールです. |

### 6. Mathematica
Mathematica とは, Wolfram Research社が開発した技術計算システムです. 
<br>
東京電機大学の学生は, Mathematica のサイトライセンス契約を結んでいるため, **大学のメールアドレス**で Mathematica を入手できます.

詳細は[こちら](https://www.mrcl.dendai.ac.jp/mrcl/it-service/software/mathematica/)

**※現在は, 従来まで Mathematica で行っていたデータ処理を, MATLAB 内に実装しているため, インストールする必要はありません.**

## データ処理プログラムの解説
主な処理内容は以下のとおりです.

| No. | 処理項目 | 処理内容 | 使用する関数 |
| --- | --- | --- | --- |
| 1 | 波長計 txt データの読み込み | 取得データから光中心波長・光周波数シフト量の推定値を測定します. | `readtable`, `findpeaks` |
| 2 | HITRAN txt データの読み込み | 吸収線データベース（HITRAN）を読み込みます. | `readtable` |
| 3 | Bin ファイルの読み込み | Alazar で取得した時間波形（インターフェログラム）を読み込みます. | `fopen`, `fread`, `fclose` |
| 4 | フーリエ変換・RF 周波数軸の生成 | 時間波形から周波数スペクトルに変換し, サンプル数とサンプリングレートからRF周波数軸を生成します. | `fft` |
| 5 | RF 吸収スペクトルの取得 | RF 透過スペクトルをRF参照スペクトルで除算することでRF吸収スペクトルを取得します. |
| 6 | RF スムージング処理（移動平均処理） | RF 吸収スペクトルに含まれる細かなノイズを低減することで, 吸収線を見やすくします. | `movmean` |
| 7 | RF 吸収ピーク位置の抽出 | RF 吸収ピーク位置を抽出し, 後の光周波数シフト量の計測に使用します. | `findpeaks` |
| 8 | 光周波数シフト量の計測 | 隣接する RF 吸収ピーク位置からピーク間隔を計測し, 光周波数シフト量の計測を行います. | 
| 9 | RF 領域から光領域への換算 | 計測した光周波数シフト量を用いて RF 領域から光領域への換算処理を行います. | `cellfun`, `vertcat` |
| 10 | 光吸収スペクトルの取得 | 透過光スペクトルを参照光スペクトルで除算することで光吸収スペクトルを取得します. |
| 11 | 光スムージング処理（移動平均処理） | 光吸収スペクトルに含まれる細かなノイズを低減することで, 吸収線を見やすくします. | `movmean` |
| 12 | 光吸収スペクトルのベースライン補正 | 2×2カプラ の特性に起因して生じるベースラインの傾きを補正します. | `fitoptions`, `fit`, `feval`, `coeffvalues` |
| 13 | 光吸収ピーク位置の抽出 | 光吸収ピーク位置を抽出し, HITRAN の吸収ピーク位置との残差を測定に使用します. | `findpeaks` |
| 14 | ピーク位置残差の標準偏差の測定・評価 | 取得データと HITRAN とのピーク位置の残差を測定し, 標準偏差を算出します. | `findpeaks` |

### 入力データ
本プログラムでは, 以下のデータを入力として使用します.

| データ | 使用用途 |
| --- | --- |
| 波長計 txt データ | 光中心周波数と光周波数シフト量の推定に使用します. |
| HITRAN txt データ | 測定した光吸収スペクトルとの比較・評価に使用します. |
| Alazar Bin データ | データ処理の元データとして使用します. |

### 出力結果
本プログラムを実行することで, 以下の結果を出力します.

| Figure No. | 出力内容 | 説明 |
| --- | --- | --- |
| 1 | 光中心周波数の変動波形 | 測定したタイミングから 1 s の範囲で波長計で取得した時間波形 |
| 2, 3 | インターフェログラム | No.2：RF 参照側, No.3：RF 透過側 のインターフェログラム |
| 4, 5 | RF コムスペクトル | No.4：スムージング前, No.5：スムージング後 の RF コム |
| 6, 7 | RF 吸収スペクトル | No.6：マスク前, No.7：マスク後 の RF 吸収スペクトル |
| 8 ~ 11 | 切り取り前の EO コムスペクトル（スムージング前 / 後）| No.8, 9：推定値, No.10, 11：提案手法 によって計測した光周波数シフト量を用いて光領域へ換算した EO コムスペクトル |
| 12,13, 15,16 | 切り取り後の EO コムスペクトル（スムージング前 / 後）| No.12, 13：推定値, No.15, 16：提案手法 によって取得した EO コムスペクトルの切り取り後の結果 |
| 14, 17 | 光吸収スペクトル & HITRAN | No.14：推定値, No.17：提案手法 によって取得した光吸収スペクトルと HITRAN の重ね合わせた結果 |
| 18, 19 | ピークフィットに伴うベースライン補正用マスク範囲の指定 | No.18：推定値, No.19：提案手法 において吸収線ピーク周辺部分の影響を受けずにベースライン補正を行うためのマスク範囲を破線で表示 |
| 20, 21 | ベースライン補正用の近似曲線 | No.20：推定値, No.21：提案手法 においてベースライン補正用の近似曲線の出力結果 |
| 22, 23 | ベースライン補正後の光吸収スペクトル & HITRAN | No.22：推定値, No.23：提案手法 においてベースライン補正後の光吸収スペクトル |

### 使用方法

1. Alazar で取得した Bin データを保存します.
   この時, ファイル名は`1`として保存します
2. 保存後に生成される以下の2つの Bin データを新規フォルダにまとめます.
   ```text
   1_1.1.1.1.A.bin
   1_1.1.1.1.B.bin
   ```
   フォルダ名の例：`my00`
3. Alazar でデータを取得した時刻を記録し，同時に波長計の lta データを保存します. <br>
   この時，lta データのファイル名は，**Bin データを保存したフォルダ名と同じ**にします.
4. `lta_txt変換プログラム.nb`を用いて, 波長計で取得した lta データを txt データに変換します.
5. MATLABプログラム内で, 実行するフォルダ名と波長計データの取得時刻を入力します.
6. 実験条件に合わせてそのほかの変数を変更し, プログラムを実行します.


## その他のソフトウェアについて
### HITRANによる混合ガスの透過率スペクトル取得方法について
> [!NOTE]
> データを作成するためには, まず**アカウントを作成する**必要があります. 右上の鍵マークからアカウントを作成してください.
> <img width="1676" height="328" alt="image" src="https://github.com/user-attachments/assets/3af9d48b-fd7a-4307-abf7-c1d7db4a7e4b" /> <br>
アカウント作成後, 「Gas mixture > Mixtures of isotopologues」から混合したいガスを選択します.

例として, 研究室で扱っている シアン化水素ガス (HCN-13-H(5.5)-25-FCAPC) の透過率スペクトルを取得してみます. <br>
データシートは[こちら](https://www.wavelengthreferences.com/wp-content/uploads/Data-HCN.pdf) (Wavelength References 社) 

まず, 左側から混合したいガスを選択し, 「Origin of the mixture」のプルダウンから「User-difined」を選択します.
<img width="1852" height="344" alt="image" src="https://github.com/user-attachments/assets/616c7ee0-0015-4a0b-9f4d-2f26fbcb01d6" />
<br>
選択すると, 最初は下のように「No results found.」と表記されるので, 右上の「Create mixture」から混合ガスを生成します.
<img width="1924" height="320" alt="image" src="https://github.com/user-attachments/assets/ad3ff722-ae78-4954-94f2-102084b608e1" />
<br>
その後, 「Title」を入力し, 「Mixing ratio」の「+」アイコンから同位体を選択します.
<img width="1620" height="920" alt="image" src="https://github.com/user-attachments/assets/e2950a42-0dd2-4f0d-8617-88a6b43921fa" />
<br>
今回は「2 : H13C14N (134)」を選択します.
<img width="1932" height="480" alt="image" src="https://github.com/user-attachments/assets/6bdde8e2-c52d-4abb-96c0-78e12dd78689" />
<br>
選択後, 「Volume share」からガス濃度を入力し, 保存アイコンを選択して値を保存します. (1 → 100%)
<img width="1944" height="364" alt="image" src="https://github.com/user-attachments/assets/8d6ea561-fb9b-400b-b038-835b83022a51" />
<br>
最後に, 「Save」を選択して保存完了です. (別の同位体を選択する場合は同じ作業を繰り返してください.)
<img width="1828" height="992" alt="image" src="https://github.com/user-attachments/assets/844bd6a6-d685-4df1-8652-5f331ea20dcb" />

ここまででは, 混合ガスの比率を設定しただけなので, まだシアン化水素ガスとしての保存ができていません. <br>
次に, 「Gas mixtures > Gas mixtures」から先ほど生成した混合ガスをシアン化水素ガスとして保存します.

まず, 先ほどと同様に「Origin of the mixture > User-defined」から右上の「Create mixture」を選択します.
<img width="2424" height="292" alt="image" src="https://github.com/user-attachments/assets/209794af-ca87-41e2-bb85-991b41f04074" />
<br>
選択後, 「Mixing ratio」の「+」アイコンを選択し, 「Molecule」を決定します. (今回は「23 : Hydrogen cyanide (HCN)」を選択します.)
<img width="1412" height="360" alt="image" src="https://github.com/user-attachments/assets/7685c3ba-6687-403b-95c7-12e3788470da" />
<br>
その後, 「Mixture of isotopologues」のプルダウンから先ほど保存した混合ガスを選択します.
<img width="2224" height="492" alt="image" src="https://github.com/user-attachments/assets/623808b0-a0ec-4c72-85a9-513af13967b1" />
選択後, 「Volume share」からガス濃度を入力 → 保存アイコンを選択して値を保存し, 「Title」を入力後, 「Save」を選択して保存完了です.
<img width="2132" height="404" alt="image" src="https://github.com/user-attachments/assets/c8cc510a-d551-4540-ac43-8d34c877e2b9" />

最後に, 「Gas mixtures > Launch simulation」から透過率スペクトルの取得を行います. <br>
まず, 「Gas mixture」のプルダウンから先ほど生成した混合ガスを選択します. (一番下に「U : ～ 」と表記) <br>
また, 今回取得したいのは透過率スペクトルなので, 「Simulation type」のプルダウンから「Transmittance function」を選択します.
<img width="2632" height="288" alt="image" src="https://github.com/user-attachments/assets/a4bdb794-c81d-49e6-87d6-43291246c1ce" />
<br>
その後, 波数/温度/圧力/光路長 などの各パラメータを入力して「Start simulation」より実行します. (パラメータはデータシートを参照)
<img width="3008" height="920" alt="image" src="https://github.com/user-attachments/assets/7077c7f5-d130-4c8d-8168-e80985634fcf" />
<br>
実行結果は, 「Gas mixtures > Simulation results」から確認でき, 「Plot selected」より見ることができます. <br>
また, 右側にあるダウンロードアイコンから .txt 形式で透過率スペクトルの保存ができます. <br>
<img width="2880" height="604" alt="image" src="https://github.com/user-attachments/assets/e0755e67-145b-4428-bbc1-1100178125d8" />
<img width="3320" height="1840" alt="image" src="https://github.com/user-attachments/assets/ae09650f-5c51-4721-a82f-cd99399fe8f7" />

> [!IMPORTANT]
> 保存した .txtファイルの横軸は波数なので, 光周波数に換算する場合は横軸に **29979245800** を掛けてください.

## 免責事項
本リポジトリで提供するプログラム，スクリプト，およびドキュメント類は，参考目的で公開するものです．内容や動作については可能な限り検証していますが，その正確性，完全性，安全性，動作，特定用途への適合性を保証するものではありません．

本リポジトリのプログラムやコードを使用したことによってユーザーまたは第三者に生じたいかなる損害，トラブル，データ損失，または不利益についても，作者は一切の責任を負いません．

利用する場合は，ユーザー自身の責任において動作環境や依存関係，ライセンス条件を十分確認したうえでご利用ください．

本リポジトリの内容は予告なく変更，削除されることがありますので，あらかじめご了承ください．


# （発展）MATLAB で Bin データ 及び 波長計 txt データの同時取得

## 目次
- [概要](#概要)
- [動作環境](#動作環境)
- [測定条件](#測定条件)
- [ファイル構成](#ファイル構成)
  - [ATS9360 関連](#ats9360-関連)
  - [WS-7 関連](#ws-7-関連)
- [ATS9360関連ファイルの役割](#ats9360関連ファイルの役割)
  - [メインプログラム](#メインプログラム)
  - [ライブラリ関連](#ライブラリ関連)
  - [ボード認識関連](#ボード認識関連)
  - [クロック設定関連](#クロック設定関連)
  - [入力設定関連](#入力設定関連)
  - [トリガ設定関連](#トリガ設定関連)
  - [レコード設定関連](#レコード設定関連)
  - [AutoDMA関連](#autodma関連)
  - [通常取得および状態確認関連](#通常取得および状態確認関連)
  - [パラメータおよび機能確認関連](#パラメータおよび機能確認関連)
  - [補助関数](#補助関数)
  - [特殊機能関連](#特殊機能関連)
  - [DSPおよびFFT関連](#dspおよびfft関連)
- [WS-7関連ファイルの役割](#ws-7関連ファイルの役割)
  - [本測定用プログラム](#本測定用プログラム-1)
  - [MATLABサンプルコード](#matlabサンプルコード)
  - [MEX関連](#mex関連)
  - [ライブラリおよびAPI定義](#ライブラリおよびapi定義)
  - [主要API関数](#主要api関数)
  - [本測定における使用状況](#本測定における使用状況)
- [著作権及びライセンス](#著作権及びライセンス)

## 概要
本プログラムは, ATS-SDK を用いた AlazarTech PCI Digitizer ATS9360 による時間波形の取得と, HighFinesse WS-7 を用いた波長記録を MATLAB 上で並行して実行するためのものです.

ATS9360では, 外部トリガを用いて Channel A 及び Channel B の時間波形を取得します. <br>
また, ATS-SDK の AutoDMA 機能を利用することで, 取得データを PCI Express 経由で PCメモリ へ高速転送します.

WS-7では, HighFinesse 社 が提供する`wlmData` APIを利用し, 新しい波長測定イベントが発生するたびに波長を記録します.

測定終了後, ATS9360 の各チャンネルデータを Bin形式 で保存し, WS-7 の経過時間および波長データを txt形式 で保存します.

>[!IMPORTANT]
>本プログラムには, AlazarTech ATS-SDK に含まれるサンプルコード, ラッパー関数, ライブラリ関連ファイルを使用しているため, 著作権及びライセンス上の理由から, プログラム本体は公開していません.
>
>ATS-SDK 及び関連ファイルについては, AlazarTech の公式サイトから利用条件を確認したうえで取得してください.

## 動作環境
- MATLAB R2026a 以降
- [AlazarTech ATS-SDK](https://github.com/user-attachments/files/29046647/ATS-SDK-Guide.pdf)
- [AlazarTech ATS9360](https://github.com/user-attachments/files/29046689/ATS9360.User.Manual_V1_0_Complete.pdf)
- Windows 64-bit
- ATSApi.dll
- ATSApi_thunk_pcwin64.dll
- HighFinesse WS-7
- [HighFinesse Wavelength Meter software](https://www.highfinesse.com/en/howto/tutorial/Control_Wavemeter_Own_Application_EN.pdf)

## 測定条件
本プログラムでは, 以下の条件でデータを取得します.

| 項目 | 設定 |
| --- | --- |
| デジタイザ | ATS9360 |
| サンプリングレート | 200 MS/s |
| サンプル数 | `2^25` |
| 入力チャンネル | Channel A, Channel B |
| カプリング | DC |
| 入力レンジ | ±400 mV |
| 入力インピーダンス | 50 Ω |
| トリガソース | External Trigger |
| 入力トリガ | TTL level |
| トリガスロープ | Positive |
| データ取得モード | NPT AutoDMA |
| 1転送あたりのレコード数 | 1 |
| 転送回数 | 1 |
| ATS9360 出力 | Two Bin files |
| WS-7 出力 | Tab-delimited txt |

## ファイル構成
ファイルは, 役割に応じて以下のように分類できます.

### ATS9360 関連
```text
ATS9360_NPT_StreamToMemory.m
AlazarDefs.m
alazarLoadLibrary.m
AlazarInclude_pcwin64.m
ATSApi_thunk_pcwin64.dll
ATSApi_thunk_pcwin64.lib
AlazarGetBoardBySystemID.m
AlazarGetBoardKind.m
AlazarGetChannelInfo.m
AlazarSetCaptureClock.m
AlazarInputControlEx.m
AlazarSetBWLimit.m
AlazarSetExternalTrigger.m
AlazarSetTriggerOperation.m
AlazarSetTriggerDelay.m
AlazarSetTriggerTimeOut.m
AlazarConfigureAuxIO.m
AlazarSetRecordSize.m
AlazarBeforeAsyncRead.m
AlazarAllocBuffer.m
AlazarPostAsyncBuffer.m
AlazarStartCapture.m
AlazarWaitAsyncBufferComplete.m
AlazarAbortAsyncRead.m
AlazarFreeBuffer.m
errorToText.m
boardTypeIdToText.m
inputRangeIdToVolts.m
```
### WS-7 関連
```
recordWS7External.m
simple_calls.m
fast_readout.m
longterm.m
longterm.fig
compile_and_call.m
wlmRecordWavelengths.cpp
wlmRecordWavelengths.mexw64
wlmData.h
wlmData.lib
wlm_constants.m
wlm_constants.mat
wlmData.dll
```

## ATS9360関連ファイルの役割

### メインプログラム

| ファイル | 役割 |
|---|---|
| `ATS9360_NPT_StreamToMemory.m` | ATS9360の初期化, 測定条件設定, NPT AutoDMA取得, CHAとCHBの分離, BIN保存, WS-7記録制御を行うメインプログラム. |

### ライブラリ関連

| ファイル | 役割 |
|---|---|
| `alazarLoadLibrary.m` | `ATSApi.dll`をMATLABへ読み込む. |
| `AlazarInclude_pcwin64.m` | `ATSApi.dll`に含まれる関数の引数型, 戻り値, ポインタ型をMATLABへ定義する. |
| `ATSApi_thunk_pcwin64.dll` | MATLABと`ATSApi.dll`の間でデータ型やポインタを変換する. |
| `ATSApi_thunk_pcwin64.lib` | Thunk DLLを生成またはリンクするときに使用する. |
| `AlazarDefs.m` | チャンネル, クロック, 入力レンジ, トリガ, AutoDMAなどの定数を定義する. |

### ボード認識関連

| ファイル | 役割 |
|---|---|
| `AlazarGetBoardBySystemID.m` | システム番号とボード番号から操作対象ボードのハンドルを取得する. |
| `AlazarGetBoardBySystemHandle.m` | システムハンドルから指定ボードのハンドルを取得する. |
| `AlazarGetSystemHandle.m` | 指定したAlazarシステムのハンドルを取得する. |
| `AlazarGetBoardKind.m` | 接続されているボードの機種IDを取得する. |
| `AlazarGetChannelInfo.m` | ボードメモリ容量とADCのビット数を取得する. |
| `AlazarNumOfSystems.m` | PCに認識されているAlazarシステム数を取得する. |
| `AlazarBoardsFound.m` | PCに認識されているAlazarボードの総数を取得する. |
| `AlazarBoardsInSystemBySystemID.m` | 指定したシステム内のボード数を取得する. |
| `AlazarBoardsInSystemByHandle.m` | システムハンドルからボード数を取得する. |

### クロック設定関連

| ファイル | 役割 |
|---|---|
| `AlazarSetCaptureClock.m` | クロック源, サンプリングレート, クロックエッジ, デシメーションを設定する. |
| `AlazarSetExternalClockLevel.m` | 外部クロック使用時の判定レベルを設定する. |

### 入力設定関連

| ファイル | 役割 |
|---|---|
| `AlazarInputControl.m` | 入力チャンネルの結合方式, 入力レンジ, インピーダンスを設定する. |
| `AlazarInputControlEx.m` | 32-bitチャンネル指定に対応した入力設定を行う. |
| `AlazarSetBWLimit.m` | 各入力チャンネルのアナログ帯域制限を設定する. |

### トリガ設定関連

| ファイル | 役割 |
|---|---|
| `AlazarSetTriggerOperation.m` | トリガ源, トリガエッジ, トリガレベル, トリガエンジンを設定する. |
| `AlazarSetExternalTrigger.m` | 外部トリガ端子の結合方式と入力レンジを設定する. |
| `AlazarSetTriggerDelay.m` | トリガ検出後から取得開始までの遅延をサンプル数で設定する. |
| `AlazarSetTriggerTimeOut.m` | トリガを待機する時間を設定する. |
| `AlazarTriggered.m` | トリガが検出されたかを確認する. |
| `AlazarForceTrigger.m` | ソフトウェアから強制的にトリガを発生させる. |
| `AlazarForceTriggerEnable.m` | 強制トリガ機能を有効にする. |
| `AlazarConfigureAuxIO.m` | AUX I/O端子をトリガ出力などに設定する. |

### レコード設定関連

| ファイル | 役割 |
|---|---|
| `AlazarSetRecordSize.m` | 1レコードのトリガ前サンプル数とトリガ後サンプル数を設定する. |
| `AlazarSetRecordCount.m` | 1回の取得で記録するレコード数を設定する. |
| `AlazarGetMaxRecordsCapable.m` | 指定したレコード長で取得可能な最大レコード数を取得する. |

### AutoDMA関連

| ファイル | 役割 |
|---|---|
| `AlazarBeforeAsyncRead.m` | 取得チャンネル, レコード長, レコード数, AutoDMAモードを設定する. |
| `AlazarAllocBuffer.m` | DMA転送用のページ境界整列メモリを確保する. |
| `AlazarPostAsyncBuffer.m` | 確保したDMAバッファをATS9360へ登録する. |
| `AlazarStartCapture.m` | ATS9360を取得開始または外部トリガ待機状態にする. |
| `AlazarWaitAsyncBufferComplete.m` | 指定したDMAバッファへの転送完了を待機する. |
| `AlazarWaitNextAsyncBufferComplete.m` | SDK管理方式で次のDMAバッファの転送完了を待機する. |
| `AlazarAbortAsyncRead.m` | AutoDMA取得を終了する. |
| `AlazarFreeBuffer.m` | 確保したDMAバッファを解放する. |

### 通常取得および状態確認関連

| ファイル | 役割 |
|---|---|
| `AlazarRead.m` | ボード内部メモリから指定レコードを読み出す. |
| `AlazarAbortCapture.m` | 通常のデータ取得を停止する. |
| `AlazarBusy.m` | ボードが取得中かを確認する. |
| `AlazarGetStatus.m` | ボードの現在状態を取得する. |
| `AlazarResetTimeStamp.m` | ボード内部のタイムスタンプカウンタをリセットする. |
| `AlazarGetTriggerAddress.m` | トリガ位置とタイムスタンプ情報を取得する. |
| `AlazarGetTriggerTimestamp.m` | 指定レコードのトリガタイムスタンプを取得する. |

### パラメータおよび機能確認関連

| ファイル | 役割 |
|---|---|
| `AlazarGetParameter.m` | 符号付き内部パラメータを取得する. |
| `AlazarGetParameterUL.m` | 符号なし32-bit内部パラメータを取得する. |
| `AlazarSetParameter.m` | 符号付き内部パラメータを設定する. |
| `AlazarSetParameterUL.m` | 符号なし32-bit内部パラメータを設定する. |
| `AlazarQueryCapability.m` | PCIe速度, ボード機能, 対応能力などを問い合わせる. |
| `AlazarGetDriverVersion.m` | デバイスドライバのバージョンを取得する. |
| `AlazarGetSDKVersion.m` | ATS-SDKのバージョンを取得する. |
| `AlazarGetBoardRevision.m` | ボードのハードウェアリビジョンを取得する. |
| `AlazarGetFPGAVersion.m` | FPGAのバージョンを取得する. |
| `AlazarGetCPLDVersion.m` | CPLDのバージョンを取得する. |
| `AlazarSetLED.m` | ボード上のLEDを点灯または消灯する. |
| `AlazarSleepDevice.m` | ボードを省電力状態へ移行する. |

### 補助関数

| ファイル | 役割 |
|---|---|
| `errorToText.m` | ATS-SDKのエラーコードを説明文へ変換する. |
| `AlazarErrorToText.m` | ATSApiのエラー文字列取得関数を呼び出す. |
| `boardTypeIdToText.m` | ボード機種IDを`ATS9360`などの文字列へ変換する. |
| `inputRangeIdToVolts.m` | 入力レンジIDを実際の電圧値へ変換する. |
| `AlazarHyperDisp.m` | 大容量波形を表示用に縮小する. |

### 特殊機能関連

| ファイル | 役割 |
|---|---|
| `AlazarConfigureRecordAverage.m` | 複数レコードをボード上で平均化する. |
| `AlazarConfigureSampleSkipping.m` | 指定したサンプルだけを選択して取得する. |
| `AlazarCreateStreamFile.m` | ストリーミングデータの保存先ファイルを作成する. |
| `AlazarOCTIgnoreBadClock.m` | OCT用途で不安定な外部クロック区間を処理する. |
| `AlazarCoprocessorDownload.m` | コプロセッサへ設定データをロードする. |
| `AlazarCoprocessorRegisterRead.m` | コプロセッサのレジスタを読み出す. |
| `AlazarCoprocessorRegisterWrite.m` | コプロセッサのレジスタへ値を書き込む. |
| `AlazarExtractNPTFootersEx.m` | NPT取得データから付加情報を抽出する. |

### DSPおよびFFT関連

| ファイル | 役割 |
|---|---|
| `AlazarDSPGetModules.m` | ボード上で利用可能なDSPモジュール一覧を取得する. |
| `AlazarDSPGetModuleByID.m` | 指定IDのDSPモジュールハンドルを取得する. |
| `AlazarDSPGetInfo.m` | DSPモジュールの情報を取得する. |
| `AlazarDSPGetBuffer.m` | DSP処理後のデータバッファを取得する. |
| `AlazarDSPGetNextBuffer.m` | 次のDSP処理済みバッファを取得する. |
| `AlazarDSPAbortCapture.m` | DSPを使用した取得を停止する. |
| `AlazarDSPGenerateWindowFunction.m` | FFT処理用の窓関数を生成する. |
| `AlazarFFTSetup.m` | ボード上FFTの条件を設定する. |
| `AlazarFFTSetWindowFunction.m` | FFT用の窓関数を設定する. |
| `AlazarFFTSetGainAndOffset.m` | FFT出力のゲインとオフセットを設定する. |
| `AlazarFFTSetScalingAndSlicing.m` | FFT出力のスケーリングとビット切り出しを設定する. |
| `AlazarFFTGetMaxTriggerRepeatRate.m` | FFT条件に対する最大トリガ繰返し周波数を取得する. |
| `AlazarFFTBackgroundSubtractionSetEnabled.m` | FFT背景減算機能を有効または無効にする. |
| `AlazarFFTBackgroundSubtractionSetRecordS16.m` | FFT背景減算用データを設定する. |
| `AlazarFFTBackgroundSubtractionGetRecordS16.m` | FFT背景減算用データを取得する. |

## WS-7関連ファイルの役割

### 本測定用プログラム

| ファイル | 役割 |
|---|---|
| `recordWS7External.m` | 別MATLABプロセスでWS-7の波長を連続取得し, 停止ファイルが作成されるまで記録を継続する. |

### MATLABサンプルコード

| ファイル | 役割 |
|---|---|
| `simple_calls.m` | `calllib`を使用してバージョン, 温度, 圧力, チャンネル数, 露光時間, 光周波数, 波長を取得する基本例. |
| `fast_readout.m` | `WaitForWLMEvent`を使用し, 新しい波長イベントごとにタイムスタンプと波長を取得する高速読み出し例. |
| `longterm.m` | WS-7の測定値を長時間記録し, MATLAB上でリアルタイム表示するGUI処理. |
| `longterm.fig` | `longterm.m`で使用するGUIの画面配置, グラフ領域, メニュー, UI部品を保存する. |
| `compile_and_call.m` | C++コードをMEXファイルへコンパイルし, MATLABから実行する手順を示す. |

### MEX関連

| ファイル | 役割 |
|---|---|
| `wlmRecordWavelengths.cpp` | `wlmData.dll`のコールバック機能をC++から使用し, 波長とタイムスタンプを高速取得する. |
| `wlmRecordWavelengths.mexw64` | `wlmRecordWavelengths.cpp`を64-bit Windows用にコンパイルしたMATLAB実行形式. |
| `wlmData.lib` | C++コードやMEXファイルを`wlmData.dll`へリンクするために使用する. |

### ライブラリおよびAPI定義

| ファイル | 役割 |
|---|---|
| `wlmData.dll` | Wavelength Meterソフトウェアが保持する測定値や設定を外部プログラムへ提供する. |
| `wlmData.h` | `wlmData.dll`に含まれる関数, 引数型, 戻り値, ポインタ型, 定数を定義する. |
| `wlm_constants.m` | `wlmData.h`に含まれる定数をMATLAB変数として定義する. |
| `wlm_constants.mat` | API定数をMATLAB構造体として読み込める形式で保存する. |

### 主要API関数

| 関数 | 役割 |
|---|---|
| `Instantiate` | Wait Event方式やコールバック方式などの通知機構を設定または解除する. |
| `WaitForWLMEvent` | 新しい測定イベントが発生するまで待機し, イベント種別と測定値を取得する. |
| `GetWavelengthNum` | 指定チャンネルの最新波長を取得する. |
| `GetFrequencyNum` | 指定チャンネルの最新光周波数を取得する. |
| `GetExposureNum` | 指定チャンネルの露光時間を取得する. |
| `GetTemperature` | 波長計内部の温度を取得する. |
| `GetPressure` | 波長計が使用する気圧値を取得する. |
| `GetChannelsCount` | 使用可能な測定チャンネル数を取得する. |
| `GetWLMVersion` | Wavelength Meterソフトウェアや装置のバージョン情報を取得する. |

### 本測定における使用状況

| ファイル | 使用状況 |
|---|---|
| `recordWS7External.m` | 本測定で直接使用する. |
| `wlmData.dll` | 本測定で直接使用する. |
| `wlmData.h` | 本測定で直接使用する. |
| `wlm_constants.mat` | 本測定で直接使用する. |
| `fast_readout.m` | `WaitForWLMEvent`実装の参考として使用する. |
| `simple_calls.m` | 基本API呼び出しの参考として使用する. |
| `test.m` | DLL接続と単発測定の確認に使用する. |
| `longterm.m` | 長時間記録GUIの参考として使用する. |
| `longterm.fig` | GUI構成の参考として使用する. |
| `compile_and_call.m` | 本測定では使用しない. |
| `wlmRecordWavelengths.cpp` | 本測定では使用しない. |
| `wlmRecordWavelengths.mexw64` | 本測定では使用しない. |
| `wlmData.lib` | 本測定では使用しない. |
| `wlm_constants.m` | API定数の確認用として参照する. |

> [!NOTE]
> 上記の一部ファイルはAlazarTech ATS-SDKに含まれるラッパー関数およびライブラリ関連ファイルです.
> 著作権およびライセンス上の理由から, 本リポジトリではこれらのファイルを公開していません.
> 本READMEでは, ファイル構成と各処理の役割のみを説明します.


### 著作権及びライセンス
AlazarTech, ATS-SDK, ATSApi 及び関連する製品名・ライブラリ名は, AlazarTech, Inc. に帰属します.

本研究で使用したプログラムには, AlazarTech ATS-SDK に含まれるサンプルコード, ラッパー関数, ライブラリ関数が含まれます.

これらのファイルは, AlazarTech のライセンス条件に従う必要があるため, 本リポジトリでは公開, 再配布していません.

本リポジトリは研究内容及び処理方法の説明を目的としており, ソースコードの配布または再利用を許諾するものではありません.
