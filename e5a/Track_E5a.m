function [epochout, prompt,ss ] = Track_E5a( fid,~,fs,~,prn,doppler ,code_offset)
code_length = 10230;
chip_rate = 10230000;
epoch = 0;
n = fix(fs*0.001*((code_length-code_offset)/code_length));
epoch=epoch+n;
t = fread(fid,2*n,'float');
%x = complex(t(1:2:end),t(2:2:end));
code_offset =code_offset+ n*1000*code_length/fs;
s.fs = fs;
s.prn = prn;
s. code_p = code_offset;
s.code_f   = chip_rate;
s. code_i = 0;
s . carrier_p=0;
s . carrier_f=doppler;
s.carrier_i = 0;
s.prompt1 = 0 + 0*(1j);
s.carrier_e1 = 0;
s.code_e1 = 0;
s.eml = 0;
block = 0;
%coffset_phase = 0.0;
numberofms = 60000;
prompt = zeros(1,numberofms);
while(1)
    if s.code_p<code_length/2
        n = fix(fs*0.001*(code_length-s.code_p)/code_length);
    else
        n = fix(fs*0.001*(2*code_length-s.code_p)/code_length);
    end

    t = fread(fid,2*n,'float');
    x = complex(t(1:2:end),t(2:2:end));
    epoch=epoch+n;
    % x = mix(x,-coffset/fs,coffset_phase);
    % coffset_phase = coffset_phase - n*coffset/fs;
    % coffset_phase = mod(coffset_phase,1);
    load('codes_E5aI.mat');
    code_length = 10230;
    c = codes_E5aI(:,prn);
    f = max(abs(xcorr(x(1:2:end),c)));
    % if f<10229
    %     f
    %     block
    %
    % end
    for i=1 % Morteza: 36?
        a = floor((i-1)*n/2+1);
        b = floor((i)*n/2);

        [ p_prompt,s ] = tracke5a( x,s,c );
        ss(block+1) = s;
        block= block+1;
        prompt(block)=p_prompt;
        epochout(block)=epoch;
    end
    if block==numberofms
        break
    end
    if mod (block,100)==0
        block
    end
end

