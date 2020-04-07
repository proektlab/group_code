
function [filteredData] = filterData(data, sigma, kernel)

flipped = 0;
if size(data,2) < size(data,1)
    data = data';
    flipped = 1;
end

if ~exist('kernel', 'var') || isempty('kernel') || strcmpi(kernel, 'gaussian')
    x = floor(-3*sigma):floor(3*sigma);
    filterSize = numel(x);
    kernel = exp(-x.^2/(2*sigma^2))/(2*sigma^2*pi)^0.5;
elseif strcmpi(kernel, 'halfGaussian')
    x = floor(-3*sigma):floor(3*sigma);
    filterSize = numel(x);
    kernel = exp(-x.^2/(2*sigma^2))/(2*sigma^2*pi)^0.5;
    kernel(x <= 0) = 0;
end

filteredTrace = data;
filteredTrace = cat(2, repmat(filteredTrace(:,1)*0,[1,filterSize]), filteredTrace, repmat(filteredTrace(:,end)*0,[1,filterSize]));
filteredTrace = convn(filteredTrace, kernel, 'same');
filteredData = filteredTrace(:,filterSize+1:end-filterSize);

if flipped == 1
    filteredData = filteredData';
end