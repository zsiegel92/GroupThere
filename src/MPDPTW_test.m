%Test Script
load('FullParams.mat');
global dists;
dists= (params.dist_mats.t)/40;



groups = genGroups(params.NumberCarSeats,params.HoursAvailableforTransit');

[f,A,b,orders] = genConstraints(length(dists),groups.groups,groups.groupTimes,groups.groupOrder);


x = linprog(f,[],[],A,b,zeros(size(f')),ones(size(f')));
x = round(x);

instructions = orders(find(x));



disp(['Total Travel Time: ', num2str(f*x),' person-hours']);

for i = 1:size(instructions,1)
    command= [params.Name{instructions{i}(1)}];
    j=2;
    if length(instructions{i})==1
        command = [command, ' drives alone.'];
    else
        command = [command, ' picks up ',params.Name{instructions{i}(j)}];
        for j = 3:length(instructions{i})
            command = [command, ', then ', params.Name{instructions{i}(j)}];
        end
        command = [command,'.'];
    end
    disp(command);
end
