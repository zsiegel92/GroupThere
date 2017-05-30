%USE SPARSE MATRIX FOR A IF MORE THAN 25 PEOPLE!
function [f,A,b,orders] = genConstraints(n,groups,groupTimes,groupOrder)
f= [];
b=[];
A = [];
orders = {};
for k = 1:length(groups)
    f = [f;groupTimes{k}];
    A = [A; cell2mat(cellfun(@(x) ismember(2:n,x),num2cell(groups{k},2),'UniformOutput',0))];
    orders = [orders;num2cell(groupOrder{k},2)];
end


A = A';
b = ones(size(A,1),1);
f=f';










end