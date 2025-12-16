function [ c ] = l2cmcode( prn,chips,frac,incr,n )
 load('codes_E5bI.mat');
 code_length = 10230;
 c1 = codes_E5bI(:,prn);
idx = mod(chips,code_length)+frac+incr.*(0:n-1);

idx = floor(idx);
idx = mod(idx,code_length);
c=c1(idx+1);


end

