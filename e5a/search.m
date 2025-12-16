function [ mmetric,mcode,mdoppler ] = search( x,prn )
fs = 4096000.0;
n = 81920 ;
code_length = 10230;
incr=code_length/n;

[ c ] = l2cmcode( prn,0,0,incr,n );
cconcat = [c ;zeros(n,1)];
cconcatfft=fft(cconcat);
mmetric = 0;
mcode = 0;
mdoppler = 0;
for doppler = -5000:50:5000
    
    q = zeros(2*n,1);

    [ w ] = nco( -doppler/fs,0,2*n );
    for i=1:2
        b = x((i-1)*n+1:(i+1)*n);
        b =transpose(b.*w);
        r=ifft(cconcatfft.*conj(fft(b)));
        q =q+abs(r);
    end
    [~,idx] = max(q);
    if q(idx)>mmetric
     mmetric =  q(idx);
     mcode = mod(code_length*(idx-1)/n,code_length);
     mdoppler = doppler;
    end
    
    
    
end


end

