function [eph, TOW] = ephemeris(decoded,subframestart)

eph                            = struct('INTEGRITYflag', 0, 'beta0', 0, 'beta1', 0, 'beta2', 0,...
                                        'toc', 0, 'af0', 0, 'af1', 0, 'af2', 0, 'A0', 0,'A1', 0,  ...
                                        'TOE2', 0, 'crs', 0, 'deltaN0', 0, 'M0', 0, 'cuc', 0, 'ecc', 0, ...
                                        'cus', 0, 'wn', 0,'dtls', 0,'dtlsf', 0,'dn', 0, 'tot', 0, 'wnot', 0, 'wnlsf', 0, ...
                                        'cic', 0, 'Omega0', 0, 'cis', 0, 'I0', 0, 'crc', 0, 'Omega', 0, ...
                                        'deltaomegadot', 0, 'I0dot', 0, 'health', 0, 'TGD', 0, ...
                                        'deltaa', 0 );

bits = decoded(1:244*5);
bits(bits==-1)=0;
bits = dec2bin(bits);
bits = bits';
%find
% preambledecoed = zeros(1,12);
PRNnumber = 0;
massagetypeID = zeros(1,5);
TOW1  = [];
WN1   = zeros(1,5);
% alartflag = zeros(1,5);
subframe = zeros(5, 244);
TOW = NaN;

for i = 1:5 % Morteza: each F-nav subframe = 5 pages
    subframe(i, :)  = bits(244*(i-1)+1 : 244*i);
    massagetypeID(i) = bin2dec(char(subframe(i, 1 :6)));
    % parity = crc24q(subframe(1:214));
    % subframe(215:238)-parity;
    % preambledecoed (i) = bin2dec(subframe(1:8));
    % PRNnumber = bin2dec(char(subframe(1, 7:12)));
    if massagetypeID(i) > 6 || massagetypeID(i) < 1
        break
    end
    
    if  (massagetypeID(i) == 1)
        PRNnumber = bin2dec(char(subframe(i, 7:12)));
        TOW1 =[TOW1  bin2dec(char(subframe(i, 168:187)))];
        WN1(1) = bin2dec(char(subframe(i, 156:167)));
        eph.toc = bin2dec(char(subframe(i,23:36)))*60;
        eph.af0 = twosComp2dec(char(subframe(i, 37:67)))*2^-34;%% wrong in gnss sdr
        eph.af1 = twosComp2dec(char(subframe(i, 68:88)))*2^-46;
        eph.af2 = twosComp2dec(char(subframe(i, 89:94)))*2^-59;%% wrong in gnss sdr
        eph.TGD = twosComp2dec(char(subframe(i, 144:153)))*2^-32;
        eph.beta0 = bin2dec(char(subframe(i, 103:113)))*2^-2;
        eph.beta1 = twosComp2dec(char(subframe(i, 114:124)))*2^-8;
        eph.beta2 = twosComp2dec(char(subframe(i, 125:138)))*2^-15;
        eph.health = bin2dec(char(subframe(i, 154:155)));
        eph.INTEGRITYflag  = bin2dec(char(subframe(i, 188)));
    end

    if  (massagetypeID(i)==2)
        TOW1 = [TOW1 bin2dec(char(subframe(i, 195:214)))];
        WN1(2) = bin2dec(char(subframe(i, 183:194)));
        eph.wn = bin2dec(char(subframe(i, 39:51)));
        eph.deltaa   = bin2dec(char(subframe(i, 105:136)))*2^-19;
        eph.M0   = twosComp2dec(char(subframe(i, 17:48)))*2^-31*pi;
        eph.ecc   = bin2dec(char(subframe(i, 73:104)))*2^-33;
        eph.Omega0   = twosComp2dec(char(subframe(i, 137:168)))*2^-31*pi;
        eph.I0dot = twosComp2dec(char(subframe(i, 169:182)))*2^-43*pi;
        eph.deltaomegadot   = twosComp2dec(char(subframe(i, 49:72)))*2^-43*pi;
    end

    if  (massagetypeID(i)==3)
        TOW1 = [TOW1 bin2dec(char(subframe(i, 187:206)))];
        WN1(3) = bin2dec(char(subframe(i, 175:186)));       
        eph.TOE2     = bin2dec(char(subframe(i, 161:174)))*60;
        eph.I0       = twosComp2dec(char(subframe(i, 17:48)))*2^-31*pi;
        eph.Omega    = twosComp2dec(char(subframe(i, 49:80)))*2^-31*pi;
        eph.deltaN0  = twosComp2dec(char(subframe(i, 81:96)))*2^-43*pi;
        eph.crs   = twosComp2dec(char(subframe(i, 145:160)))*2^-5;
        eph.crc   = twosComp2dec(char(subframe(i, 129:144)))*2^-5;
        eph.cus   = twosComp2dec(char(subframe(i, 113:128)))*2^-29;
        eph.cuc   = twosComp2dec(char(subframe(i, 97:112)))*2^-29;
    end

    if  (massagetypeID(i)==4)
        TOW1      = [TOW1 bin2dec(char(subframe(i, 190:209)))];
        eph.cic   = twosComp2dec(char(subframe(i, 17:32)))*2^-29;
        eph.cis   = twosComp2dec(char(subframe(i, 33:48)))*2^-29;
        eph.A0    = twosComp2dec(char(subframe(i, 49:80)))*2^-30;
        eph.A1    = twosComp2dec(char(subframe(i, 81:104)))*2^-50;
        eph.dtls  = twosComp2dec(char(subframe(i, 105:112)));
        eph.tot   = bin2dec(char(subframe(i, 113:120)))*3600;
        eph.wnot  = bin2dec(char(subframe(i, 121:128)));
        eph.wnlsf = bin2dec(char(subframe(i, 129:136)));
        eph.dn    = bin2dec(char(subframe(i, 137:139)));
        eph.dtlsf = twosComp2dec(char(subframe(i, 140:147)));
    end
    TOW = TOW1(1); % Morteza: TOW needs the time corresponding to the starting subframe
    % eph = eph;
end
end