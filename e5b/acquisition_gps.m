function [ mmetric,mcode,mdoppler ] = acquisition_gps( x,fs,coffset )
mmetric = zeros(1,32);
mcode = zeros(1,32);
mdoppler = zeros(1,32);


fsr = 4096000.0/fs;
h =fir1(161,1.5e6/(fs/2));
x = filter(h,1,x) ;
x = x(81:end);
xr = interp1(1:length(x),real(x),1/fsr*(1:75*4096));
xi = interp1(1:length(x),imag(x),1/fsr*(1:75*4096));
x = xr+1j*xi;
%code_length = 10230;
for prn=1:32
    prn
    [ mmetric(prn),mcode(prn),mdoppler(prn) ] = search_gps( x,prn );
end



end

