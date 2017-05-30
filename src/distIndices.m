function indices = distIndices(sizeGroup,group)
%alternatively to global sub2indMAT, include n as argument and use sub2ind([n,n],i,j)
global sub2indMAT;

if size(group,1)==1 %if a query is made for a single permutation
    if sizeGroup == 2
        indices = [sub2indMAT(group(1),group(2)),sub2indMAT(group(2),1)];
    elseif sizeGroup == 3
        indices = [sub2indMAT(group(1),group(2)),sub2indMAT(group(2),group(3)),sub2indMAT(group(3),1)];
    elseif sizeGroup ==4
        indices = [sub2indMAT(group(1),group(2)),sub2indMAT(group(2),group(3)), sub2indMAT(group(3),group(4)),sub2indMAT(group(4),1)];
    elseif sizeGroup == 5
        indices = [sub2indMAT(group(1),group(2)),sub2indMAT(group(2),group(3)), sub2indMAT(group(3),group(4)),sub2indMAT(group(4),group(5)),sub2indMAT(group(5),1)];
    elseif sizeGroup ==1
        indices = sub2indMAT(group(1),1);
    else
        indices = [sub2indMAT(group(1),group(2)),sub2indMAT(group(2),group(3)), sub2indMAT(group(3),group(4)),sub2indMAT(group(4),group(5)),sub2indMAT(group(5),group(6)),sub2indMAT(group(6),1)];
    end
else %if a query is made for many permutations or many groups
    indices = zeros(size(group,1),size(group,2));
    if sizeGroup == 2
        indices = [sub2indMAT(group(1,1),group(1,2)),sub2indMAT(group(1,2),1);sub2indMAT(group(1,2),group(1,1)),sub2indMAT(group(1,1),1)];
    elseif sizeGroup == 3
        for ii = 1:size(group,1)
            indices(ii,:) = [sub2indMAT(group(ii,1),group(ii,2)),sub2indMAT(group(ii,2),group(ii,3)),sub2indMAT(group(ii,3),1)];
        end
    elseif sizeGroup ==4
        for ii = 1:size(group,1)
            indices(ii,:) = [sub2indMAT(group(ii,1),group(ii,2)),sub2indMAT(group(ii,2),group(ii,3)), sub2indMAT(group(ii,3),group(ii,4)),sub2indMAT(group(ii,4),1)];
        end
    else %elseif sizeGroup ==5
        for ii = 1:size(group,1)
            indices(ii,:) = [sub2indMAT(group(ii,1),group(ii,2)),sub2indMAT(group(ii,2),group(ii,3)), sub2indMAT(group(ii,3),group(ii,4)),sub2indMAT(group(ii,4),group(ii,5)),sub2indMAT(group(ii,5),1)];
        end
    end
end
end



