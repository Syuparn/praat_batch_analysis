###################################################################
#                      f0statistics.praat                         #
# ディレクトリ内全wavファイルのF0 mean, max, minを表にまとめcsvに出力 #
###################################################################


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
    # 分析結果csvファイルの保存先: saveResultTo$に格納
    comment save result table to:
    text saveResultTo f0results.csv

    # F0生成時(To Pitch...)に使用。デフォルト値はPraatのデフォルト値を使用
    comment F0 extract parameters:
    positive F0Floor(Hz) 75
    positive F0Ceil(Hz) 600
    real FrameStepTime(s) 0
endform


# HACK: 拡張子".csv"が末尾についていない場合のみ付ける
@main(directory$, saveResultTo$ - ".csv" + ".csv")


procedure main(.wavDirectoryPath$, .resultCsvPath$)
    # ディレクトリwavDirectoryPath$内のファイル名一覧を.wavPathsObjに格納
    
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
        
        # .soundObjのF0分析
        @statRow(.soundObj)
        
        #分析結果を.tableObjに格納
        selectObject(.tableObj)
        do("Set string value...", .i, "file", .wavName$)
        do("Set numeric value...", .i, "mean", statRow.return["mean"])
        do("Set numeric value...", .i, "max", statRow.return["max"])
        do("Set numeric value...", .i, "min", statRow.return["min"])
        
        removeObject(.soundObj)
    endfor

    # tableObj保存
    selectObject(.tableObj)
    do("Save as comma-separated file...",
    ... .wavDirectoryPath$ + "/" + .resultCsvPath$)
endproc


procedure filesObj(.dirPath$, .glob$)
    # デバッグしやすいようにオブジェクト名を.dirPath$にする
    .return = do("Create Strings as file list...",
    ...          .dirPath$, .dirPath$ + .glob$)
endproc


procedure statRow(.soundObj)
    # wavファイルのF0分析結果を配列(っぽいもの)で返す

    selectObject(.soundObj)
    # soundオブジェクトからpitchオブジェクトを生成
    .pitchObj = do("To Pitch...", frameStepTime, f0Floor, f0Ceil)
    @meanF0: .pitchObj
    @maxF0: .pitchObj
    @minF0: .pitchObj
    removeObject(.pitchObj)

    .return["mean"] = meanF0.return
    .return["max"] = maxF0.return
    .return["min"] = minF0.return
endproc


procedure meanF0: .pitchObj
    selectObject(.pitchObj)
    .return = do("Get mean...", 0, 0, "Hertz")
endproc


procedure maxF0: .pitchObj
    selectObject(.pitchObj)
    .return = do("Get maximum...", 0, 0, "Hertz", "Parabolic")
endproc


procedure minF0: .pitchObj
    selectObject(.pitchObj)
    .return = do("Get minimum...", 0, 0, "Hertz", "Parabolic")
endproc
