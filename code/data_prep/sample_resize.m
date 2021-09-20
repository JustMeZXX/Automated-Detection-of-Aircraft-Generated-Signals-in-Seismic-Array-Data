% This script is used to resized the samples to match ResNet-18 input size

% Input: path to the source samples (unresized)
% Output: the resized spectrogram images are saved to the destinate file

mkdir 'your_file_for_saving_the_resized_samples';
cd 'your_file_for_saving_the_resized_samples'
clc;clear;close all

% read images
path = 'path to your unresized samples';
files = fullfile(path, '*.png'); % can be other formats
dir = dir(files);

for i = 1:length(dir)

    cur_address = [dir(i).folder,'\',dir(i).name];
    cur_img = imread(cur_address);
    
    cur_img_resized = imresize(cur_img,[224,224]);
    
    imwrite(cur_img_resized,dir(i).name) % save as the current name
end

