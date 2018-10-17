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

if ~exist('./Chehra_v0.1_MatlabFit','dir')
    disp('Error! Chehra_v0.1_MatlabFit facial landmark tracker not found.');
    disp('Please download it from https://sites.google.com/site/chehrahome/');
    disp('Extract Chehra_v0.1_MatlabFit to the current directory of this m file, then run setup.m');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Test on iPhone Video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('***Getting Heart Rate from iPhone 6 Captured Video***\n')
estimatedHR = getHeartRateFromVideo('./videos/File 1-15-16, 2 11 59 PM (105 BPM)_720p.mov');
fprintf('Ground Truth: 105 BPM\n');
fprintf(['Estimate: ' num2str(estimatedHR) ' BPM\n\n']);
input('Press Enter to Continue...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preliminary Tests on News Clips
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Some of these estimates could be wrong but I thought it'd be interesting
%to include more challenging cases to look at.
fprintf('\n***Preliminary Tests on News Clips***\n');
fprintf('The ground truth is unknown but I have included them for testing purposes.\n\n');

fprintf('President Obama Talking About Earth Day...\n')
estimatedHR = getHeartRateFromVideo('./videos/President Obama - April 18th, 2015 - Weekly Address - Video Caption - Earth Day.mov');
fprintf(['Estimate: ' num2str(estimatedHR) ' BPM\n\n']);
input('Press Enter to Continue...')

fprintf('President Obama on Gun Control...\n')
estimatedHR = getHeartRateFromVideo('./videos/President Obama tears up during gun control speech - BBC News.mov');
fprintf(['Estimate: ' num2str(estimatedHR) ' BPM\n\n']);
input('Press Enter to Continue...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tests on Videos Used in the ICCV Paper (Mahnob-HCI Videos)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n***Testing on Some Mahnob-HCI Videos from the ICCV Paper***\n');
fprintf('These are very slow to process, please wait...\n\n')
fprintf('Getting Heart Rate from P1-Rec1-2009.07.09.17.53.46_C1 trigger _C_Section_2.avi (frames 306 to 2135)...\n')
estimatedHR = getHeartRateFromVideo('./videos/P1-Rec1-2009.07.09.17.53.46_C1 trigger _C_Section_2.avi',306:2135);
fprintf('Ground Truth: 73 BPM\n');
fprintf(['Estimate: ' num2str(estimatedHR) ' BPM\n\n']);
input('Press Enter to Continue...')

fprintf('\nGetting Heart Rate from P25-Rec1-2009.09.01.14.47.38_C1 trigger _C_Section_28.avi (frames 306 to 2135)...\n')
estimatedHR = getHeartRateFromVideo('./videos/P25-Rec1-2009.09.01.14.47.38_C1 trigger _C_Section_28.avi',306:2135);
fprintf('Ground Truth: 84 BPM\n');
fprintf(['Estimate: ' num2str(estimatedHR) ' BPM\n\n']);