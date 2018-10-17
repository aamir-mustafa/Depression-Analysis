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

%Takes as input a video file and returns the estimated heart rate of a
%single subject from observing the face.

function hr=getHeartRateFromVideo(videoFileName,frames2Use)
%Parameters:
%videoFileName is the name of the video file.
%frames2Use is a vector of frames to load from the video.
%For example: [306:2135] loads frames 306 to 2135. The frames2Use parameter is optional.

rng('shuffle','twister'); %Seed the random number generator.

%Load video frames.
disp(['Loading ' videoFileName '...']);
if nargin<2
    [frames,frameRate] = vid2Frames(videoFileName);
    frames2Use = 1:length(frames);
else
    %This will load only the specified frames form the video.
    [frames,frameRate] = vid2Frames(videoFileName,0,frames2Use);
end

%Some parameters for preprocessing the video.
freqRange = 0.7:0.01:4; %Restrict frequency to typical human heart rates.
movingAveWindow = frameRate/5; %Temporal smoothing for removing noise.

%Track face.
[direc,name] = fileparts(videoFileName);
if isempty(direc) %If no directory was provided in the path, assume we are using the current directory.
    direc = '.';
end
landmarksFile = [direc '/' name '_trackedLandmarks_frames_' num2str(frames2Use(1)) 'to' num2str(frames2Use(end)) '.mat'];
if ~exist(landmarksFile,'file')
    disp('Tracking Facial Landmarks...');
    trackedLandmarks = trackFace(frames);
    disp(['Saving ' landmarksFile]);
    save(landmarksFile,'trackedLandmarks');
else
    disp('Loading Previously Tracked Facial Landmarks...');
    S = load(landmarksFile);
    trackedLandmarks = S.trackedLandmarks;
    clear S;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get color changes (traces) over time and do BPM estimate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Show frame to user. Feel free to comment out.

imshow(frames(1).cdata);
drawnow;

disp('Getting Traces and Doing ICA...');

%Predefined bounding box for face region using facial landmarks.
startR = trackedLandmarks{1}(25,2);
endR = trackedLandmarks{1}(42,2);
startC = trackedLandmarks{1}(1,1);
endC = trackedLandmarks{1}(10,1);

%ICA will look for two signals. We are assuming the skin region's color
%changes are due to cardiac activity and lighting color change only.
numComponents = 2;
%n is the number of patches to select for each ICA run. We could select
%more than two patches and ask ICA to find two components. By default, we
%supply ICA with two traces over time.
n = 2;
icasig = {[]};
dispstat('','init');

temp = [];

numPairs = 500; %500 was used in the paper.

%Determine patch size based on crop size of face. In the paper, delta = 20
%for all videos.
delta = round((endC - startC + 1)*0.15);

