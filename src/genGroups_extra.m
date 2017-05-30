function RouteParams = genGroups_extra(seats,timeLimit,extra,extraWindow)
% extraWindow = .5; %Extra half hour for those who don't need to arrive by 7:30

%seats is an integer vector whose length is the number of people +1, as is
%timeLimit, as is extra. So, the 2:length(seats) entries of seats,
%timeLimit, and extra correspond to people.
global dists;
global sub2indMAT;
sub2indMAT = zeros(size(dists));
for i = 1:size(dists,1)
    for j = 1:size(dists,2)
        sub2indMAT(i,j)=sub2ind(size(dists),i,j);
    end
end



n = length(seats)-1;
drivers{1} = find(seats>0);
drivers{2} = find(seats>1);
drivers{3} = find(seats>2);
drivers{4}= find(seats>3);
drivers{5} = find(seats>4);

people = 2:(n+1);

%NOTE: location 1 (row/col 1 in global dists) is the final destination!
%So, there are length(seats)-1 people
%alternatively, there are length(timeLimit)- 1 people
%there are
global routeAdder;
% routeAdder{i} = triu(ones(i,i));
routeAdder{1} = 1;
routeAdder{2} = [1,1;0,1];
routeAdder{3} = [1,1,1;0,1,1;0,0,1];
routeAdder{4} = [1,1,1,1;0,1,1,1;0,0,1,1;0,0,0,1];
routeAdder{5} = [1,1,1,1,1;0,1,1,1,1;0,0,1,1,1;0,0,0,1,1;0,0,0,0,1];


groups = cell(1,4);

%% Choose groups of size 1
groups{1} = find(seats>0);
groupTimes{1} = arrayfun(@(x) dists(x,1),groups{1});
groupOrder{1} = groups{1};



%% Choose groups of size 2:4
for k = 2:max(seats)
groups{k} = nchoosek(people,k);

noDrivers =find((cell2mat(cellfun(@(x) ismember(people,x),num2cell(groups{k},2),'UniformOutput',0)))*double(seats(2:end)>0)==0);
groups{k}(noDrivers,:)=[];


[groupTimes{k},groupOrder{k}] = cellfun(@(x) shortTime(x,seats(x),timeLimit(x) + prod(extra(x))*extraWindow),num2cell(groups{k},2),'UniformOutput',0);

groupTimes{k} = cell2mat(groupTimes{k});
infeas{k} = find(groupTimes{k} == Inf);
groups{k}(infeas{k},:)=[];
groupTimes{k}(infeas{k})=[];
groupOrder{k}(infeas{k}) = [];
groupOrder{k} = cell2mat(groupOrder{k});
end


% disp(['Total number of people: ',num2str(n)]);
% disp(['Total number of drivers: ', num2str(nnz(seats))]);
% for k = 1:max(seats)
%     disp(['Groups of size: ', num2str(k)]);
%     disp([num2str(n),' choose ', num2str(k),' is ',num2str(nchoosek(n,k))]);
%     disp(['Number groups of size ', num2str(k),': ', num2str(size(groups{k},1))]);
% end
% save('sofar')

RouteParams.groups = groups;
RouteParams.groupTimes = groupTimes;
RouteParams.groupOrder = groupOrder;




end
