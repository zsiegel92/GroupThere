function params = ImportSystem(filename)
%filename = 'Example_Input.csv';
%Destination is the first location entered.

%% Initialize variables.
delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: text (%q)
%	column2: text (%q)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
params.Name = dataArray{:, 1};
params.Address = (dataArray{:, 2})';
params.NumberCarSeats = dataArray{:, 3};
params.HoursAvailableforTransit = dataArray{:, 4};
params.CantakePublicTransit = dataArray{:, 5};

end