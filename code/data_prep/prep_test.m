% This script is used to prepare spectral samples for test
% The start and end date of these samples are changed by identifying the
% "start_day_index" and "num_days" (depend on station availability)

% Since IRIS repository may throw random errors when fetching the data,
% we save these error messges at the end of this script for reference.

% Input: path to the ground truth text files
% Output: throwed error messages
%         the spectrogram images are automatically saved to the files

mkdir 'your_file_for_saving_the_samples';
cd 'your_file_for_saving_the_samples'
clc;clear;close all

% read GTs between start and end days
path = 'path to your ground truth text files';
files = fullfile(path, '*.txt');
dir = dir(files);

num_days = 1; % number of days for test
start_day_index = 15;
end_day_index = start_day_index + num_days - 1;

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
[GT_days, ~] = MergeOverlapsGT(GT);

% sliding window iteration
date_string_initial = {'2014-01-01 00:00:00.00'};
t_initial = datenum(date_string_initial);

% parameters for sliding window
window_length = 100/86400; % 100s
step = window_length/5; % 20s

% parameters for STFT
window = 512;
nfft = 512;
noverlap = 256;

start_date = GT_days(1,1) - 1;
end_date = GT_days(end,1) - 1;

error_count = 0;
count = 0;
labels = [];
for i = start_date: step: (end_date + 1) - window_length % + 1 means we need to count the last day as well
    
    count = count + 1;
    
    window_start_cur = i;
    window_end_cur = i + window_length;
    window_cur_absolute = [window_start_cur + 1, window_end_cur + 1];
    
    t_start_cur = t_initial + window_start_cur;
    t_end_cur = t_initial + window_end_cur;
    
    t_start_string = datestr(datetime(t_start_cur,'ConvertFrom','datenum'));
    t_end_string = datestr(datetime(t_end_cur,'ConvertFrom','datenum'));
    
    save_name = sprintf('R2120_test_%03d_%06d.png',int32(floor(window_cur_absolute(1))),int32(count));
    
    try
        traces = irisFetch.Traces('ZG','R2120','*','DPZ',t_start_string,t_end_string);
        [S,F,T] = spectrogram(traces.data,window,noverlap,nfft,traces.sampleRate);
        t_spec = T/86400 + traces.startTime;
        S_dB = log10(abs(S));
        
        % preprocessing
        mean_cols = mean(S_dB, 1);
        mean_rows = mean(S_dB, 2);
        
        for row = 1:size(S_dB,1)
            S_dB(row,:) = S_dB(row,:) - mean_rows(row);
        end
        for col = 1:size(S_dB,2)
            S_dB(:,col) = S_dB(:,col) - mean_cols(col);
        end
        
        S_dB = imgaussfilt(S_dB);
        
        % save
        imagesc(t_spec,F,S_dB);
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        set(gca,'Position',[0 0 1 1])
        
        saveas(gcf,save_name,'png')
        close all
        
    catch ME
        error_count = error_count + 1;
        error_message{error_count} = ME;
        error_windows(error_count,:) = window_cur_absolute;
        error_count_index(error_count) = count;
        
        % when error throwed, we create a blank spectrogram in place
        temp_img = zeros(656,875);
        imwrite(temp_img,save_name)
        
    end
end

if error_count ~= 0
    save('error_windows_R2120_test.mat','error_message','error_windows','error_count_index') % save the error message in fetching if needed
end

