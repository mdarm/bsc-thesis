# Source code for the B.Sc. thesis
This repository contains the Matlab source code corresponding to the thesis *Experimental study of swirl flow and heat transfer in concentric cylinders with tangential inlet flow*. The thesis itself can be downloaded from [here](https://drive.google.com/drive/folders/15u5Fi_lQtK2yJz6T-DN7GTj6o2hvR9nX). It is an experimental research study of swirling decaying flow in an annulus, and its potential usefulness in terms of heat transfer improvement. 

## Contents

The basic calculations are handled by two main scripts, namely: `EgregiousDataPadding.m` and 'FlowCalibration.m'. The rest are functions which are invoked accordingly within, when needed for:

* calculating weighted averages - `WeightedVariance.m' 
* differentiating numerically and performing error propagation - `UncertaintyPropagation.m`
* performing single sample uncertainty analysis - `InstrumentUncertainty.m`
* calculating temperature homogeneity - `TemperatureHomogeneity.m`
* changing the string interpreter - `ChangeInterpreter.m`
* plotting in a predefined size - `PlotDimensions.m`

All scripts are self explanatory and have the appropriate references when needed.

For a quick tryout, just open `EgregiousDataPadding.m` or 'FlowCalibration.m', run it, and see what figures it comes up with. This should work regardless of the Matlab's directory, as it is automatically set for both scripts.
 
### external scripts
A few other toolboxes have been used in the code. To make the code easily accessible, they have been incorporated. (I know, it's not the best method, but it does prevent the code from potentially breaking when these toolboxes get updates.) If you work more with the code, you might want to download these toolboxes yourself though. I have used the following ones:

* For exporting figures to pdf format: [Plot2LaTeX](https://se.mathworks.com/matlabcentral/fileexchange/52700-plot2latex) package.
* For performing regression analysis: [lsqcurvefit_approx][https://github.com/tamaskis/lsqcurvefit_approx-MATLAB]. The code was extended by myself to include uncertainties in both variables. 

### raw data

The `raw data` directory contains two sub-directories: `error estimate` and `flow results`. The first contains the actuality data collected for determining the uncertainty of each sensor, while the second contains the experimental flow data. 
