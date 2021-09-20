% This script is used to prepare spectral samples (training + validation)
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

% we iterate 20 days from May 14 to Jun 02 for example,
% Julian day table of non-leap years is as below:
% http://uop.whoi.edu/UOPinstruments/frodo/aer/julian-day-table.html

num_days = 20; % number of days for training
start_day_index = 6; % index of start date
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

% sliding window iteration
% picked days: May 14 - Jun 02 (20 consecutive days)
% picked stations: R2120, R2308, R3514, R5819, R6005

date_string_initial = {'2014-01-01 00:00:00.00'};
t_initial = datenum(date_string_initial);

% parameters for sliding window
window_length = 100/86400; % 100s
step = window_length/20; % 5s
threshold = 0.3;

% parameters for STFT
window = 512;
nfft = 512;
noverlap = 256;

start_date = GT_days(1,1) - 1;
end_date = GT_days(end,1) - 1;

s = RandStream('mlfg6331_64'); % random stream for reproducibility

sample_rate = 8; % pick one negative sample every 8 (for data balance)

count_negative = 0;
count_positive_valid = 0;
count_negative_valid = 0;

error_count = 0;

for i = start_date: step: (end_date + 1) - window_length % + 1 means we need to count the last day as well
    window_start_cur = i;
    window_end_cur = i + window_length;
    
    t_start_cur = t_initial + window_start_cur;
    t_end_cur = t_initial + window_end_cur;
    
    t_start_string = datestr(datetime(t_start_cur,'ConvertFrom','datenum'));
    t_end_string = datestr(datetime(t_end_cur,'ConvertFrom','datenum'));
    
    window_cur_absolute = [window_start_cur + 1, window_end_cur + 1];
    
    % find overlap with labeled GTs
    [l,r] = RangeIntersection(window_cur_absolute(:,1),window_cur_absolute(:,2),window_GT_absolute_sort_merged(:,1),window_GT_absolute_sort_merged(:,2));
    overlap_intervals = [l(:), r(:)];
    
    if ~isempty(overlap_intervals)
        
        % For current window has overlap with any GT:
        % if the overlap is larger than the pre-defined threshold,
        % we move the spectrogram of current window to positive category;
        % otherwise we move them to negtive category
        
        overlap_abs_length = abs(overlap_intervals(:,1)-overlap_intervals(:,2));
        overlap_abs_ratio = max(overlap_abs_length)/abs(window_cur_absolute(1)-window_cur_absolute(2));
        
        if overlap_abs_ratio >= threshold
            count_positive_valid = count_positive_valid + 1;
            
            try
                traces = irisFetch.Traces('ZG','R2120','*','DPZ',t_start_string,t_end_string); % use R2120 for example
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
                
                save_name = sprintf('R2120_P_%03d_%06d_5s',int32(floor(window_cur_absolute(1))),int32(count_positive_valid));
                saveas(gcf,save_name,'png')
                close all
                
            catch ME
                count_positive_valid = count_positive_valid - 1;
                
                error_count = error_count + 1;
                error_message{error_count} = ME;
                error_windows(error_count,:) = window_cur_absolute;
            end
            
        else
            count_negative = count_negative + 1;
            count_negative_valid = count_negative_valid + 1;
            
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
                
                save_name = sprintf('R2120_N_%03d_%06d_5s',int32(floor(window_cur_absolute(1))),int32(count_negative_valid));
                saveas(gcf,save_name,'png')
                close all
                
            catch ME
                count_negative = count_negative - 1;
                count_negative_valid = count_negative_valid - 1;
                
                error_count = error_count + 1;
                error_message{error_count} = ME;
                error_windows(error_count,:) = window_cur_absolute;
            end
        end
    else
        % For current window doesn't have overlap with any GT:
        % we randomly pick some samples to make two categories balanced
        
        count_negative = count_negative + 1;
        random_num = randi(s, [0 sample_rate-1]);
        
        if mod(count_negative, sample_rate) == random_num
            
            count_negative_valid = count_negative_valid + 1;
            
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
                
                save_name = sprintf('R2120_N_%03d_%06d_5s',int32(floor(window_cur_absolute(1))),int32(count_negative_valid));
                saveas(gcf,save_name,'png')
                close all
                
            catch ME
                count_negative = count_negative - 1;
                count_negative_valid = count_negative_valid - 1;
                
                error_count = error_count + 1;
                error_message{error_count} = ME;
                error_windows(error_count,:) = window_cur_absolute;
            end
        end
    end
end

save('error_windows_R2120_training.mat','error_message','error_windows') % save the error message in fetching if needed

