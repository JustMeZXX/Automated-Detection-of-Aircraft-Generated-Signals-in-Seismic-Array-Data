function decision_output = CWFS(prob,windows_loc)

state = [prob(:,1) >= prob(:,2), windows_loc];

decision_count = zeros(86401,1);
decision = zeros(86401,1);

for k = 1:size(state,1)
    
    decision_count(state(k,2)+1:state(k,3)+1) = decision_count(state(k,2)+1:state(k,3)+1) + 1;
    
    if state(k,1) == 1

        decision(state(k,2)+1:state(k,3)+1) = decision(state(k,2)+1:state(k,3)+1) + 1;
    end
end

decision_ratio = decision./decision_count;
decision_output = decision_ratio(:,1) > 0.5;

end

