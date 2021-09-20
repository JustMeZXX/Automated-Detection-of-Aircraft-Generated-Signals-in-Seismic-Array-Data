% This script shows a simple demonstration for the automated aircraft 
% detection system at day 145 using all five seismic stations

% The probability of each station is pre-saved, which can be obtained by
% running model_test.py on the test data of day 145, where the pre-trained
% ResNet-18 model is obtained by runnding model_training.py on the its 
% training and validation data within the the same fold

% The ground truth is also pre-saved, and can be obtained by running 
% prep_ground_truth.m on day 145

% Input: pre-saved probablily (.mat file) for each station at day 145;
%        pre-saved process ground truth labels at day 145
% Output: Precision, Recall, and F-score

clc;clear;close all

window_length = 100;
num_stations = 5;
threshold = 0.5; % IoU for evaluation

load('prob_R2120_145.mat')
prob_R2120 = prob;
load('prob_R2308_145.mat')
prob_R2308 = prob;
load('prob_R3514_145.mat')
prob_R3514 = prob;
load('prob_R5819_145.mat')
prob_R5819 = prob;
load('prob_R6005_145.mat')
prob_R6005 = prob;

load('labels_145.mat')
label_segment(:,3) = abs(label_segment(:,1)-label_segment(:,2));
label_segment = label_segment(label_segment(:,3) > window_length-1, 1:2);

% majority voting across windows (CWFS)
decision_output_R2120 = CWFS(prob_R2120,windows_loc);
decision_output_R2308 = CWFS(prob_R2308,windows_loc);
decision_output_R3514 = CWFS(prob_R3514,windows_loc);
decision_output_R5819 = CWFS(prob_R5819,windows_loc);
decision_output_R6005 = CWFS(prob_R6005,windows_loc);

% majority voting across stations (CSFS)
decision_output_sum = decision_output_R2120 + decision_output_R2308 + decision_output_R3514 + decision_output_R5819 + decision_output_R6005;
decision_output = decision_output_sum >= ceil((num_stations+1)/2);

% find detection segments with binary 1
detection_segment = [];
detection_positive_index = find(diff(decision_output')==1) + 1;

for i = 1:length(detection_positive_index)
    
    index_start_cur = detection_positive_index(i);
    index_start_cur_temp = index_start_cur;
    
    while decision_output(index_start_cur_temp) == 1 && index_start_cur_temp < 86401
        index_start_cur_temp = index_start_cur_temp + 1;
    end
    index_end_cur = index_start_cur_temp - 1;
    
    index_cur = [index_start_cur,index_end_cur];
    
    detection_segment = [detection_segment;int32(index_cur)];
end

if ~isempty(detection_segment)
    detection_length = abs(detection_segment(:,1)-detection_segment(:,2));
    detection_segment = detection_segment(detection_length > window_length-1,:);
end

% Precision, Recall, and F-score
[evals,outputs] = evaluateSegment(label_segment,detection_segment,threshold);

