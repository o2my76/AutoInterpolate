% 倍率最適値の探索　25KMH28 光岡 佑馬

%% 各変数の定義 (適宜確認、必要に応じて変更すること)
clear; clc; clf;                            % F5キーで実行 / Ctrl+Enterでセクション実行

tic

% 各モード間隔、RF周波数シフト量の設定 (光周波数シフト量は自動で算出してくれます)
RFDiff = 0.30e6;                             % RF周波数シフト量 [Hz] (RFモード間隔より小さく設定)
AOM = 80e6;                                  % RF中心周波数 [Hz]
OpRep = 25e9;                                % 光モード間隔 (繰り返し周波数 [Hz])
RFRep = 0.35e6;                              % RFモード間隔 [Hz]

% Waveform Generator の CH2のバースト位相と変調波の種類の設定
BurstPhase = 120;                            % バースト位相 [°] (90°以上で設定)
mode = 2;                                    % 変調波の種類 (三角波: 1, 正弦波: 2 を入力)

% 実行するフォルダ名を入力、データ保存の有無決定
NamePrefix = 'my';                          % 読み込むファイルの接頭語 
StartDataNum = 73;                          % 読み込むファイルの開始番号 (例: StartDataNum = 1 と入力すると、my1から読み込みを開始する)
DataNumber = 3;                             % 読み込むファイルの数 
k = 11;                                     % 変化させる倍率の数
m = 10;                                     % 倍率を変化させる際の増分 (例: 50と入力すると、算出値の倍率が50ずつ変化する)
l = -2900;                                  % 倍率を変化させる際の増分のオフセット

% 波長計で取得した時間を入力 [s] (据え置き)
AcquisitionMin = 00;                         % データ取得時間 [分]
AcquisitionSec = 30;                         % データ取得時間 [秒]

AcquisitionTime = 60 * AcquisitionMin + AcquisitionSec;

% 検出する吸収線ピーク値の閾値 (設定した値未満をピーク値とみなす)
RFPeakJudge = 0.92;
OptPeakJudge = 0.935;

% x軸の生成 (自己研究と合致しているか確認すること)
N = 2^25;                                    % サンプル数 [S]
Fs = 200e6;                                  % サンプリングレート [S/s] 
t = (0:N-1) / Fs;                            % 時間軸の生成

% スムージング量の設定
smth = (1.8e9 / Fs) * 90 * N / 2^24;                 % スムージング量の設定 (設定した数のサンプル数でそれぞれ算出値をとる)
CH2_Freq = Fs / (N * 180 / (180 - (BurstPhase - 90) * 2));                   % 変調波周波数

j_shift = ((1:k) - (k + 1) / 2).';
MagnificationCorrection = j_shift * m + l;

%% 全データ保存用配列
Amp_All_GHz = nan(k, DataNumber);
OpDiff_All_GHz = nan(k, DataNumber);
A_Prop_All = nan(k, DataNumber);
DataNameList = strings(1, DataNumber);

%% データの保存
% フォルダを自動で作成し、データを保存
BaseFolder = "C:\Users\yuma0\デスクトップ\研究室\MATLAB用\MATLAB取得データ";  % ファイルの保存先フォルダの選択
DateFolder = string(datetime('now', 'Format', 'yyyyMMdd'));
TimeFolder = string(datetime('now', 'Format', 'HH;mm;ss'));

FirstName = sprintf('%s%03d', NamePrefix, StartDataNum);
LastName  = sprintf('%s%03d', NamePrefix, StartDataNum + DataNumber - 1);

RunFolder = fullfile( ...
    BaseFolder, ...
    DateFolder, ...
    sprintf('%s_mode%d_%s-%s', TimeFolder, mode, FirstName, LastName));

if ~exist(RunFolder, 'dir')
    mkdir(RunFolder);
end

%% HITRANデータの読み込み
% HITRANデータファイルの指定
HITRANdata = readtable("C:\Users\yuma0\デスクトップ\研究室\MATLAB用\SpectrMixt_H13C14N_15Torr");
X_Fraction = HITRANdata{:, 1};                              % HITRANのx軸の取得 (波数 [cm^-1])
HITRAN_X = X_Fraction * 29979245800;                        % 波数から光周波数に変換 [Hz]
HITRAN_Y = HITRANdata{:, 2};                                % HITRANのy軸の取得 (透過率)

