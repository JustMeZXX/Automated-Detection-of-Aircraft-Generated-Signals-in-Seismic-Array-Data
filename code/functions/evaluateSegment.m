function [evals,outputs] = evaluateSegment(ground_truth_all,result_all,threshold)

falseneg = 0;
falsepos = 0;
gt = 0;

ground_truth = ground_truth_all;
result = result_all;

gt = gt + size(ground_truth,1);

% check corner case
if isempty(ground_truth)
    
    falsepos = falsepos + size(result,1);
    outputs.falsepos = falsepos;
    
elseif isempty(result)
    
    falseneg = falseneg + size(ground_truth,1);
    outputs.falseneg = falseneg;
    
end

% calculate pair-wise distance matrix
score = [];
for ii = 1:size(ground_truth,1)
    for jj = 1:size(result,1)
        ground_truth_cur = ground_truth(ii,:);
        result_cur = result(jj,:);
        
        [l,r] = RangeIntersection(ground_truth_cur(1),ground_truth_cur(2),result_cur(1),result_cur(2));
        overlap_interval = [l(:), r(:)];
        
        if ~isempty(overlap_interval)
            
            inter_cur = abs(overlap_interval(2)-overlap_interval(1));
            union_cur = double(abs(max([ground_truth_cur(2),result_cur(2)])-min([ground_truth_cur(1),result_cur(1)])));
            iou_cur = inter_cur/union_cur;
            
            score(ii,jj) = iou_cur;
        else
            score(ii,jj) = 0;
        end
        
    end
    
end

assignment = findSegmentAssociation(score, threshold);

for i = 1: size(assignment,1)
    if sum(assignment(i,:)) == 0
        falseneg = falseneg + 1;
    end
end

for c = 1: size(assignment,2)
    if sum(assignment(:,c)) == 0
        falsepos = falsepos + 1;
    end
end

truepos = size(ground_truth,1) - falseneg;

outputs.truepos = truepos;
outputs.falseneg = falseneg;
outputs.falsepos = falsepos;

if (truepos + falseneg) ~= size(ground_truth,1)
    disp('***** Watch out sum of annotations is not valid with TP+FN *****');
end


evals.rateFN = falseneg/gt;
evals.rateTP = truepos/gt;
evals.rateFP = falsepos/gt;
evals.TP = truepos;
evals.FN = falseneg;
evals.FP = falsepos;

evals.precision = truepos / (truepos + falsepos);
evals.recall = truepos / (truepos + falseneg);
evals.Fscore = 2*(evals.precision*evals.recall)/(evals.precision+evals.recall);

end
