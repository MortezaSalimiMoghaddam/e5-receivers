function [ p_prompt,s ] = tracke5b( x,s ,c)

n = length(x);
code_length = 10230;
fs = s.fs;
x= mix(x,-s.carrier_f/fs, s.carrier_p);


s.carrier_p = s.carrier_p -n*s.carrier_f/fs;
s.carrier_p = mod(s.carrier_p,1);
cf = (s.code_f + s.carrier_f / (1207.14e6/10230000)) / fs;
% for i=1:20001
% test_corr(i) = abs(correlate(x, s.prn, 0, s.code_p-(i-1)*.5-2500, cf,c));
% end

p_early = correlate(x, s.prn, 0, s.code_p-0.5, cf,c);

p_prompt = correlate(x, s.prn, 0, s.code_p, cf,c);
p_late = correlate(x, s.prn, 0, s.code_p+0.5, cf,c);

pll_k1 = .5;
pll_k2 = 50;
e = pll_costas(p_prompt);
e1 = s.carrier_e1;
s.carrier_f = s.carrier_f + pll_k1*e + pll_k2*(e-e1);
s.carrier_e1 = e;

%% DLL

dll_k1 = 0.02;
dll_k2 = 0.2;
s.early = abs(p_early);
s.prompt = abs(p_prompt);
s.late = abs(p_late);
if ((s.late+s.early)==0)
    e = 0;
else
    e = (s.late-s.early)/(s.late+s.early);
end

s.eml = e;
e1 = s.code_e1;
s.code_f = s.code_f + dll_k1*e + dll_k2*(e-e1);
s.code_e1 = e;

s.code_p = s.code_p + n*cf;
s.code_p = mod(s.code_p,code_length);

end

