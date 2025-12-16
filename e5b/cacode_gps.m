function [ c ] = cacode_gps( prn,chips,frac,incr,n )
 load('codes_L1CA.mat');
 code_length = 1023;
 c1 = codes_L1CA(:,prn);
idx = mod(chips,code_length)+frac+incr.*(0:n-1);

idx = floor(idx);
idx = mod(idx,code_length);
c=c1(idx+1);


end

