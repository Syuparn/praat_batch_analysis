# praat_batch_analysis
Extract F0 and Intensity of all .wav files as .csv dataframe by Praat

# about
## f0contours.praat
output F0 contour of each .wav file in the directory to .csv file

(each csv file name is same as corresponding wav file (hoge.wav -> hoge.csv))

csv file format:

|t[s]|F0[Hz]|
|---:|---:|
|0.01||
|0.02|99.15|
|0.03|100.83|

`NOTE:` an unvoiced frame is shown as an empty element

## f0statistics.praat
output max, min, and mean value of F0 contour of each .wav file in the directory to .csv file

(all results are written to 1 csv file)

csv file format ([Hz]):

|file|mean|max|min|
|---:|---:|---:|---:|
|speech1.wav| 101.07 | 175.95 | 81.62 |
|speech2.wav| 189.55 | 216.51 | 169.18 |
|speech3.wav| 222.95 | 312.41 | 166.43 |


## intensitystatistics.praat
output max, min, and mean value of intensity of each .wav file in the directory to .csv file

(all results are written to 1 csv file)

csv file format ([dB]):

(same as f0statistics.praat)


# usage 
1. Open Praat
1. From "Open Praat Script", read the script you want to run
1. Run script
1. Choose Directory files from message box
1. You get F0(or Intensity) data CSV file!
