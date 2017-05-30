function [dist_mat_rowcol, coordrowcol] = distmat_onerow_onecol(locNames,index)
%locNames = {'Rochester, NY','New York, NY','Boston, MA','Philadelphia, PA','Pittsburg, PA','Chicago, IL','Durham, NC','Long Beach, CA','Torrance, CA','Omaha, NB','Dallas, TX', 'Denver, CO'};

nloc = length(locNames);

%Querying Google API
% Querying Google Maps
%Google Maps API Credential: AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU

APIkey='AIzaSyDn-zSmuif-Mf8z16Pm1MLYp41zYcFoaX0';
pre_url = 'https://maps.googleapis.com/maps/api/distancematrix/json?';


d_trow = zeros(1,nloc);
d_tcol = zeros(nloc,1);

R_trow = zeros(1,nloc);
R_tcol = zeros(nloc,1);

singleString = strrep(locNames{index},' ','+');

for k = 1:ceil(length(locNames)/10)
    mink = 10*(k-1)+1;
    limk = min(10*k,length(locNames));
    
    locStringk = strrep(strjoin(locNames(mink:limk),'|'),' ','+');
    
    rowurl = [pre_url,'origins=',singleString,'&','destinations=',locStringk,'&key=',APIkey];
    colurl = [pre_url,'origins=',locStringk,'&','destinations=',singleString,'&key=',APIkey];
    %url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=nottingham&destinations=london|manchester|liverpool&key=AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU';
    colresult = webread(colurl);
    rowresult = webread(rowurl);
    %To account for API overuse...
    if (size(colresult.rows,1)<1)
        d_trow = zeros(1,nloc);
        d_tcol = zeros(nloc,1);
        
        R_trow = zeros(1,nloc);
        R_tcol = zeros(nloc,1);
        
        disp('API Overuse');
        return
    else
        d_tcol(mink:limk)= arrayfun(@(x) colresult.rows(x).elements(1).distance(1).value,1:limk-mink+1);
        R_tcol(mink:limk)= arrayfun(@(x) colresult.rows(x).elements(1).duration(1).value,1:limk-mink+1);
        
        d_trow(mink:limk)= arrayfun(@(x) rowresult.rows(1).elements(x).distance(1).value,1:limk-mink+1);
        R_trow(mink:limk)= arrayfun(@(x) rowresult.rows(1).elements(x).duration(1).value,1:limk-mink+1);
    end
    %Google Distance Matrix API allows maximum 100 queries per second.
    if (length(locNames) > 25)
        pause(1)
    end
    
end
clear mink; clear minL; clear limk; clear limL;



d_trow = d_trow*(1/1609.34); %Convert meters to miles.
d_tcol = d_tcol*(1/1609.34); %Convert meters to miles.

R_trow = R_trow*(1/3600); %Convert seconds to hours
R_tcol = R_tcol*(1/3600); %Convert seconds to hours

dist_mat_rowcol.drow = d_trow;
dist_mat_rowcol.dcol = d_tcol;
dist_mat_rowcol.trow = R_trow;
dist_mat_rowcol.tcol = R_tcol;

%% Coordinates
%Note that 'locations{2}' contains the location-names as inputted by user
APIkey2='AIzaSyDn-zSmuif-Mf8z16Pm1MLYp41zYcFoaX0';
pre_url2 = 'https://maps.googleapis.com/maps/api/geocode/json?';
coordinates = cell(1,1);

address = ['address=',strrep(locNames{index},' ','+')];
url2 = [pre_url2,address,'&key=',APIkey2];
%url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=nottingham&destinations=london|manchester|liverpool&key=AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU';
webreturn = webread(url2);
webreturn = webreturn.results.geometry;
webreturn = webreturn.location;
coordinates{1,1}= webreturn;


coordrowcol = cell2mat(cellfun(@(x) [x.lat;x.lng],coordinates,'UniformOutput',0)); %coordinates(1,k) is the latitude of the k'th location; coordinates(2,k) is the longitude.

end