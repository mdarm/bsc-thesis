# Source code for the B.Sc. thesis
This repository contains the MATLAB source code for the thesis entitled: *Experimental study of swirl flow and heat transfer in concentric cylinders with tangential inlet flow*. The thesis itself can be downloaded from [here](https://drive.google.com/drive/folders/15u5Fi_lQtK2yJz6T-DN7GTj6o2hvR9nX). It is an experimental research study of confined air flow which estimates the heat transfer enhancement under various flow conditions. The results of the computation are given in two files: `results.txt` and `data.txt`, both of which have been formatted in a way that greatly simplifies their implementation in a LaTeX document (i.e. tables and tikz figures). 

## Prerequisites

Software:

* Inkscape, which works in conjunction with the external toolbox `Plot2LaTeX.m` 
* MATLAB R2020a, from which the [curve fitting toolbox](https://se.mathworks.com/products/curvefitting.html) was used.

## Contents

The basic calculations are handled by one script, namely `EgregiousDataPadding.m`. The rest are functions or subroutines which have been invoked for:

* calculating weighted averages: `WeightedVariance.m` 
* differentiating numerically and performing error propagation: `UncertaintyPropagation.m`
* performing single-sample-uncertainty analysis: `InstrumentUncertainty.m`
* performing flow-meter calibration: `FlowCalibration.m`
* changing the string interpreter in plots: `ChangeInterpreter.m`
* plotting in a predefined size: `PlotDimensions.m`

All scripts are self explanatory and have the appropriate references where needed.

### external scripts
A few other toolboxes have been invoked in the code and have been incorporated for accessibility reasons. I know, it's not the best method, but it does prevent the code from potentially breaking down when they get updates. In case you wish to work more with the code, or with parts of it, and given that these toolboxes are used, you might want to download them yourself. These toolboxes are for: 

* exporting figures to pdf format: `Plot2LaTeX.m`, the [Plot2LaTeX](https://se.mathworks.com/matlabcentral/fileexchange/52700-plot2latex) package. Keep in mind that the location of Inkscape has to be 'hard coded' into this matlab file if it differs from 'c:\Program Files (x86)\Inkscape\Inkscape.exe'.
* performing regression analysis: `LeastSquaresFit.m`, originally [lsqcurvefit_approx](https://github.com/tamaskis/lsqcurvefit_approx-MATLAB). The code was extended by myself to acount for uncertainties in both variables. 

### raw data

The `raw data` directory contains two sub-directories: `error estimate` and `flow results`. The first contains the actuality data collected for determining the uncertainty of each sensor (using [single-sample-uncertainty analysis](https://doi.org/10.1115/1.3242452)), while the second contains the experimental flow data (i.e. temperature, power supply and time measurements). 

## Running the code

For a quick tryout, just open `EgregiousDataPadding.m`, run it, and see what figures and results it comes up with. This should work regardless of the MATLAB's directory, as the script has instructions to cd() to the directory it is to work in.

Or, for calling the scripts from the Windows' command line:

```powershell
$ cd /path/to/EgregiousDataPadding.m # add directory of script

$ matlab -nodesktop -nosplash -r "EgregiousDataPadding" # invoke MATLAB
```

Lastly, for computing only the numerical results (i.e. acquiring only the `results.txt` and `data.txt`, without any plots), double click on `compile-code-windows.bat`
