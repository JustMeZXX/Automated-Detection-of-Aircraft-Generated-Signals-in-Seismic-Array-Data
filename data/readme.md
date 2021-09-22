### Dataset
The dataset used in this paper can be downloaded from: [Dataset](https://smu.box.com/s/f6ixzgd6zmzf78i3p0zunfqv0tm8zwfb). 

The dataset consists of training, validation, and test, which are created from Julian day 135 to 152 of 2014. Since a modified four-fold time series cross-validation was applied in the experiments, the random-split training and validation sets along with the test set under different seismic stations (R2120, R2308, R3514, R5819, R6005) are respectively saved as zip files under the different folder for each fold split (fold_01, fold_02, fold_03, fold_04) for easy manipulation. 

The pre-trained ResNet-18 models for five different seismic stations for each of the four fold splits are saved as .pt files in folder "./checkpoints". 

The processed ground truth for each of the four fold splits (two days within one fold) are saved as .mat files in folder "./labels".

To save time in running the system on the test sets, the pre-calculated output probabilities of ResNet-18 model for each of the seismic station at each fold split are saved as .mat files in folder "./prob". 
