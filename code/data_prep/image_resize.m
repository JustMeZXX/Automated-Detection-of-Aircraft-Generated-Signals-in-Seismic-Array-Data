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












cd 'D:\seismology_acoustic\cross_validation\fold_01_134_143\testing_v2\R2308\test_resized'
clc;clear;close all

%% read images
path = 'E:\seismology_acoustic\training_samples_5s_4_9_2021\R2308_test\145';
files = fullfile(path, '*.png');
dir = dir(files);

for i = 1:length(dir)
    
    i
    cur_address = [dir(i).folder,'\',dir(i).name];
    cur_img = imread(cur_address);
    
    cur_img_resized = imresize(cur_img,[224,224]);
    
    imwrite(cur_img_resized,dir(i).name)
end












cd 'D:\seismology_acoustic\cross_validation\fold_01_134_143\testing_v2\R3514\test_resized'
clc;clear;close all

%% read images
path = 'E:\seismology_acoustic\training_samples_5s_4_9_2021\R3514_test\145';
files = fullfile(path, '*.png');
dir = dir(files);

for i = 1:length(dir)
    
    i
    cur_address = [dir(i).folder,'\',dir(i).name];
    cur_img = imread(cur_address);
    
    cur_img_resized = imresize(cur_img,[224,224]);
    
    imwrite(cur_img_resized,dir(i).name)
end












cd 'D:\seismology_acoustic\cross_validation\fold_01_134_143\testing_v2\R5819\test_resized'
clc;clear;close all

%% read images
path = 'D:\seismology_acoustic\test_for_two_stations_4_26_2021\R5819\145';
files = fullfile(path, '*.png');
dir = dir(files);

for i = 1:length(dir)
    
    i
    cur_address = [dir(i).folder,'\',dir(i).name];
    cur_img = imread(cur_address);
    
    cur_img_resized = imresize(cur_img,[224,224]);
    
    imwrite(cur_img_resized,dir(i).name)
end












cd 'D:\seismology_acoustic\cross_validation\fold_01_134_143\testing_v2\R6005\test_resized'
clc;clear;close all

%% read images
path = 'D:\seismology_acoustic\test_for_two_stations_4_26_2021\R6005\145';
files = fullfile(path, '*.png');
dir = dir(files);

for i = 1:length(dir)
    
    i
    cur_address = [dir(i).folder,'\',dir(i).name];
    cur_img = imread(cur_address);
    
    cur_img_resized = imresize(cur_img,[224,224]);
    
    imwrite(cur_img_resized,dir(i).name)
end
