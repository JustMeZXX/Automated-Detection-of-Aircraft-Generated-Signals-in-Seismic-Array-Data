function assignmentMatrix = findSegmentAssociation(scoreMatrix, threshold)

gtNum = size(scoreMatrix,1);
detNum = size(scoreMatrix,2);
assignmentMatrix = zeros(gtNum,detNum);
[currentScore, idxMax] = max(scoreMatrix(:));

while(currentScore ~= 0)
  
    [gtmax,detmax] = ind2sub(size(scoreMatrix),idxMax);
    
    scoreMatrix(gtmax,detmax) = 0;
  
    if currentScore >= threshold
        scoreMatrix(gtmax,:) = 0;
        scoreMatrix(:,detmax) = 0;
        assignmentMatrix(gtmax,detmax) = 1;
    end
    
    [currentScore, idxMax] = max(scoreMatrix(:));
        
 
end