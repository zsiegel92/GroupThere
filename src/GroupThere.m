%%Need to add:
% -Denote whether someone HAS to take their car.
% -Plan return trips in one pass to ensure nobody is stranded or return
% trips are highly sub-optimal


%% function [] = GroupThere(filename)
function [solution,params,mailParam] = GroupThere(filename)


%% Initializing parameters
mailParam.sender = <YOUR EMAIL>;
mailParam.eventDate = <EVENT DATE>;
mailParam.eventTime = <EVENT TIME>;
mailParam.eventName = <YOUR EVENT NAME>;
mailParam.eventLocation = <EVENT LOCATION NAME>;
mailParam.eventContact = <EVENT CONTACT PHONE NUMBER>;
mailParam.eventEmail = <EMAIL CONTACT FOR EVENT>;
mailParam.eventHostOrg = <HOST ORG>; %After "Sincerely,"
mailParam.signature = <SOMETHING GOOFY>;

[~,~,~,eventhour,eventminute,~] = datevec(mailParam.eventTime);

%% Reading/Interpreting Input
disp('Reading input.')
params = import_google_form_extra_real(filename); %The group destination is the first address listed.
% params = import_google_form(filename); %The group destination is the first address listed.

%% Distance Matrix
disp('Generating distance matrix.')
%  [dist_mats, coords] = Generate_Dist_Mat(params.Address);
% save('distParams_GoogleForm_realsofar.mat','dist_mats','coords');
% load('distParams_GoogleForm_realsofar.mat');
% save('distParams_36peopleTEST.mat','dist_mats','coords');
load('distParams_36peopleTEST.mat');
params.dist_mats = dist_mats;
params.coords = coords;
clear dist_mats coords;


global dists;
dists= (params.dist_mats.t);


%% Generating groups
disp('Generating feasible groups.')
% groups = genGroups(params.NumberCarSeats,params.HoursAvailableforTransit');
params.extraWindow= 0.5;
groups = genGroups_extra(params.NumberCarSeats,params.HoursAvailableforTransit',params.extra,params.extraWindow);

%% Generating constraints
disp('Generating constraint matrix.')
[f,A,b,orders] = genConstraints(length(dists),groups.groups,groups.groupTimes,groups.groupOrder);

%% Optimizing - linear programming
disp('Optimizing.')
% x = linprog(f,[],[],A,b,zeros(size(f')),ones(size(f')));
x = intlinprog(f,1:length(f),[],[],A,b,zeros(size(f')),ones(size(f')));
params.model.f = f;
params.model.A = A;
params.model.b = b;
params.model.orders=orders;
params.model.x = x;


x = round(x);



solution.instructions = orders(find(x));



%% Output
disp(['Total Travel Time: ', num2str(f*x),' person-hours']);

for i = 1:size(solution.instructions,1)
    % Figure out departure time!
    distind = dists(distIndices(length(solution.instructions{i}),solution.instructions{i}));
    % Check if extra arrival time is needed.
    if (any(triu(ones(length(solution.instructions{i})))*distind' >params.HoursAvailableforTransit(solution.instructions{i})))
        arr = max(triu(ones(length(solution.instructions{i})))*distind'-params.HoursAvailableforTransit(solution.instructions{i}));
        %arrival=amount of time after 7:30 that you arrive.
        deps = (arr - triu(ones(length(solution.instructions{i})))*distind');
        %departures = amount of time AFTER 7:30 that each person leaves.
        %Note that negative values imply times before 7:30.
    else
        %7:30 arrival
        arr = 0;
        deps = arr - triu(ones(length(solution.instructions{i})))*distind';
    end

    % Give commands
    command= [params.Name{solution.instructions{i}(1)}];
    j=2;
    if length(solution.instructions{i})==1
        command = [command, ' drives alone.'];
    else
        command = [command, ' picks up ',params.Name{solution.instructions{i}(j)}];
        for j = 3:length(solution.instructions{i})
            command = [command, ', then ', params.Name{solution.instructions{i}(j)}];
        end
        command = [command,'.'];
    end
    disp(command)
    solution.departures{i} = deps;
    solution.arrivals{i} = arr;

    solution.departures{i} = arrayfun(@(x) char(datetime(0,0,0,eventhour,eventminute+round(x*60),0,'Format','hh:mm')),solution.departures{i},'UniformOutput',0);
    solution.arrivals{i} = arrayfun(@(x) char(datetime(0,0,0,eventhour,eventminute+round(x*60),0,'Format','hh:mm')),solution.arrivals{i},'UniformOutput',0);
    disp(['First departure: ', char(datetime(0,0,0,eventhour,eventminute+round(deps(1)*60),0,'Format','hh:mm'))]);
    disp(['Arrival: ', char(datetime(0,0,0,eventhour,eventminute+round(arr*60),0,'Format','hh:mm'))]);
end

disp(sprintf('%s\n',''));

for k = 2:length(params.Name)
    plan = find(cellfun(@(x) ismember(k,x),solution.instructions));
    if isempty(plan)
        disp([params.Name{k},' does not have a ride!!']);
    end
end

clear i j command

save('FullInstructions_ifnotnow.mat');

liveparam = 0;
if liveparam == 1
    liveparam = 0;
    liveparam = (liveparam==1);
    liveparam = input('Are you sure you want to send mail? (1 or 0)');
    if (liveparam==1)
        disp('Sending mail to real people!');
    end
end
  GroupThereMail(params,solution,mailParam,liveparam);%Change 0 to 1 to go LIVE. Otherwise, all emails will be sent circularly to the sender (and forwarded to admin)
end



