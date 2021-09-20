% This script is used to split saved samples to training and validation
% The split ratio can be changed by identifying different "percentage"

mkdir 'your_file_for_saving_the_training_samples';
mkdir 'your_file_for_saving_the_validation_samples';
clc;clear;close all

s = RandStream('mlfg6331_64'); % random stream for reproducibility
percentage = 0.8;

Folder = 'path to your saved samples';
DestTrain = 'your_file_for_saving_the_training_samples';
DestValid = 'your_file_for_saving_the_validation_samples';

FileList = dir(fullfile(Folder, '*.png')); % can be other formats

numTrain = floor(numel(FileList) * percentage);
numValid = numel(FileList) - numTrain;

IndexAll = 1:numel(FileList);
IndexTrain = randperm(s, numel(FileList), numTrain);
IndexValid = setdiff(IndexAll, IndexTrain);

for i = 1:numTrain
    Source = fullfile(Folder, FileList(IndexTrain(i)).name);
    copyfile(Source, DestTrain);
end

for j = 1:numValid
    Source = fullfile(Folder, FileList(IndexValid(j)).name);
    copyfile(Source, DestValid);
end

