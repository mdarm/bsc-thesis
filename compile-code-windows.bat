::================================================================
:: The below script is used to automatically detect the path and 
:: run the EgregiousDataPadding script without producing any plots
::================================================================
set srcpath=%~dp0
matlab -nosplash -noFigureWindows -r "try; run('%srcpath%EgregiousDataPadding.m'); catch; end; quit"
