###################################################################
#                      f0contours.praat                           #
# ディレクトリ内各wavファイルのF0系列を同名のcsvに出力                #
# (無声区間のF0は--undefined--と表記)                               #
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
    comment F0 extract parameters:
    positive F0Floor(Hz) 75
    positive F0Ceil(Hz) 600
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
        
        # .soundObjのF0分析
        @makeF0ContourTable(.soundObj)
        .tableObj = makeF0ContourTable.return
        removeObject(.soundObj)

        .csvName$ = .wavName$ - ".wav" + ".csv"
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


procedure makeF0ContourTable(.soundObj)
    # NOTE: unvoiced frame F0 is shown as "--undefined--"

    selectObject: .soundObj
    # extract F0 contour from .soundObj
    .pitchObj = do("To Pitch...", frameStepTime, f0Floor, f0Ceil)
    .frameStepTime = if frameStepTime then frameStepTime else 0.01 endif
    .times# = to#(do("Get end time") / .frameStepTime) * .frameStepTime
    # NOTE: use old style because do#() has not implemented yet...
    .f0s# = List values at times: .times#, "hertz", "linear"

    # make table for F0 contour
    .tableObj = do("Create Table with column names...",
    ...            "F0countour '.soundObj'", size(.f0s#), "t[s] F0[Hz]")
    #               obj name                 num of rows  columns
    selectObject(.tableObj)

    for .frame from 1 to size(.f0s#)
        do("Set numeric value...", .frame, "t[s]", .times#[.frame])
        do("Set numeric value...", .frame, "F0[Hz]", .f0s#[.frame])
    endfor

    removeObject(.pitchObj)
    .return = .tableObj
endproc
