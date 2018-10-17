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

currentPath = pwd;
addpath([currentPath '/FastICA_25']);
if exist([currentPath '/Chehra_v0.1_MatlabFit'],'dir')
    addpath(genpath([currentPath '/Chehra_v0.1_MatlabFit']));
    disp('Paths added. Please run demoHR.m')
else
    disp('Error! Chehra_v0.1_MatlabFit facial landmark tracker not found.');
    disp('Please download it from https://sites.google.com/site/chehrahome/');
    disp('Then extract Chehra_v0.1_MatlabFit to the current directory of this m file.');
end
clear currentPath;