function [dist_mats, coords] = Generate_Dist_Mat(locNames)
%locNames = {'Rochester, NY','New York, NY','Boston, MA','Philadelphia, PA','Pittsburg, PA','Chicago, IL','Durham, NC','Long Beach, CA','Torrance, CA','Omaha, NB','Dallas, TX', 'Denver, CO'};

nloc = length(locNames);

%Querying Google API
% Querying Google Maps
%Google Maps API Credential: AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU

APIkey='AIzaSyDn-zSmuif-Mf8z16Pm1MLYp41zYcFoaX0';
pre_url = 'https://maps.googleapis.com/maps/api/distancematrix/json?';


d_t = zeros(nloc,nloc);
R_t = zeros(nloc,nloc);

inds = cell(nloc,nloc);
for k = 1:nloc
    for L = 1:nloc
        inds(k,L) ={[k,L]};
    end
end


for k = 1:ceil(length(locNames)/10)
    for L = 1:ceil(length(locNames)/10)
        mink = 10*(k-1)+1;
        minL = 10*(L-1)+1;
        limk = min(10*k,length(locNames));
        limL = min(10*L,length(locNames));
        
        locStringk = strrep(strjoin(locNames(mink:limk),'|'),' ','+');
        locStringL = strrep(strjoin(locNames(minL:limL),'|'),' ','+');
        
        
        url = [pre_url,'origins=',locStringk,'&','destinations=',locStringL,'&key=',APIkey];
        %url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=nottingham&destinations=london|manchester|liverpool&key=AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU';
        result = webread(url);
        
        %To account for API overuse...
        if (size(result.rows,1)<1)
            d_t = 100000*ones(nloc,nloc);
            R_t = 100000*ones(nloc,nloc);
            disp('API Overuse');
            return
        else
            d_t(mink:limk,minL:limL)= cellfun(@(x) result.rows(x(1)).elements(x(2)).distance(1).value,inds(1:limk-mink+1,1:limL-minL+1));
            R_t(mink:limk,minL:limL)= cellfun(@(x) result.rows(x(1)).elements(x(2)).duration(1).value,inds(1:limk-mink+1,1:limL-minL+1));
        end
        %Google Distance Matrix API allows maximum 100 queries per second.
        if (length(locNames) > 10)
            pause(1)
        end
    end
end
clear mink; clear minL; clear limk; clear limL;


d_t = d_t*(1/1609.34); %Convert meters to miles.
R_t = R_t*(1/3600); %Convert seconds to hours

dist_mats.d = d_t;
dist_mats.t = R_t;

%Coordinates
%Note that 'locations{2}' contains the location-names as inputted by user
APIkey2='AIzaSyDn-zSmuif-Mf8z16Pm1MLYp41zYcFoaX0';
pre_url2 = 'https://maps.googleapis.com/maps/api/geocode/json?';
coordinates = cell(1,size(locNames,1));
for i = 1:length(locNames)
    address = ['address=',strrep(locNames{i},' ','+')];
    url2 = [pre_url2,address,'&key=',APIkey2];
    %url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=nottingham&destinations=london|manchester|liverpool&key=AIzaSyDDKHV64CvECHE8wf_KXpLiWr2fM0XAnrU';
    webreturn = webread(url2);
    webreturn = webreturn.results.geometry;
    webreturn = webreturn.location;
    coordinates{i}= webreturn;
end

coords = cell2mat(cellfun(@(x) [x.lat;x.lng],coordinates,'UniformOutput',0)); %coordinates(1,k) is the latitude of the k'th location; coordinates(2,k) is the longitude.

end