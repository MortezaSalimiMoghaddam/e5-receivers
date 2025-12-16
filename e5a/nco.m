function [ w ] = nco( f,p,n )
NT = 1024;
nco_table = exp(2*(pi)*(1j).*(1:NT)*(1.0/NT));
idx = p + f.*(1:n);
idx = floor(idx*NT);
idx = mod(idx,NT);
w= nco_table(idx+1);

end

