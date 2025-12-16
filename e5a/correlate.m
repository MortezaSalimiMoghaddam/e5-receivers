function [ p ] = correlate(x,prn,chips,frac,incr,c)
n = length(x);
rz=[1; 1];

code_length = 10230;

p = 0.0j;
%cp = mod((chips+frac),code_length);
cp = mod(chips+frac+incr.*(0:n-1),code_length);
%rzp = mod((2*(chips+frac)),2);
rzp = mod((2*(chips+frac+incr.*(0:n-1))),2);
%for i =1:n

p= sum( x.*[(c(floor(cp)+1)).*rz(floor(rzp)+1)]);
%end

end

