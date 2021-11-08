# Automated-Detection-of-Aircraft-Generated-Signals-in-Seismic-Array-Data

This repo is the official implementation for the our paper [A Data-Driven Framework for Automated Detection of Aircraft-Generated Signals in Seismic Array Data Using Machine Learning](https://pubs.geoscienceworld.org/ssa/srl/article-abstract/doi/10.1785/0220210198/609341/A-Data-Driven-Framework-for-Automated-Detection-of)

### Demo
The demo is provided in [demo](https://github.com/JustMeZXX/Automated-Detection-of-Aircraft-Generated-Signals-in-Seismic-Array-Data/tree/main/demo), please follow the instructions in demo.m to start the detection system. As a prerequisite, please download and add [functions](https://github.com/JustMeZXX/Automated-Detection-of-Aircraft-Generated-Signals-in-Seismic-Array-Data/tree/main/code/functions) to the MATLAB path before running the system. 

### Dataset
The dataset is uploaded in [dataset](https://github.com/JustMeZXX/Automated-Detection-of-Aircraft-Generated-Signals-in-Seismic-Array-Data/tree/main/data), please follow the readme file to get access to the data.

### Code
The code is released in [code](https://github.com/JustMeZXX/Automated-Detection-of-Aircraft-Generated-Signals-in-Seismic-Array-Data/tree/main/code). The code implemented for this study consists of three parts: data preparation (data_prep), modeling training and test (model_py), and decision fusion and system evaluation (fusion_and_eval). 

### Bibtex
If you find our work useful for your research, please consider citing:

    @article{10.1785/0220210198,
      author = {Zhang, Xinxiang and Arrowsmith, Stephen and Tsongas, Sotirios and Hayward, Chris and Meng, Haoran and Ben‐Zion, Yehuda},
      title = {A Data‐Driven Framework for Automated Detection of Aircraft‐Generated Signals in Seismic Array Data Using Machine Learning},
      journal = {Seismological Research Letters},
      year = {2021},
      month = {11},
      issn = {0895-0695},
      doi = {10.1785/0220210198},
      url = {https://doi.org/10.1785/0220210198},
      eprint = {https://pubs.geoscienceworld.org/ssa/srl/article-pdf/doi/10.1785/0220210198/5456137/srl-2021198.1.pdf}}
      
### Acknowledge
Part of our code in functions is referred from [MATLAB Central](https://www.mathworks.com/matlabcentral/fileexchange/24254-interval-merging). We thank Bruno Luong for releasing the codes.
