function [slidedX, slidedXpt] = sliding(X, width, step)
%make vector X as slided version 
%
%   X: vector
%   width: the number of elements considered in each slide
%       minimum value is 1 ,maximum value is X, default value is 10
%   step: the number of bins passed in each slide
%       default value is 1
%
%   Heejeong Jeong
%   Oct. 2015

narginchk(1,3);
if nargin == 1
    width = 10; step = 1;
else 
    if nargin == 2; step = 1; end;
    if isempty(X)
        disp('empty X');
        return;
    elseif width<1 || width>length(X(1,:))
        disp('wrong width');
        return;
    end
    if step<1 || step>length(X(1,:))
        disp('wrong step');
        return;
    end
end
    
slidedX = zeros(length(X(:,1)),floor((length(X(1,:))-width)/step)+1);
slidedXpt = zeros(1,floor((length(X(1,:))-width)/step)+1);
for iBin = 1: (floor((length(X(1,:))-width)/step)+1)
    slidedX(:,iBin) = mean(X(:,(iBin-1)*step+1:(iBin-1)*step+width),2);
    slidedXpt(iBin) = (iBin-1)*step+round(width/2);
end
end
