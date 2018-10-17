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

%Returns a 3D matrix of all the frames from the specified video.

%Input: fileName is a string with the path and video's file name,
%Optional Input: rotationAngle will rotate the frame by the specified
%degrees (useful if video is upsidedown but normally set to 0), frames2Get
%is a 1-D vector of the frames to get from the video.
%For example, [306:2135] loads frames 306 to 2135.

%Output: The frames of the video and the frame rate.

function [frames,frameRate]=vid2Frames(fileName,rotationAngle,frames2Get)
vidObj = VideoReader(fileName);
frameRate = vidObj.FrameRate;

if nargin<3
    k = 1;
    while hasFrame(vidObj)
        frames(k).cdata = readFrame(vidObj);
        k = k + 1;
    end
else
    s = struct('cdata',zeros(vidObj.Height,vidObj.Width,3,'uint8'));
    frames = repmat(s,length(frames2Get),1); %Preallocating frames.

    currentFrameNum = 0;
    for k = 1:frames2Get(1)-1
        currentFrameNum = currentFrameNum + 1;
        readFrame(vidObj);
    end
    k = 1;
    while hasFrame(vidObj)
        if k>length(frames2Get)
            break;
        end
        currentFrameNum = currentFrameNum + 1;
        if currentFrameNum==frames2Get(k)
            frames(k).cdata = readFrame(vidObj);
            k = k + 1;
        else
            readFrame(vidObj);
        end
    end
end

if nargin>1 && rotationAngle~=0
    for k = 1:length(frames)
        frames(k).cdata = imrotate(frames(k).cdata,rotationAngle);
    end
end