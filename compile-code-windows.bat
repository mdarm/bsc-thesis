set srcpath=%~dp0
matlab -nosplash -r "try; run('%srcpath%EgregiousDataPadding.m'); catch; end; quit"
