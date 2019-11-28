################################################################################
#                      intensitycontours.praat                                 #
# ディレクトリ内各wavファイルのインテンシティ系列を(ファイル名)_intensity.csvに出力  #
# (無音区間のF0は--undefined--と表記)                                            #
################################################################################


# CAUTION: praat scriptには「関数」はない
#（あるのは戻り値を返さない"procedure"のみ）
# 代わりにprocedure内ローカル変数returnで値を受け渡す
# (先頭に"."を付けるとprocedure内のローカル変数、付けないとグローバル変数
# ローカル変数は"(procedure名).(変数名)"で外部からも参照可能)


clearinfo


# csvファイルの出力形式をutf-8に指定
do("Text writing preferences...", "UTF-8")


# 引数をフォーム(GUI)で受け取る
form directory path
    # 分析したい音声が入っているディレクトリのパス: directory$に格納
    text directory

    # インテンシティ生成時(To Intensity...)に使用。デフォルト値はPraatのデフォルト値を使用
    comment Intensity extract parameters:
    positive F0Min(Hz) 100
    real FrameStepTime(s) 0
endform


@main(directory$)


procedure main(.wavDirectoryPath$)    
    # wavファイル名を取得
    @filesObj(.wavDirectoryPath$, "/*.wav")
    .wavNamesObj = filesObj.return
    .numFiles = do("Get number of strings")

    .tableObj = do("Create Table with column names...",
    ...            "stats", .numFiles, "file mean max min")
    #              obj name  num of rows  columns


    # 各wavファイルを分析し、結果を.tableObjに記入
    for .i to .numFiles
        .wavName$ = object$[.wavNamesObj, .i]
        .soundObj = do("Read from file...",
        ...            .wavDirectoryPath$ + "/" + .wavName$)
        
        # .soundObjのintensity分析
        @makeIntensityContourTable(.soundObj)
        .tableObj = makeIntensityContourTable.return
        removeObject(.soundObj)

        # NOTE: f0contours.praatの生成ファイルと名前が被らないようにしている
        .csvName$ = .wavName$ - ".wav" + "_intensity.csv"
        selectObject(.tableObj)
        do("Save as comma-separated file...",
        ... .wavDirectoryPath$ + "/" + .csvName$)
        removeObject(.tableObj)
    endfor
endproc


procedure filesObj(.dirPath$, .glob$)
    # デバッグしやすいようにオブジェクト名を.dirPath$にする
    .return = do("Create Strings as file list...",
    ...          .dirPath$, .dirPath$ + .glob$)
endproc


procedure makeIntensityContourTable(.soundObj)
    # NOTE: silent frame intensity is shown as "--undefined--"

    selectObject: .soundObj
    # extract intensity contour from .soundObj
    .intensityObj = do("To Intensity...", f0Min, frameStepTime, "yes")
    .frameStepTime = if frameStepTime then frameStepTime else 0.01 endif
    .times# = to#(do("Get end time") / .frameStepTime) * .frameStepTime
    
    # NOTE: "List values at times" cannot be used for intensity...
    # initialize intensity vector
    .intensities# = zero#(size(.times#))
    for .frame from 1 to size(.times#)
        .intensities#[.frame] = do("Get value at time...", .times#[.frame], "Cubic")
    endfor

    # make table for F0 contour
    .tableObj = do("Create Table with column names...",
    ...            "Intensitycountour '.soundObj'", size(.times#), "t[s] intensity[dB]")
    #               obj name                        num of rows    columns
    selectObject(.tableObj)

    for .frame from 1 to size(.intensities#)
        do("Set numeric value...", .frame, "t[s]", .times#[.frame])
        do("Set numeric value...", .frame, "intensity[dB]", .intensities#[.frame])
    endfor

    removeObject(.intensityObj)
    .return = .tableObj
endproc
