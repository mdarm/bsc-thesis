# Source code for the B.Sc. thesis
This repository contains the Matlab source code corresponding to the thesis *Experimental study of swirl flow and heat transfer in concentric cylinders with tangential inlet flow*. The [thesis](http://hildobijl.com/Downloads/GPRT.pdf) itself can be downloaded from [here](https://drive.google.com/drive/folders/15u5Fi_lQtK2yJz6T-DN7GTj6o2hvR9nX). It is an experimental research study of swirling decaying flow in an annulus, and its potential usefulness in terms of heat transfer improvement. 

## Contents

Every chapter in the thesis has its own folder. Just open the folder and you will find a Matlab script with the same name. For instance, `Chapter4.m`.

The experiments at the end of each chapter are generally done in a separate file. You will just have to guess which file name corresponds best to the experiment.

In general, just open a file, make sure that the folder it is in is set as Matlab's current working directory, run it and see what figures it comes up with.

## External toolboxes

I have used a few other toolboxes in the code. To make the code easily accessible, I have incorporated these toolboxes. (I know, it's not the best method, but it does prevent the code from potentially breaking when these toolboxes get updates.) If you work more with the code, you might want to download these toolboxes yourself though. I have used the following ones.

* For exporting figures to files, the [Plot2LaTeX](https://se.mathworks.com/matlabcentral/fileexchange/52700-plot2latex) package.
* For chapter 5: the NIGP toolbox. See the personal page of [Andrew McHutchon](http://mlg.eng.cam.ac.uk/?portfolio=andrew-mchutchon).
* For chapter 5: the SONIG toolbox. I developed this one myself, but it has [its own GitHub page](https://github.com/HildoBijl/SONIG).

All other support code (the Tools and the PitchPlunge system) have been coded by myself and have not been uploaded like this anywhere else before.

## Feedback

I am always curious where the stuff that I make winds up, so if you find this source code useful, send me a message. (You can find [contact information](http://hildobijl.com/Contact.php) on my [personal web page](http://hildobijl.com/).)

Oh, and if you find an error anywhere, then this should of course also be fixed so others aren't bothered by it. I will help fix errors in any way I can.
