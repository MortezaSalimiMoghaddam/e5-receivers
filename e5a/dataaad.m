clc
clear all
close all
load('track1log12.txt');
load('track6log12.txt');
load('track17log12.txt');
load('track30log12.txt');
track1log12(:,10)=track1log12(:,10)+120246;
track6log12(:,10)=track6log12(:,10)+120905;
track17log12(:,10)=track17log12(:,10)+1687;
track30log12(:,10)=track30log12(:,10)+76410;

trackResults=struct([]);
trackResults(1,1).PRN = 1;
trackResults(1,2).PRN = 6;
trackResults(1,3).PRN = 17;
trackResults(1,4).PRN = 30;
trackResults(1, 1).I_P=track1log12(:,2);
trackResults(1, 2).I_P=track6log12(:,2);
trackResults(1, 3).I_P=track17log12(:,2);
trackResults(1, 4).I_P=track30log12(:,2);
trackResults(1, 1).absoluteSample = track1log12(:,10);
trackResults(1, 2).absoluteSample = track6log12(:,10);
trackResults(1, 3).absoluteSample = track17log12(:,10);
trackResults(1, 4).absoluteSample = track30log12(:,10);
save('trackingResults1', 'trackResults');
settings = initSettings();
