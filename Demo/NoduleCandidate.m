% Lung Nodule Candidate Generation
function [clustCenter, clustMembers] = NoduleCandidate(Im, bw)

% Input data init
xOffset = 100; yOffset = 60;
sw = 300; sh = 400;
bandwidth = bw;
data = [];
for i = xOffset : xOffset+sw
    for j = yOffset : yOffset+sh
        if Im(i, j) > 0
            data = [data; i, j];
        end
    end
end

data = data';

[clustCent, point2cluster, clustMembsCell] = MeanShiftCluster(data, bandwidth);

numClust = length(clustMembsCell);
clustMembers = cell(1, numClust);

for k = 1 : numClust
    myMembers = clustMembsCell{k};
    myClustCen = clustCent(:,k);
    [tp, L] = size(myMembers);

    clustPtSet = zeros(L, 2);
    clustPtSet(:,1) = data(1, myMembers);
    clustPtSet(:,2) = data(2, myMembers);

    clustMembers{k} = clustPtSet;

 end

clustCenter = clustCent;
