clc
clear
%close all
settings = initSettings();
fs = settings.samplingFreq;
coffset = 0 ;
% filename = '/home/mori/MatlabFiles/simulator/galileoTest/galileoSimV3/build/50galileo2.bin';
% filename = '/home/mori/MatlabFiles/simulator/galileoTest/galileoSimV2/build/50galileo2.bin';
% filename = '/home/mori/MatlabFiles/simulator/e5a/galNew.bin';
filename = '/home/mori/MatlabFiles/simulator/gnss-sdr/gnss-sdr/logGalE5a';
n = fs*0.075;
[fid] = fopen(filename,'rb');
fseek(fid,40000,'bof');
t = fread(fid,2*n,"float");
x = complex(t(1:2:end),t(2:2:end));
% x= mix(x,-650/fs, 0);
[ mmetric,mcode,mdoppler ] = acquisition_e5a( x,settings )
% [mmetric,mcode,mdoppler ] = acquisition( x,fs,coffset );
% [mmetric_gps,mcode_gps,mdoppler_gps ] = acquisition_gps( x,fs,coffset );
fclose(fid);
mmetric2 = mmetric(mmetric~= 0);
mmetric =mmetric/min(mmetric2);
acqnumber = 0;
for i = 1:36
    if mmetric(i)>=2
        acqnumber = acqnumber+1
        acqresult(acqnumber,1:4) = [i mmetric(i) mcode(i) mdoppler(i)];
    end
end
%%
for i=1:acqnumber
    [fid] = fopen(filename, 'rb');
    fseek(fid,40000,'bof');
    prn=acqresult(i);
    doppler     = mdoppler(prn);
    code_offset = mcode(prn);
    [ epoch, prompt,sa ] = Track_E5a( fid,filename,fs,coffset,prn,doppler ,code_offset);
    trackresult(i).I_P = real(prompt);
    trackresult(i).Q_P = imag(prompt);
    trackresult(i).absoluteSample =epoch ;
    trackresult(i).PRN =prn ;
    %ssa(i) =sa;
    fclose(fid)
end
%%
[navSolutions, eph] = postNavigation(trackresult, settings);
    