%% 選択したファイルのループ処理
for p = 1:DataNumber
    Name = sprintf('%s%03d', NamePrefix, StartDataNum + p - 1);
    DataNameList(p) = string(Name);

    fprintf('\n==============================\n');
    fprintf('Processing: %s  (%d / %d)\n', Name, p, DataNumber);
    fprintf('==============================\n');

    %% 波長計で保存したtxtデータの読み込み、中心波長・光周波数シフト量の推定値の自動測定
    % 読み込むテキストファイルの指定
    wavelengthtxtFolder = "C:\Users\yuma0\デスクトップ\研究室\MATLAB用\txtファイル取り込む用";
    wavelengthFolder = fullfile(wavelengthtxtFolder, Name + ".txt");
    Tdata = readtable(wavelengthFolder);

    Tdata_Time = Tdata{:, 1} / 1e3;                 % 波長計取得データの時間軸の取得 [s]
    wavelength = Tdata{:, 2} / 1e9;                 % 波長計取得データの中心波長の取得 [nm]

    % 波長計で取得した時間から中心波長及び光周波数シフト量の推定値を測定
    TimeRange = (AcquisitionTime <= Tdata_Time) & (Tdata_Time <= AcquisitionTime + 1);     % 取得する範囲の設定
    Acquisition_TimerRange = Tdata_Time(TimeRange);                                        % 設定した範囲の時間軸の取得
    Acquisition_wavelength = wavelength(TimeRange).';                                      % 設定した範囲の波長軸の取得

    % 波長の最大値と最小値の測定 (2/3周期のうち、最大値と最小値を検出するようにする)
    [Max_wavelength, Max_LocsTime] = findpeaks(Acquisition_wavelength, Acquisition_TimerRange, 'MinPeakDistance', 1/CH2_Freq);
    [Min_wavelength, Min_LocsTime] = findpeaks(-Acquisition_wavelength, Acquisition_TimerRange, 'MinPeakDistance', 1/CH2_Freq);
    Min_wavelength = -Min_wavelength;                                                  % 反転したデータを元に戻す

    Center_wavelength = (mean(Max_wavelength) + mean(Min_wavelength)) / 2;
    Fc = 299792458 / Center_wavelength;                                                % 中心波長から中心周波数を算出

    % 中心波長の最大値と最小値から光周波数シフト量の推定値の算出
    OpDiff_Max = 299792458 / mean(Max_wavelength);                                     % 波長の最大値の平均から光周波数に変換
    OpDiff_Min = 299792458 / mean(Min_wavelength);                                     % 波長の最小値の平均から光周波数に変換

    % 光周波数シフト量の算出 (推定値) (mode 1:三角波, mode 2:正弦波)
    if mode == 1
        OpDiff_modConv = (OpDiff_Min - OpDiff_Max) / (180 / (180 - (BurstPhase - 90) * 2));  
    end
    if mode == 2
        OpDiff_modConv = (OpDiff_Min - OpDiff_Max) * sin(2 * (BurstPhase - 90) * pi / 180);
    end
    %% Alazarで取得したBinファイルの読み込み
    % 定数を事前に計算 (Binファイルを読み込むにあたって)
    nBitsPerSample = 16;                                      % サンプルのビット数
    dInputRange_volts = 0.4;                                  % 入力範囲（±0.4 V）
    dSampleZeroValue = (2^(nBitsPerSample - 1)) - 0.5;        % サンプルのゼロ点
    dScaleFactor = dInputRange_volts / dSampleZeroValue;      % スケール係数

    BaseDataFolder = "C:\Users\yuma0\デスクトップ\研究室\MATLAB用\データ処理用元データ";
    DataFolder = fullfile(BaseDataFolder, Name);

    % 1.1 ファイルパスの指定(参照光スペクトル)
    FileNameA = fullfile(DataFolder, '1_1.1.1.1.A.bin');      % ここに読み込むファイルパスを入力 
    fileID = fopen(FileNameA, 'r');                                                    % ファイルを読み込みモードで開く
    if fileID == -1                                                                    % ファイルが正常に開けたかどうかの確認
        error('Unable to open the file: %s', FileNameA);
    end
    data = fread(fileID, 'uint16');                                                    % データを16ビット符号なし整数として読み込む
    fclose(fileID);                                                                    % ファイルを閉じる
    Y1 = dScaleFactor * (double(data) - dSampleZeroValue);                             % サンプル値を電圧値に変換


    % 1.2 ファイルパスの指定（透過光スペクトル）
    FileNameB = fullfile(DataFolder, '1_1.1.1.1.B.bin');      % ここに読み込むファイルパスを入力 
    fileID = fopen(FileNameB, 'r');
    if fileID == -1
        error('Unable to open the file: %s', FileNameB);
    end
    data = fread(fileID, 'uint16');                                                    % データを16ビット符号なし整数として読み込む
    fclose(fileID);
    Y2 = dScaleFactor * (double(data) - dSampleZeroValue);                             % サンプル値を電圧値に変換



    %% フーリエ変換 (時間波形から周波数スペクトルに変換)
    % フーリエ変換
    CombA = fft(Y1);                                                                   % 参照光のフーリエ変換
    f1 = (0:length(Y1)-1)*Fs/length(Y1);                                               % x軸の生成 (周波数)
    CombB = fft(Y2);                                                                   % 透過光のフーリエ変換
    f2 = (0:length(Y2)-1)*Fs/length(Y2);                                               % x軸の生成 (周波数)

    %% 吸収スペクトルの取得
    Absorption = CombB ./ CombA;                      % 透過率の算出
    f3 = (0:length(Absorption)-1)*Fs/length(Absorption);  % X軸の生成

    %% マスク範囲の設定 (ノイズ箇所を除去)
    % マスク範囲の設定
    RFmaskMin = AOM - RFRep * 17 - RFDiff / 2;
    RFmaskMax = AOM + RFRep * 17 + RFDiff / 2;
    RFmask1 = (RFmaskMin <= f1) & (f1 <= RFmaskMax);               % 吸収線表示範囲をmaskに設定
    f1 = f1(RFmask1);                                              % RF吸収線のx軸のうち、設定した「mask」の範囲のみを保存
    CombA= CombA(RFmask1);                       % RF吸収線のy軸のうち、設定した「mask」の範囲のみを保存
    RFmask2 = (RFmaskMin <= f2) & (f2 <= RFmaskMax);               % 吸収線表示範囲をmaskに設定
    f2 = f2(RFmask2);                                              % RF吸収線のx軸のうち、設定した「mask」の範囲のみを保存
    CombB= CombB(RFmask2);                       % RF吸収線のy軸のうち、設定した「mask」の範囲のみを保存
    RFmask3 = (RFmaskMin <= f3) & (f3 <= RFmaskMax);               % 吸収線表示範囲をmaskに設定
    f3 = f3(RFmask3);                                              % RF吸収線のx軸のうち、設定した「mask」の範囲のみを保存
    Absorption= Absorption(RFmask3);                       % RF吸収線のy軸のうち、設定した「mask」の範囲のみを保存


    %% デュアルコムスペクトルのスムージング処理 (平滑化)
    SmthCombA = movmean(abs(CombA), smth);                        % RF参照光スペクトルのスムージング処理
    SmthCombB = movmean(abs(CombB), smth);                        % RF透過光スペクトルのスムージング処理



    %% 除算によるRF吸収スペクトルの取得・表示
    % 3.1 RF吸収スペクトルの取得及び表示（スムージング処理前）

    % 3.2.1 RF吸収スペクトルの取得及び表示（スムージング処理後）+ マスク後のRF吸収スペクトルの表示及び吸収線ピークの検出、表示
    % RF吸収スペクトルのスムージング処理
    SmthAbsorption = movmean(abs(Absorption), smth);                       % RF吸収スペクトルのスムージング処理


    %% RF吸収線のピーク位置検出・表示
    % 3.2.2 RF吸収線のピーク位置の検出
    RFminPeakDistance = 0.05e6;                                                % 検出するピーク間隔の設定 (あえてここでの間隔を短くし、その後不要なピーク成分を除去)

    % 設定した範囲内でのピーク値の検出 (「RFPeakAbsorption」: y軸(ピーク値) 「RFPeakLocation」: x軸(ピーク位置) )
    [RFPeakAbsorption, RFPeakLocation] = findpeaks(-SmthAbsorption, f3, 'MinPeakDistance', RFminPeakDistance);
    RFPeakAbsorption = -RFPeakAbsorption;                                      % 反転したデータを元に戻す

    % 不要なピーク成分を除去 (ベースライン部分のノイズ箇所をピークとして検出してしまっているため)
    idx = RFPeakAbsorption < RFPeakJudge;                                        % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
    RFPeakLocation = RFPeakLocation(idx);                                      % 除去後のピーク位置(x軸)に「RFPeakLocation」を上書き
    RFPeakAbsorption = RFPeakAbsorption(idx);                                  % 除去後のピーク値(y軸)に「PEPeakAbsorption」を上書き



    %% 検出したRF吸収線のピーク間隔のうち、隣り合ったピーク間隔のみを自動で算出
    % 隣り合ったRF吸収線ピーク間隔の算出及び標準偏差の算出
    PeakDiff1 = RFPeakLocation(2:end) - RFPeakLocation(1:end-1);            % RF吸収線ピーク間隔の算出 (x成分)
    PeakAbsorption = abs(RFPeakAbsorption(2:end) - RFPeakAbsorption(1:end-1)); % RF吸収線ピーク値の算出 (y成分)
    idx = PeakDiff1 < 0.5e6;                                                % 隣り合った吸収線かどうかの判別 (間隔が0.5 MHz 未満で隣り合っていると判断し、インデックスを取得)
    PeakDiff1 = PeakDiff1(idx);                                             % 隣り合った吸収線ピーク間隔のみ残す (x成分)
    PeakAbsorption = PeakAbsorption(idx);                                   % 隣り合った吸収線ピーク値のみ残す (y成分)

    idx = PeakAbsorption < 0.03;                                            % 隣り合った吸収線ピーク値の差分の算出 (0.03未満のみを残し、インデックスを取得)
    PeakDiff2 = PeakDiff1(idx);                                             % 取得したインデックスの吸収線ピーク間隔のみ残す
    std_PeakDiff = std(PeakDiff2);                                          % 隣り合った吸収線ピーク間隔の標準偏差を「std_PeakDiff」として保存


    %% 隣り合ったピーク間隔から光周波数シフト量を自動で算出
    % 4.1 設計した光周波数シフト量から隣り合った吸収線ピーク間隔の算出 (推定値)
    modConv_PeakDiff = abs(OpRep * RFDiff / OpDiff_modConv - RFRep);              % 推定値の大きさを「modConv_PeakDiff」として保存

    % 4.2.1 隣り合ったRF吸収線ピーク間隔の算出値の算出
    Prop_PeakDiff = mean(PeakDiff1);                                       % 隣り合った吸収線ピーク間隔の算出値を「Prop_PeakDiff」として保存

    % 4.2.2 RFピーク間隔の算出値を用いた光周波数シフト量の算出
    OpDiff_Prop = OpRep * RFDiff / (-Prop_PeakDiff +RFRep);                 % 算出値から算出した光周波数シフト量を「OpDiff_Prop」として保存



    %% 準備：配列の初期化 / 事前割り当て・倍率の算出
    % 事前準備1: 配列の初期化・事前割り当て (これをするとデータ処理時間が格段に速くなる)
    n = 35;
    RF_Center = zeros(1,n); OP_Center = zeros(1,n);
    B_modConv = zeros(1, n);    B_Prop = zeros(1, n);
    RFX1 = cell(n, 1); RFX2 = cell(n, 1); 
    RFY1 = cell(1, n); RFY2 = cell(1, n); 
    OPX1_modConv = cell(n, 1); OPX1_Prop = cell(n, 1); 
    OPX2_modConv = cell(n, 1); OPX2_Prop = cell(n, 1); 
    cutOPX1_modConv = cell(n, 1); cutOPX1_Prop = cell(n, 1);
    cutOPY1_modConv = cell(1, n); cutOPY1_Prop = cell(1, n);
    cutOPX2_modConv = cell(n, 1); cutOPX2_Prop = cell(n, 1);
    cutOPY2_modConv = cell(1, n); cutOPY2_Prop = cell(1, n);

    Amp = nan(k, 1);
    A_Prop_List = nan(k, 1);
    OpDiff_Prop_List = nan(k, 1);

    % 事前準備2: 算出したそれぞれのピーク間隔より算出した光周波数シフト量による倍率算出 (光周波数シフト量/RF周波数シフト量)
    A_modConv = OpDiff_modConv / RFDiff;                         % 波長計データから得られた推定値を用いた倍率の算出
    A_Prop = OpDiff_Prop / RFDiff;                         % 算出値を用いた倍率の算出
    A_Prop_base = A_Prop;                                  % 基準となる倍率を保存

    %% 算出した倍率を用いて、RF領域から光領域へ自動で変換
    % 算出した倍率を用いてRF領域から光領域へ変換 ※スペクトル毎に変換式が異なるので注意
    % 倍率を変化させながら、RF領域から光領域への変換を実行
    for j = 1:k
        A_Prop = A_Prop + j_shift(j) * m + l;     % 倍率を変化させる (基準となる倍率から、増分を変化させながら倍率を変化させる)
        A_Prop_List(j) = A_Prop;   % 各jにおけるA_Propを保存
        OpDiff_Prop_List(j) = A_Prop * RFDiff;   % 各jにおける算出値を保存

        for i = 1:n
            RFc = AOM + RFRep * (i - 18);                                                        % RFコムスペクトルの中心周波数を算出 (共通)
            RF_Center(i) = RFc;                                                                  % 各RFコムスペクトル中心周波数を「RF_Center」に格納
            B_modConv_temp = Fc + (OpRep * (i - 18)) - (A_modConv * (AOM + RFRep * (i - 18)));           % オフセット周波数の算出 (推定値)
            B_modConv(i) = B_modConv_temp;                                                               % 各RFコムスペクトルのオフセット周波数を「B_modConv」に格納
            B_Prop_temp = Fc + (OpRep * (i - 18)) - (A_Prop * (AOM + RFRep * (i - 18)));           % オフセット周波数の算出 (算出値)
            B_Prop(i) = B_Prop_temp;                                                               % 各RFコムスペクトルのオフセット周波数を「B_Prop」に格納

            % 5.1 RFコムの切り取り範囲の設定 (共通)
            RFmin = -RFDiff / 2 + RFc;                                              % RFコムスペクトルの中心から切り取る範囲の最小値
            RFmax = RFDiff / 2 + RFc;                                               % RFコムスペクトルの中心から切り取る範囲の最大値
            cut_RF = (RFmin <= f1) & (f1 <= RFmax);                                 % RFコムスペクトルの切り取る範囲を「cut_RF」として保存
            % 5.2 RF参照光スペクトルの切り取り、結果を格納 (共通)
            cutf1 = f1(cut_RF);                                                     % x軸のうち「cut」で指定した範囲を切り取り、「cutf1」として保存
            RFX1{i} = cutf1;                                                        % 「RFX1」に格納
            cutCombA = CombA(cut_RF);                                       % y軸のうち「cut」で指定した範囲を切り取り、「cutCombA」として保存
            RFY1{i} = cutCombA;                                                 % 「RFY1」に格納
            % 5.3 RF透過光スペクトルの切り取り、結果を格納 (共通)
            cutf2 = f2(cut_RF);                                                     % x軸のうち「cut」で指定した範囲を切り取り、「cutf2」として保存
            RFX2{i} = cutf2;                                                        % 「RFX2」に格納
            cutCombB = CombB(cut_RF);                                       % y軸のうち「cut」で指定した範囲を切り取り、「cutCombB」として保存
            RFY2{i} = cutCombB;                                                 % 「RFY2」に格納
            % 5.4 RF領域から光領域へ変換、結果を格納
            OP1_modConv = A_modConv .* cutf1 + B_modConv_temp;                                  % 光領域へ変換した参照光スペクトルの保存
            OPX1_modConv{i} = OP1_modConv;                                                  % 「OPX1_modConv」に格納
            OP2_modConv = A_modConv .* cutf2 + B_modConv_temp;                                  % 光領域へ変換した透過光スペクトルの保存
            OPX2_modConv{i} = OP2_modConv;                                                  % 「OPX2_modConv」に格納
            OP1_Prop = A_Prop .* cutf1 + B_Prop_temp;                                  % 光領域へ変換した参照光スペクトルの保存
            OPX1_Prop{i} = OP1_Prop;                                                  % 「OPX1_modConv」に格納
            OP2_Prop = A_Prop .* cutf2 + B_Prop_temp;                                  % 光領域へ変換した透過光スペクトルの保存
            OPX2_Prop{i} = OP2_Prop;                                                  % 「OPX2_modConv」に格納
            
            % 6.1 取得したEOコムスペクトルの中心周波数から光モード間隔分の切り取り
            OPFc = Fc + OpRep * (i - 18);                                   % EOコムスペクトルの中心周波数を算出
            OP_Center(i) = OPFc;                                            % 各EOコムスペクトルの中心周波数を「OP_Center」に格納
            % 6.2 EOコムの切り取り範囲の設定、切り取りの実行、結果を格納
            OPmin = -OpRep / 2 + OPFc;                                      % EOコムスペクトルの中心から切り取る範囲の最小値
            OPmax = OpRep / 2 + OPFc;                                       % EOコムスペクトルの中心から切り取る範囲の最大値
                % 6.2.1 推定値
                cutOP_modConv = (OPmin <= OP1_modConv) & (OP1_modConv < OPmax);     % 推定値におけるEOコムスペクトルの切り取る範囲を「cutOP_modConv」として保存
                X1_modConv = OP1_modConv(cutOP_modConv);                            % 切り取り後の参照光スペクトルのx軸の保存
                cutOPX1_modConv{i} = X1_modConv;                                % 「cutOPX1_modConv」に格納
                Y1_modConv = cutCombA(cutOP_modConv);                       % 切り取り後の参照光スペクトルのy軸の保存
                cutOPY1_modConv{i} = Y1_modConv;                                % 「cutOPY1_modConv」に格納
                X2_modConv = OP2_modConv(cutOP_modConv);                            % 切り取り後の透過光スペクトルのx軸の保存
                cutOPX2_modConv{i} = X2_modConv;                                % 「cutOPX2_modConv」に格納
                Y2_modConv = cutCombB(cutOP_modConv);                       % 切り取り後の透過光スペクトルのy軸の保存
                cutOPY2_modConv{i} = Y2_modConv;                                % 「cutOPY2_modConv」に格納
                % 6.2.2 算出値
                cutOP_Prop = (OPmin <= OP1_Prop) & (OP1_Prop < OPmax);     % 以下同様
                X1_Prop = OP1_Prop(cutOP_Prop);
                cutOPX1_Prop{i} = X1_Prop;
                Y1_Prop = cutCombA(cutOP_Prop);
                cutOPY1_Prop{i} = Y1_Prop;
                X2_Prop = OP2_Prop(cutOP_Prop);
                cutOPX2_Prop{i} = X2_Prop;
                Y2_Prop = cutCombB(cutOP_Prop);
                cutOPY2_Prop{i} = Y2_Prop;
        end


        %% 光領域変換後のEOコムスペクトルの表示 (切り取り前・スムージング前後)
        % スムージング前の切取前の光領域変換後のEOコムスペクトルの表示 (推定値)

        for i = 1:n
            SmthRFY1 = movmean(abs(RFY1{i}), smth);                       % RF参照光スペクトルのスムージング処理
            SmthRFY2 = movmean(abs(RFY2{i}), smth);                       % RF透過光スペクトルのスムージング処理
        end

        % 切取前の光領域変換後のEOコムスペクトルの表示 (算出値)
        for i = 1:n
            SmthRFY1 = movmean(abs(RFY1{i}), smth);                       % RF参照光スペクトルのスムージング処理
            SmthRFY2 = movmean(abs(RFY2{i}), smth);                       % RF透過光スペクトルのスムージング処理
        end

        %% EOコムスペクトルの表示範囲に合わせて、HITRANのマスク・ピーク位置の検出
        % 準備: HITRANのマスク範囲の設定、実行
        OPmaskMin = Fc - OpRep * 17.5;
        OPmaskMax = Fc + OpRep * 17.5;
        OPmask = (OPmaskMin <= HITRAN_X) & (HITRAN_X <= OPmaskMax);     % HITRAN表示範囲を設定
        HITRAN_X = HITRAN_X(OPmask);                                    % HITRANのx軸の指定した範囲をマスク
        HITRAN_Y = HITRAN_Y(OPmask);                                    % HITRANのy軸の指定した範囲をマスク

        % HITRANのピーク位置の検出
        OPminPeakDistance = 0.05e12;            % 検出ピーク間隔の設定 (これもRF同様あえて値を小さくし、その後余分なピーク成分を除去)

        % ピーク検出の実行
        [Peak_HITRAN_Y, Peak_HITRAN_X] = findpeaks(-HITRAN_Y, HITRAN_X, 'MinPeakDistance', OPminPeakDistance);
        Peak_HITRAN_Y = -Peak_HITRAN_Y;         % 反転したデータを元に戻す

        % HITRANの不要なピーク成分を除去
        idx = Peak_HITRAN_Y < OptPeakJudge;       % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
        Peak_HITRAN_X = Peak_HITRAN_X(idx);    % 除去後のHITRANのx軸に上書き
        Peak_HITRAN_Y = Peak_HITRAN_Y(idx);    % 除去後のHITRANのy軸に上書き


        %% 切り取り後のEOコムスペクトル・吸収スペクトルの表示・ピーク位置の検出
        % 推定値 (波長計で測定した光周波数シフト量)
        % 8.1.1 スムージング前の切取後の光領域変換後のEOコムスペクトルの表示 (推定値)
        % Cell中のベクトルをすべて縦ベクトルに変換
        AX2_col = cellfun(@(v) v(:), cutOPX2_modConv, 'UniformOutput', false);
        AY2_col = cellfun(@(v) v(:), cutOPY2_modConv, 'UniformOutput', false);
        AX1_col = cellfun(@(v) v(:), cutOPX1_modConv, 'UniformOutput', false);
        AY1_col = cellfun(@(v) v(:), cutOPY1_modConv, 'UniformOutput', false);
        % 縦方向に連結し、1本のスペクトルの線にする
        AX2 = vertcat(AX2_col{:}); AY2 = vertcat(AY2_col{:});
        AX1 = vertcat(AX1_col{:}); AY1 = vertcat(AY1_col{:});
        % グラフの表示

        % 8.1.2 スムージング後の切取後の光領域変換後のEOコムスペクトルの表示 (推定値)
        SmthAY1 = movmean(abs(AY1), smth);                       % 参照光スペクトルのスムージング処理
        SmthAY2 = movmean(abs(AY2), smth);                       % 透過光スペクトルのスムージング処理

        % 8.1.3 吸収スペクトルの取得及び表示、HITRANとの比較 (推定値)
        Absorption_modConv = AY2 ./ AY1;                                  % 透過率の算出
        % 吸収スペクトルのスムージング処理
        Absorption_modConv = movmean(abs(Absorption_modConv), smth);                       % 吸収スペクトルのスムージング処理 


        %% ピーク位置の検出 (推定値)
        % 8.1.4 吸収線ピーク位置の検出、HITRANとの比較 (推定値)
        [PeakAbsorption_modConv, PeakLocation_modConv] = findpeaks(-Absorption_modConv, AX1, 'MinPeakDistance', OPminPeakDistance);
        PeakAbsorption_modConv = -PeakAbsorption_modConv;                                   % 反転したデータを元に戻す
        idx = PeakAbsorption_modConv < OptPeakJudge;                                      % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
        PeakLocation_modConv = PeakLocation_modConv(idx);                                  % 除去後のx軸に上書き
        PeakAbsorption_modConv = PeakAbsorption_modConv(idx);                              % 除去後のy軸に上書き

        % HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
        if length(Peak_HITRAN_X) ~= length(PeakLocation_modConv)
            MinLen = min(length(Peak_HITRAN_X), length(PeakLocation_modConv));
            Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
            Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
            PeakLocation_modConv = PeakLocation_modConv(1:MinLen);
            PeakAbsorption_modConv = PeakAbsorption_modConv(1:MinLen);
        end


        %% 算出値 (隣り合ったRF吸収線のピーク間隔の算出値)
        % 8.2.1 スムージング前の切取後の光領域変換後のEOコムスペクトルの表示 (算出値)
        % Cell中のベクトルをすべて縦ベクトルに変換
        BX2_col = cellfun(@(v) v(:), cutOPX2_Prop, 'UniformOutput', false);
        BY2_col = cellfun(@(v) v(:), cutOPY2_Prop, 'UniformOutput', false);
        BX1_col = cellfun(@(v) v(:), cutOPX1_Prop, 'UniformOutput', false);
        BY1_col = cellfun(@(v) v(:), cutOPY1_Prop, 'UniformOutput', false);
        % 縦方向に連結し、1本のスペクトルの線にする
        BX2 = vertcat(BX2_col{:}); BY2 = vertcat(BY2_col{:});
        BX1 = vertcat(BX1_col{:}); BY1 = vertcat(BY1_col{:});

        % 8.2.2 スムージング後の切取後の光領域変換後のEOコムスペクトルの表示 (算出値)
        SmthBY1 = movmean(abs(BY1), smth);                       % 参照光スペクトルのスムージング処理
        SmthBY2 = movmean(abs(BY2), smth);                       % 透過光スペクトルのスムージング処理

        % 8.2.3 吸収スペクトルの取得及び表示、HITRANとの比較 (算出値)
        Absorption_Prop = BY2 ./ BY1;                                  % 透過率の算出
        % 吸収スペクトルのスムージング処理
        Absorption_Prop = movmean(abs(Absorption_Prop), smth);                       % 吸収スペクトルのスムージング処理


        %% ピーク位置の検出 (算出値)
        % 8.2.4 吸収線ピーク位置の検出、HITRANとの比較 (算出値)
        [PeakAbsorption_Prop, PeakLocation_Prop] = findpeaks(-Absorption_Prop, BX1, 'MinPeakDistance', OPminPeakDistance);
        PeakAbsorption_Prop = -PeakAbsorption_Prop;                                   % 反転したデータを元に戻す
        idx = PeakAbsorption_Prop < OptPeakJudge;                                      % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
        PeakLocation_Prop = PeakLocation_Prop(idx);                                  % 除去後のx軸に上書き
        PeakAbsorption_Prop = PeakAbsorption_Prop(idx);                              % 除去後のy軸に上書き

        % HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
        if length(Peak_HITRAN_X) ~= length(PeakLocation_Prop)
            MinLen = min(length(Peak_HITRAN_X), length(PeakLocation_Prop));
            Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
            Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
            PeakLocation_Prop = PeakLocation_Prop(1:MinLen);
            PeakAbsorption_Prop = PeakAbsorption_Prop(1:MinLen);
        end

        %% 取得データとHITRANのピーク間隔の差分の測定 / 比較・標準偏差の算出
        % HITRANと取得した吸収線ピーク位置の残差の算出及び表示
        PeakRes_HITRAN_AX = abs(Peak_HITRAN_X(1:end).' - PeakLocation_modConv(1:end).');                    % HITRANと推定値とのピーク位置の差分の算出
        PeakRes_HITRAN_BX = abs(Peak_HITRAN_X(1:end).' - PeakLocation_Prop(1:end).');                    % HITRANと算出値とのピーク位置の差分の算出

        % 標準偏差の算出及び表示 (ここ大事)
        PeakRes_HITRAN_AX_SD = std(PeakRes_HITRAN_AX);
        PeakRes_HITRAN_BX_SD = std(PeakRes_HITRAN_BX);

        Amp(j) = PeakRes_HITRAN_BX_SD;     % 算出値のピーク位置の差分の標準偏差を「Amp」に保存
        A_Prop = A_Prop_base;              % 基準となる倍率に戻す (次のループで倍率を変化させるため)

    end
    Amp_All_GHz(:, p) = Amp / 1e9;
    OpDiff_All_GHz(:, p) = OpDiff_Prop_List / 1e9;
    A_Prop_All(:, p) = A_Prop_List;
