
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
        d_tcol(mink:limk,index)= arrayfun(@(x) colresult.rows(x).elements(1).distance(1).value,1:limk-mink+1);
        R_tcol(mink:limk,index)= arrayfun(@(x) colresult.rows(x).elements(1).duration(1).value,1:limk-mink+1);
        
        d_trow(index,mink:limk)= arrayfun(@(x) rowresult.rows(1).elements(x).distance(1).value,inds(1:limk-mink+1,1:limL-minL+1));
        R_trow(index,mink:limk)= arrayfun(@(x) rowresult.rows(1).elements(x).duration(1).value,inds(1:limk-mink+1,1:limL-minL+1));
    end
    %Google Distance Matrix API allows maximum 100 queries per second.
    if (length(locNames) > 25)
        pause(1)
    end
    
end