channel = 2; %Use the green channel.
for i = 1:numPairs
    dispstat(['Number of random patch pairs processed: ' num2str(i) '/' num2str(numPairs)]);
    while size(icasig{i},1)<numComponents %If running ICA only yielded one component, randomly select another pair of patches and run ICA again.
        coordsUsed{i} = [];
        traces = zeros(n,length(frames));
        %Randomly get n traces as input to ICA later.
        for j = 1:n
            tempTrace = [];
            while isempty(tempTrace) %If an invalid patch is randomly specified, the algorithm selects another random patch.
                r = randi([startR+delta endR-delta]);
                c = randi([startC+delta endC-delta]);
                [r,c] = getRandomTrack(r,c,trackedLandmarks,frameRate);
                tempTrace = getAvePatchValOverTime(frames,channel,r,c,delta); %Average all pixels in patch for each frame.
            end
            coordsUsed{i}{j} = [r; c];
            traces(j,:) = tempTrace;
        end
        traces = movingAve(traces',movingAveWindow)'; %Smooth using moving average to get rid of some noise.
        %Finally, run ICA on the traces and store the independent components.
        icasig{i} = fastica(traces,'numOfIC',numComponents,'verbose','off','stabilization','off');
    end
    icasig{end+1} = [];
 
    d = zeros(numComponents,1);
    for j  = 1:numComponents
        %Heuristically decide which of the two independent components is
        %the cardiac signal.
        %The raw color changes over the skin patch should be predominantly
        %due to color changes from the light source. So the component most
        %similar to the raw trace should be the one from the light source.
        %We save all the distances to the raw signal so later on, we know
        %which components are likely to *not* be the cardiac pulse.
        d(j) = min(sum((traces - repmat(icasig{i}(j,:),numComponents,1)).^2,2));
        
        %Like previous work, we apply a volley of preprocessing filters to
        %the components to make them nicer for estimating BPM.
        
        %Note on detrending filter:
        %In our paper, only lambda = 100 was used for the 61 FPS videos.
        %However, we have found that different lambda values work better
        %for different video frame rates.
        %We believe this is due to the combination of lambda and the
        %sampling rate of the input signal affecting the frequency response
        %of the detrending filter. The calculation of lambda in this code
        %is ad-hoc but seems to help keep the detrending filter's frequency
        %response from varying too much due to different video frame rates.
        %Tests indicate it works for 15-60 FPS videos.
        lambda = 100/((60/frameRate)^2);
        icasig{i}(j,:) = detrendingFilter(icasig{i}(j,:)',lambda)';
        icasig{i}(j,:) = movingAve(icasig{i}(j,:),movingAveWindow);
        
        %Compute pwelch.
        [pxxEst{i}{j},f] = pwelch(icasig{i}(j,:),length(icasig{i}(j,:)),[],freqRange,frameRate);
        [~,idx] = max(pxxEst{i}{j});
        
        %Find the peak frequencies in the distribution.
        pks = findpeaks(pxxEst{i}{j});
        [a,tempIdx] = max(pks);
        pks(tempIdx) = [];
        b = max(pks);
        
        %Heuristic to decide if there is a clearly dominant frequency in
        %the independent component. This is done by taking the ratio of the
        %two highest amplitudes in the frequency distribution. We call this
        %the selection ratio. 2 was used in the paper.
        if length([a b])==2 && (a/b)>2 %Check that two peaks were found and then compute selection ratio.
            bpmEst(i,j) = 60*f(idx); %Multiply peak frequency by 60 to get BPM.
            temp(end+1,:) = [a b bpmEst(i,j)];
        else
            bpmEst(i,j) = -1; %Heuristic determined BPM estimate to be unreliable due to no clear dominant frequency in the component. Mark for deletion.
        end
    end
    [~,idx] = min(d); %Find component most similar to light source color changes and mark for deletion from the BPM histogram.
    bpmEst(i,idx) = -1;
    
    %Delete all unreliable BPM estimates from histogram.
    icasig{i}(bpmEst(i,:)==-1,:) = [];
end
icasig(end) = [];
fprintf('\n');

%Take majority vote (mode) from BPM histogram as final estimate.
hr = bpmEst(:);
hr(hr<0) = [];
hr = round(hr);
%histogram(hr,'BinMethod','integers'); %This can be uncommented to see the histogram of heart rates computed from the selected patch pairs.
hr = mode(hr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [r,c]=getRandomTrack(r,c,trackedLandmarks,frameRate)
for i = 2:length(trackedLandmarks)
    %Use the eyebrows and nose for alignment.
    transform = computeRigidTransformation(trackedLandmarks{i-1}(1:19,:),trackedLandmarks{i}(1:19,:));
    temp = [c(:,end) r(:,end) 1]';
    transformedPts = (transform*temp)';
    r = [r transformedPts(:,2)];
    c = [c transformedPts(:,1)];
end
movingAveWindow = round(frameRate/5);
r = movingAve(r',movingAveWindow)';
c = movingAve(c',movingAveWindow)';