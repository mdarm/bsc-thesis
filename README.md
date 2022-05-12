# Source code for the B.Sc. thesis
This repository contains the Matlab source code corresponding to the thesis *Experimental study of swirl flow and heat transfer in concentric cylinders with tangential inlet flow*. The thesis itself can be downloaded from [here](https://drive.google.com/drive/folders/15u5Fi_lQtK2yJz6T-DN7GTj6o2hvR9nX). It is an experimental research study of confined air flow which estimates the heat transfer enhancement under certain flow conditions. The results of the computation are given in two files: `results.txt` and `data.txt`, both of which have been formated in a way that greatly simplifies their implementation in a LaTeX table. 

## Prerequisites

Software:

* Inkscape
* MATLAB R2020a, from which the [curve fitting toolbox](https://se.mathworks.com/products/curvefitting.html) was used.

## Contents

The basic calculations are handled by two main scripts, namely: `EgregiousDataPadding.m` and 'FlowCalibration.m'. The rest are functions which are invoked accordingly within, for:

* calculating weighted averages - `WeightedVariance.m` 
* differentiating numerically and performing error propagation - `UncertaintyPropagation.m`
* performing single-sample-uncertainty analysis - `InstrumentUncertainty.m`
* calculating temperature homogeneity - `TemperatureHomogeneity.m`
* changing the string interpreter - `ChangeInterpreter.m`
* plotting in a predefined size - `PlotDimensions.m`

All scripts are self explanatory (in Greek) and have the appropriate references when needed.

For a quick tryout, just open `EgregiousDataPadding.m` or `FlowCalibration.m`, run it, and see what figures and results it comes up with. This should work regardless of the Matlab's directory, as both scripts have instructions to cd() to the directory they are to work in.

Or, for calling the scripts from the Windows' command line:

```powershell
$ cd /path/to/EgregiousDataPadding.m # add directory of script

$ matlab -nodesktop -nosplash -r "EgregiousDataPadding" # invoke MATLAB
```

Lastly, for computing only the numerical results (i.e. no plots), double click on `compile-code-windows.bat` after providing it with the current directory of the script. 

### external scripts
A few other toolboxes have been used in the code. To make the code easily accessible, they have been incorporated. (I know, it's not the best method, but it does prevent the code from potentially breaking when these toolboxes get updates.) If you work more with the code, you might want to download these toolboxes yourself though. I have used the following ones:

* For exporting figures to pdf format: `Plot2LaTeX.m`, the [Plot2LaTeX](https://se.mathworks.com/matlabcentral/fileexchange/52700-plot2latex) package.
* For performing regression analysis: `LeastSquaresFit.m`, originally [lsqcurvefit_approx](https://github.com/tamaskis/lsqcurvefit_approx-MATLAB). The code was extended by myself to include uncertainties for both variables. 

### raw data

The `raw data` directory contains two sub-directories: `error estimate` and `flow results`. The first contains the actuality data collected for determining the uncertainty of each sensor, while the second contains the experimental flow data. 
