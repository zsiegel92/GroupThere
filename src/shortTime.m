function [minTime,order] = shortTime(possibleGroup,seats,timeLimit)
global dists;
global routeAdder;

groupLength = length(possibleGroup);
referenceIndices = zeros(1,max(possibleGroup));
referenceIndices(possibleGroup)=1:groupLength;



%possibleGroup is the indices of the people involved in the group.
%seats and timeLimit are the number of seats those people have, and their
%time restrictions



permus = zeros(factorial(groupLength-1),groupLength);

%eligibleCars = possibleGroup(find(seats(possibleGroup)>=groupLength)); %Person
%indices

eligibleCars = (seats >=groupLength); %Indices in possibleGroup
[~,inds] = sort(eligibleCars,'descend');
possibleGroup = possibleGroup(inds);%put drivers first;
timeLimit = timeLimit(inds);
numDrivers = sum(eligibleCars);
%possibleGroup(1:numDrivers) consists of the group members whose cars can
%accommodate the group

minTime = inf;
order = [];



for k = 1:numDrivers
    %generate distance tuples for driver k
    possibleGroup([1,k]) = possibleGroup([k,1]);
    timeLimit([1,k]) = timeLimit([k,1]);
    
    permus = [repmat(possibleGroup(1),size(permus,1),1),perms(possibleGroup(2:end))];
    timepermus = [repmat(timeLimit(1),size(permus,1),1),perms(timeLimit(2:end))];
    
    
    distinds = distIndices(groupLength,permus);
    
    
    
    
    timedistances = dists(distinds);
    totTime = timedistances*(1:groupLength)'; %Driver is the only one to travel first leg, 2nd person is only person to travel 2nd leg, etc.
    
    
    
    [~,inds] = sort(totTime);
    
    i=1;
    %     disp('hello')
    %     timeLimit
    %     permus(inds(i),:)
    %     referenceIndices(permus(inds(i),:))
    %     timeLimit(referenceIndices(permus(inds(i),:)))
    %     timedistances(inds(i),:)
    while(i <= length(inds) && totTime(inds(i))<minTime)
%         if(length(possibleGroup)>2)
%             disp([num2str(size(routeAdder{groupLength})), ', ', num2str(size(timedistances(inds(i),:)')), ', ', num2str(size(timeLimit(1:end-1)'))])
%             disp(num2str((routeAdder{groupLength})*timedistances(inds(i),:)'))
%             disp(' <= ')
%             disp(num2str(timeLimit(1:end-1)'))
%         end
        %         if ((routeAdder{groupLength})*timedistances(inds(i),:)' <= timeLimit(1:end-1)')
        if ((routeAdder{groupLength})*timedistances(inds(i),:)' <= timepermus(inds(i),:)')
            minTime =totTime(inds(i));
            order = permus(inds(i),:);
            break
        end
        %evaluate distance tuples for minimality and time-feasibility
        i = i +1;
    end
    
    
end


%% List infeasible Groups
% if (minTime == inf)
%     disp(['Group: [',  num2str(possibleGroup), '] is infeasible.'])
% end
end