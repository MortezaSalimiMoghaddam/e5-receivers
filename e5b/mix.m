function [ x ] = mix( x,f,p )
NT = 1024;
nco_table = exp(2*(pi)*(1j).*(1:NT)*(1.0/NT));
n = length(x);

df = floor(f*NT*(2^50));
dp = floor(p*NT*(2^50))+df.*(0:n-1);

    idx    = mod(floor(dp./(2^50)),1024)+1;
    x = x.*transpose(nco_table(idx));
    

    
    

end

