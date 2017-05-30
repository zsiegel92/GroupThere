function [] = GroupThereMail(params,solution,mailParam,liveVariable)
instructions = solution.instructions;
departures = solution.departures;
arrivals = solution.arrivals;

sender = mailParam.sender;
eventDate = mailParam.eventDate;
eventTime = mailParam.eventTime;
eventName = mailParam.eventName;
eventLocation= mailParam.eventLocation;
eventContact = mailParam.eventContact;
eventEmail = mailParam.eventEmail;
eventHostOrg = mailParam.eventHostOrg;
signature = mailParam.signature;

knownAccounts = {<YOUR EMAIL>};
knownPasswords = {<YOUR PASSWORD};
psswd = knownPasswords(find(strcmp(sender,knownAccounts)));

if (liveVariable == 0)
    params.Emails = cellfun(@(x) sender,params.Emails,'UniformOutput',0);
end



subject = ['Carpooling information for ', eventName, ' ', eventDate, ', ' eventTime, ', @ ',eventLocation];


global dists
[~,~,~,h,mn,~] = datevec(eventTime); %== [15,30]

times = [];
for k = 2:length(params.Name)
    plan = find(cellfun(@(x) ismember(k,x),instructions));
    if isempty(plan)
        command = ['Sorry, ', params.Name{k},', nobody can give you a ride to this event.'];
        addressEmailTable =[];
    else
        placeInLine = find(instructions{plan}==k,1);

        command= [params.Name{instructions{plan}(1)}];
        if length(instructions{plan})==1
            times = round(dists(instructions{plan}(1),1).*60);
            command = [command, ', you will drive alone to ', eventLocation ,', which takes ', num2str(times(1)), ' minutes. Leave by ',departures{plan}{1},'.'];
        else
            j=2;
            times(1) = round(dists(instructions{plan}(1),instructions{plan}(2)).*60);
            command = [command, ' picks up ',params.Name{instructions{plan}(j)}, ' at ', departures{plan}{2}, ', which takes ',num2str(times(1)), ' minutes;'];
            for j = 3:length(instructions{plan})
                times(j-1) = round(dists(instructions{plan}(j-1),instructions{plan}(j)).*60);
                command = [command, ' then ', params.Name{instructions{plan}(j)}, ' at ', departures{plan}{j}, ', which takes ',num2str(times(j-1)), ' minutes;'];
            end
            command = command(1:end-1);
            times(length(times)+1)=round(dists(instructions{plan}(end),1).*60);
            command = [command,'. Then, all head to ', eventLocation,', which takes ', num2str(times(end)),' minutes.'];
            command = sprintf('%s\n',command);
            command = sprintf('%s\n',command);
            if placeInLine~=1
                command = [command,  params.Name{instructions{plan}(1)}, ' leaves by ',departures{plan}{1},'.'];
                command = sprintf('%s\n',command);
                command = [command, 'You (', params.Name{instructions{plan}(placeInLine)},') need to be ready by ', departures{plan}{placeInLine},'.'];
            else
                command = [command,  'You (', params.Name{instructions{plan}(1)}, ') need to leave by ',departures{plan}{1},'.'];
            end

            command = sprintf('%s\n',command);
            command = [command, 'You will (all) arrive at ', eventLocation,' at ', arrivals{plan}{1},'.'];

        end
        addressEmailTable =[];
        for j = 1:length(instructions{plan})
            addressEmailTable = [addressEmailTable, sprintf('%s\n',[params.Name{instructions{plan}(j)},': ', params.Emails{instructions{plan}(j)}, ', ', params.Address{instructions{plan}(j)}])];
        end
    end

    addressEmailTable = sprintf('%s\n',addressEmailTable);
    addressEmailTable = [addressEmailTable, sprintf('%s\n',['Event Location: ', eventLocation])];
    addressEmailTable = [addressEmailTable, sprintf('%s\n',['Event Address: ', params.Address{1}])];
    addressEmailTable = [addressEmailTable, sprintf('%s\n',['Event Contact: ', eventContact])];
    addressEmailTable = [addressEmailTable, sprintf('%s\n',['Email: ', eventEmail,' for more information.'])];
    addressEmailTable = sprintf('%s\n',addressEmailTable);
    addressEmailTable = [addressEmailTable, sprintf('%s\n',['To request a different carpool, please email ', sender, ' for more information.'])];


    message = sprintf('%s\n\n',['Hi ',params.Name{k},',']);
    message = [message,sprintf('%s\n\n','Here is your personalized travel plan:')];
    message = [message,sprintf('%s\n\n',command)];

    message = [message, sprintf('%s\n\n',addressEmailTable)];

    message = [message,sprintf('%s\n\n','Sincerely,'),eventHostOrg];

    message = sprintf('%s\n',message);

    message = [sprintf('%s\n',message), signature];

    matlabmail(params.Emails{k}, message, subject, sender, psswd);
    times = [];
end

%datetime(0,0,0,15,30,0,'Format','hh:mm') == 3:30
%[~,~,~,h,mn,~] = datevec('3:30 PM') %== [15,30]

end


