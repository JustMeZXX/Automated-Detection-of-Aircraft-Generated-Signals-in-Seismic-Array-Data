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
start_day_index = 17; % index of start date
end_day_index = start_day_index + num_days - 1; % index of start date

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
        if str_cur{5} == 'A'
            count = count + 1;
            
            time_length = abs(str2double(str_cur{3})-str2double(str_cur{4}));
            
            GT_cur(count,1:4) = [str2double(str_cur{2}), str2double(str_cur{3}),str2double(str_cur{4}),time_length];
            
            GT_cur(count, 5:6) =...
                [str2double(str_cur{2}) + str2double(str_cur{3})/86400,...
                str2double(str_cur{2}) + str2double(str_cur{4})/86400];
        end
    end
    GT = [GT;GT_cur];
end

window_GT_absolute_all = GT; % unmerged GT

% merge overlaps
window_GT_absolute_all_sort = sortrows(window_GT_absolute_all,5);

GT_days = window_GT_absolute_all_sort(:,1);
window_GT_absolute_sort = window_GT_absolute_all_sort(:,5:6);

window_GT_absolute_sort_merged = window_GT_absolute_sort(1,:);
for i = 2:size(window_GT_absolute_sort,1)
    cur_window_GT_sort = window_GT_absolute_sort(i,:);
    top_window_GT_sort_merged = window_GT_absolute_sort_merged(end,:);
    
    if top_window_GT_sort_merged(2) < cur_window_GT_sort(1)
        window_GT_absolute_sort_merged = [window_GT_absolute_sort_merged;cur_window_GT_sort];
        
    elseif top_window_GT_sort_merged(2) < cur_window_GT_sort(2)
        top_window_GT_sort_merged(2) = cur_window_GT_sort(2);
        
        window_GT_absolute_sort_merged = window_GT_absolute_sort_merged(1:end-1,:);
        window_GT_absolute_sort_merged = [window_GT_absolute_sort_merged;top_window_GT_sort_merged];
        
    end
end

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


