###################################################################
#                      f0contours.praat                           #
# ディレクトリ内各wavファイルのF0系列を同名のcsvに出力                #
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
    selectObject: .soundObj
    # extract F0 contour from .soundObj
    .pitchObj = do("To Pitch...", frameStepTime, f0Floor, f0Ceil)
    .nFrames = do("Get number of frames")

    # make table for F0 contour
    .tableObj = do("Create Table with column names...",
	...            "F0countour '.soundObj'", .nFrames, "t[s] F0[Hz]")
	#               obj name                 num of rows  columns

    for .frame from 1 to .nFrames
		selectObject(.pitchObj)
        .t = do("Get time from frame number...", .frame)
        .f0 = do("Get value in frame...", .frame, "Hertz")
        
        #分析結果を.tableObjに格納
		selectObject(.tableObj)
		do("Set numeric value...", .frame, "t[s]", .t)
		# NOTE: NaNの互換性のためF0をstringに変換しテーブルに格納
        # (F0がundefined(=unvoiced)のとき,セルを"undefined"ではなく
        # ""(NaNとして扱われる)にするため)
        do("Set string value...", .frame, "F0[Hz]",
        ... if .f0 == undefined then "" else string$(.f0) endif)
    endfor

	removeObject(.pitchObj)
    .return = .tableObj
endproc
