
clear
if ~exist('./Chehra_v0.1_MatlabFit','dir')
    disp('Error! Chehra_v0.1_MatlabFit facial landmark tracker not found.');
    disp('Please download it from https://sites.google.com/site/chehrahome/');
    disp('Extract Chehra_v0.1_MatlabFit to the current directory of this m file, then run setup.m');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Test on iPhone Video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We add path for the folder Chehra_v0.1_MatlabFit to get access to the
%files in it
addpath(genpath('Chehra_v0.1_MatlabFit'))
%------------------VIDEO 1--------------------------------------------
i1=900:10:22881; %1x2199 vector
j1=1200:10:23180; %1x2199 vector
estimatedHR1=zeros(1,2199);
for n1=1:2199

    estimatedHR1(n1) = getHeartRateFromVideo('./videos/Co_StDa_250110.avi',i1(n1):j1(n1));
%getHeartRateFromVideo(filename, Frames to use (eg 306:2135))    
   
end
fprintf('We do not know the Ground Truth Heart Rate\n');
%fprintf('Estimate:  %d  BPM\n\n', estimatedHR1(100));
k1=1:2199;
plot(k1,estimatedHR1)
axis([0,2200,40,150])
title('Co_StDa_250110')
xlabel('Frames(1 sec = 25 Frames)')
ylabel('Estimated Heart Rate')
savefig('Co_StDa_250110.fig')
csvwrite('Co_StDa_250110.dat',estimatedHR1)
dlmwrite('Co_StDa_250110.txt',estimatedHR1)
%------------------END OF VIDEO 1---------------------------------------
%----------------------VIDEO 2------------------------------------------
i2=900:10:22881; %1x2199 vector
j2=1200:10:23180; %1x2199 vector
estimatedHR2=zeros(1,2199);
for n2=1:2199

    estimatedHR2(n2) = getHeartRateFromVideo('./videos/Co_RoDu_021209.avi',i2(n2):j2(n2));
%getHeartRateFromVideo(filename, Frames to use (eg 306:2135))    
   
end
fprintf('We do not know the Ground Truth Heart Rate\n');

k2=1:2199;
plot(k2,estimatedHR2)
axis([0,2200,40,150])
title('Co_RoDu_021209')
xlabel('Frames(1 sec = 25 Frames)')
ylabel('Estimated Heart Rate')
savefig('Co_RoDu_021209.fig')
csvwrite('Co_RoDu_021209.dat',estimatedHR2)
dlmwrite('Co_RoDu_021209.txt',estimatedHR2)
%----------------------END OF VIDEO 2-------------------------------------
%---------------------------VIDEO 3---------------------------------------
i3=875:10:22781;
j3=1175:10:23080;
estimatedHR3=zeros(1,2191);
for n3=1:2191

    estimatedHR3(n3) = getHeartRateFromVideo('./videos/Co_BiLi_71209.avi',i3(n3):j3(n3));
%getHeartRateFromVideo(filename, Frames to use (eg 306:2135))    
   
end
fprintf('We do not know the Ground Truth Heart Rate\n');

k3=1:2191;
plot(k3,estimatedHR3)
axis([0,2200,40,150])
title('Co_BiLi_71209')
xlabel('Frames(1 sec = 25 Frames)')
ylabel('Estimated Heart Rate')
savefig('Co_BiLi_71209.fig')
csvwrite('Co_BiLi_71209.dat',estimatedHR3)
dlmwrite('Co_BiLi_71209.txt',estimatedHR3)
%------------------------END OF VIDEO 3----------------------------------

