function [ mmetric,mcode,mdoppler ] = acquisition_e5a( x, settings )
mmetric = zeros(1,36);
mcode = zeros(1,36);
mdoppler = zeros(1,36);


%code_length = 10230;
for prn=1:36
    prn
    [ mmetric(prn),mcode(prn),mdoppler(prn) ] = search_e5a( x,prn,settings );
end



end

