% This script is used to read ground truth from .txt file to Matlab vector
% The vector is recored as second-wise, starting from 1s to 86401s (a day)
% The overlaps between different labeled aircraft events are merged

% Input: path to the ground truth text files
% Output: label_segment (two-columns vector with start and end time)

clc;clear;close all

% read GTs between start and end days
path = 'path to your ground truth text files';
files = fullfile(path, '*.txt');
dir = dir(files);

num_days = 1; % number of test days
start_day_index = 17; % index of start date (index 17: day 145)
end_day_index = start_day_index + num_days - 1; % index of end date

count_days = 0;
GT = [];
for i = start_day_index: end_day_index
    count_days = count_days + 1;
    
    fr = fileread(dir(i).name);
    matches = regexp(fr, '[^\n]*', 'match');
    
    count = 0;
    GT_cur = [];
    for num_rows = 2:size(matches,2)
        str_cur = strsplit(matches{num_rows});
        if str_cur{5} == 'A' % only use labels with high confidence
            count = count + 1;
            
            time_length = abs(str2double(str_cur{3})-str2double(str_cur{4}));
            
            GT_cur(count,1:4) = [str2double(str_cur{2}), str2double(str_cur{3}),str2double(str_cur{4}),time_length];
            
            GT_cur(count, 5:6) =...
                [str2double(str_cur{2}) + str2double(str_cur{3})/86400,...
                str2double(str_cur{2}) + str2double(str_cur{4})/86400];
        end
    end
    GT = [GT;GT_cur]; % unmerged GT
end

% merge overlaps
[GT_days, window_GT_absolute_sort_merged] = MergeOverlapsGT(GT);

start_date = GT_days(1,1) - 1;
end_date = GT_days(end,1) - 1;

decision_labels = zeros(86401,1);
for k = 1:size(window_GT_absolute_sort_merged,1)
    
    window_cur_GT_absolute = window_GT_absolute_sort_merged(k,:);
    
    cur_GT_in_sec = int32(86400 * (window_cur_GT_absolute - start_date - 1));
    
    decision_labels(cur_GT_in_sec(1)+1:cur_GT_in_sec(2)+1) = decision_labels(cur_GT_in_sec(1)+1:cur_GT_in_sec(2)+1) + 1;
    
end

decision_labels = logical(decision_labels);

% find and output label segment
label_segment = []; 
label_index = find(diff(decision_labels')==1) + 1; 

for i = 1:length(label_index)
    
    index_start_cur = label_index(i);
    index_start_cur_temp = index_start_cur;
    
    while decision_labels(index_start_cur_temp) == 1
        index_start_cur_temp = index_start_cur_temp + 1;
    end
    
    index_end_cur = index_start_cur_temp - 1;
    
    index_cur = [index_start_cur,index_end_cur];
    
    label_segment = [label_segment;int32(index_cur)];
end

windows_loc = [(0:5:86400-100)',(100:5:86400)'];

save('labels_145.mat','windows_loc','label_segment') % same as .mat file if needed

