function [ground_truth_days,ground_truth_merged_sort_merged] = MergeOverlapsGT(ground_truth_all_unmerged)

ground_truth_all_unmerged_sort = sortrows(ground_truth_all_unmerged,5);

ground_truth_days = ground_truth_all_unmerged_sort(:,1);

ground_truth_unmerged_sort = ground_truth_all_unmerged_sort(:,5:6);

ground_truth_merged_sort_merged = ground_truth_unmerged_sort(1,:);

for i = 2:size(ground_truth_unmerged_sort,1)
    
    cur_ground_truth_sort = ground_truth_unmerged_sort(i,:);
    top_ground_truth_sort_merged = ground_truth_merged_sort_merged(end,:);
    
    if top_ground_truth_sort_merged(2) < cur_ground_truth_sort(1)
        ground_truth_merged_sort_merged = [ground_truth_merged_sort_merged;cur_ground_truth_sort];
        
    elseif top_ground_truth_sort_merged(2) < cur_ground_truth_sort(2)
        
        top_ground_truth_sort_merged(2) = cur_ground_truth_sort(2);
        
        ground_truth_merged_sort_merged = ground_truth_merged_sort_merged(1:end-1,:);
        ground_truth_merged_sort_merged = [ground_truth_merged_sort_merged;top_ground_truth_sort_merged];
        
    end
    
end

end

