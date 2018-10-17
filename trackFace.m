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

%Input: Frames loaded from the function vid2frames.
%Output: A set of facial landmarks for each frame. This is found using the
%Chehra_v0.1_MatlabFit code. (https://sites.google.com/site/chehrahome/)

%This code does not really track the face over the frames. Instead, it
%detects the face independently for each frame. This is slower but was
%found to be more robust. (I encountered some issues with tracking errors
%gradually accumulating over frames, causing the landmarks to drift.)
function shape=trackFace(frames)
fitting_model = 'Chehra_v0.1_MatlabFit/models/Chehra_f1.0.mat';
load(fitting_model); 

%Detect Face in Frame
faceDetector = vision.CascadeObjectDetector();
bbox = step(faceDetector,frames(1).cdata);
init_shape = InitShape(bbox,refShape);
init_shape = reshape(init_shape,49,2);

%Convert to greyscale if needed. Also, convert frame to double.
if size(frames(1).cdata,3) == 3
    img = im2double(rgb2gray(frames(1).cdata));
else
    img = im2double((frames(1).cdata));
end

%Tracking Facial Landmarks
%Initial facial landmark detection for first frame.
shape = cell(1,length(frames));
MaxIter = 6;
shape{1} = round(Fitting(img,init_shape,RegMat,MaxIter));

for i = 2:length(frames)    
    if size(frames(i).cdata,3) == 3
        img = im2double(rgb2gray(frames(i).cdata));
    else
        img = im2double((frames(i).cdata));
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Detect the face in the frame and find the facial landmarks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbox = step(faceDetector,frames(i).cdata);
    
    %This code assumes there is only one subject in the video.
    %If more than one face was found, there was something wrong with the
    %face detection step.
    %So if one face was detected, use the detected face to find facial
    %landmarks. Else, use the landmarks from the previous frame.
    if size(bbox,1)==1
        init_shape = InitShape(bbox,refShape);
        init_shape = reshape(init_shape,49,2);
    else
        init_shape = shape{i-1};
    end  
    shape{i} = round(Fitting(img,init_shape,RegMat,MaxIter));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Use the previous frame's facial landmarks to initialize the facial
%landmark detection for the current frame. The above block can be commented
%out and below line uncommented, to use tracking. This would be faster but
%less robust to errors.
    %shape{i} = Fitting(img,shape{i-1},RegMat,MaxIter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mod(i,50)==0 %Display landmark detection results every 50 frames.
        disp([num2str(100*i/length(frames)) '%']);
        imshow(frames(i-1).cdata);
        drawnow;
        hold on;
        for j = 1:size(shape{i-1},1)
            text(shape{i-1}(j,1),shape{i-1}(j,2),num2str(j));
        end
        hold off;
        drawnow;
    end
end