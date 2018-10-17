%**************************************************************************
%Copyright (C) 2016, Antony Lam, all rights reserved.
%* Do not redistribute without permission.
%* Strictly for academic and non-commerial purpose only.
%* Use at your own risk.
%
%Please cite the following paper if you use this code:
%* Robust Heart Rate Measurement from Video Using Select Random Patches. 
%Antony Lam and Yoshinori Kuno, In ICCV 2015.
%Contact
%antonylam@cv.ics.saitama-u.ac.jp
%Graduate School of Science and Engineering
%Saitama University
%Last Update: January 26, 2016
%**************************************************************************

%Given a patch in the first frame and the tracked coordinates of the patch
%(r,c), return the average pixel value of all values in the patch for all
%frames.

%Input: frames, channel, (r,c) tracked coordinates, delta (about 0.5 of
%square patch's sides).
%Output: 1-D vector of average pixel values from each patch in each frame.
function vals=getAvePatchValOverTime(frames,channel,r,c,delta)
if nargin<5
    delta = 0;
end
imgSize = size(frames(1).cdata);
vals = zeros(1,length(frames));
for i = 1:length(frames)
    startR = uint16(max(r(i)-delta,1));
    endR = uint16(min(r(i)+delta,imgSize(1)));
    startC = uint16(max(c(i)-delta,1));
    endC = uint16(min(c(i)+delta,imgSize(2)));
    if startR>endR || startC>endC
        vals = [];
        return;
    end
    temp = frames(i).cdata(startR:endR,startC:endC,channel);
    %vals(i) = mean(double(temp(:))); %This is slower.
    vals(i) = sum(double(temp(:)))/numel(temp); %This should be faster.
end