end

% 除算後の吸収スペクトル (ピークがきちんと検出されているかの確認用)
figure
plot(BX1, Absorption_Prop, 'r', 'LineWidth', 1);
hold on
plot(HITRAN_X, HITRAN_Y, '--g', 'LineWidth', 1);              % HITRANの表示 (破線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 195.2e12:0.2e12:196.2e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([195.2e12 196.2e12])                                     % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% title('Baseline Corrected Optical Absorption of Proposed Method')     % グラフのタイトル
legend('Measurement of Proposed Method','HITRAN')           % 凡例
fontsize(20,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定
plot(Peak_HITRAN_X, Peak_HITRAN_Y, 'bv', 'MarkerFaceColor', 'c');                 % HITRANのピーク位置に谷(シアン)でプロット
plot(PeakLocation_Prop, PeakAbsorption_Prop, 'bv', 'MarkerFaceColor', 'm');   % 最終的に検出した吸収線ピークを谷(マゼンタ)でプロット
legend('Measurement of Proposed Method','HITRAN')           % 凡例

hold off

% CSVファイルへの保存
No = (1:k).';

AmpTable = table( ...
    No, MagnificationCorrection, j_shift, ...
    'VariableNames', {'No', 'MagnificationCorrection', 'j_shift'});

for p = 1:DataNumber
    AmpTable.(char(DataNameList(p))) = Amp_All_GHz(:, p);
end

AmpCSVFilePath = fullfile( ...
    RunFolder, ...
    sprintf('mode%d %s-%s.csv', mode, FirstName, LastName));

writetable(AmpTable, AmpCSVFilePath, 'Encoding', 'UTF-8');

%% OpDiffとAmpを含む詳細CSV
DetailTable = table( ...
    No, MagnificationCorrection, j_shift, ...
    'VariableNames', {'No', 'MagnificationCorrection', 'j_shift'});

for p = 1:DataNumber

    BaseName = char(DataNameList(p));

    DetailTable.([BaseName, '_OpDiff_GHz']) = OpDiff_All_GHz(:, p);
    DetailTable.([BaseName, '_Amp_GHz']) = Amp_All_GHz(:, p);

end

DetailCSVFilePath = fullfile( ...
    RunFolder, ...
    sprintf('mode%d %s-%s_detail.csv', mode, FirstName, LastName));

writetable(DetailTable, DetailCSVFilePath, 'Encoding', 'UTF-8');

fprintf('\n保存完了：\n');
fprintf('%s\n', AmpCSVFilePath);
fprintf('%s\n', DetailCSVFilePath);

toc;