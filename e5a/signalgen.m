clc
clear
fs= 2*10240000;
fcarr =1000;
fcode = 10230000+fcarr*10230000/1176.45e6;
delt =1/fs;
phase_inc_code = fcode*delt;
phase_inc_carr= 2*pi*fcarr*delt;
i= 1;
argin_frac = 0.2;
prn=2;
phase_data=0;
%%
% tic
% while(i<1*10230)
% argin_frac=argin_frac+phase_inc_code;
% argin_frac(argin_frac>=10230)=argin_frac(argin_frac>=10230)-10230;
% arg_in = fix(argin_frac)+1;
% ca = untitled3(prn,arg_in);
% phase_data = phase_data+phase_inc_carr;
% doppler =exp(1j*phase_data);
% %doppler_data(i) = doppler;
% i=i+1;
% signal(i) = ca*doppler;
% end
% toc
%% 
tic
argin_frac_init  = 0.2;
phaseinc_int = 0;
argin_frac =fix(mod(argin_frac_init+(0:50*fs-1)*phase_inc_code,10230))+1;
ca = untitled3(prn,argin_frac);
dopp = exp(1j*(phaseinc_int +(0:50*fs-1)*phase_inc_carr));
signal1= ca'.*dopp;
signal1 = awgn(signal1,-20,'measured');
toc

signal2 = zeros(1, 2*length(signal1));
signal2(1:2:end) = real(signal1);
signal2(2:2:end) = imag(signal1);

fileID = fopen('galNew.bin','wb');

fwrite(fileID,signal2 , "float");

fclose(fileID);