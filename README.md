# ZMW Analysis Platform (ZAP)

## DEVELOPMENT ON THIS PLATFORM HAS CEASED. USE AT YOUR OWN RISK. RECOMMENDED SOFTWARE AT: https://github.com/David-Scott-White/cosmos-toolbox

### Overview

Matlab build of an analysis platform and GUI for single-molecule imaging experiments of ligand binding using zero-mode waveguides (ZMWs). This repository integrates a variety of software written during my PhD work at the University of Wisconsin Madison. Primary features of the platform (will) include: 

* **Image Mask Creator**
    * create thresholded image masks to localize single-molecules in TIFF images 


* **Time Series Creator**
    * create time-series of intensity values at each localized single-molecule over a stack of TIFF images
    
    
* **Time Series Idealization**
    * integration of my recently published [DISC algorithm](https://elifesciences.org/articles/53357) for unsupervised identification of states and transitions in a given time series using top-down machine learning. 
    * DISC can also be found at: https://github.com/ChandaLab/DISC
    
    
* **Analysis**
    * General analysis of idealized time series including dwell time analysis, state occupancy analysis, bleach-step analysis, and exporting to QuB for more advanced hidden Markov modeling. 
    
    
### Acknowledgments 
This project would not be possible without the support of both Dr. Baron Chanda and Dr. Randall H. Goldsmith at UW-Madison. I also thank Dr. Marcel Goldschen-Ohm and Owen Rafferty for contributing to early code. My thesis work was supported by the NIH grants to B.C (NS-101723, NS-081320, and NS-081293), D.S.W (T32 fellowship GM007507) and R.H.G. (GM127957).
