function [firstSubFrame, activeChnList,decodebits] = findPreambles1(trackResults)

% findPreambles finds the first preamble occurrence in the bit stream of
% each channel. The preamble is verified by check of the spacing between
% preambles (6sec) and parity checking of the first two words in a
% subframe. At the same time function returns list of channels, that are in
% tracking state and with valid preambles in the nav data stream.
%
%[firstSubFrame, activeChnList] = findPreambles(trackResults, settings)
%
%   Inputs:
%       trackResults    - output from the tracking function
%       settings        - Receiver settings.
%
%   Outputs:
%       firstSubframe   - the array contains positions of the first
%                       preamble in each channel. The position is ms count
%                       since start of tracking. Corresponding value will
%                       be set to 0 if no valid preambles were detected in
%                       the channel.
%       activeChnList   - list of channels containing valid preambles

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
%
% Copyright (C) Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
% Written by Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
%--------------------------------------------------------------------------
%
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

% CVS record:
% $Id: findPreambles.m,v 1.1.2.10 2006/08/14 11:38:22 dpl Exp $

% Preamble search can be delayed to a later point in the tracking results
% to avoid noise due to tracking loop transients
searchStartOffset = 0;

%--- Initialize the firstSubFrame array -----------------------------------
%firstSubFrame = zeros(1, settings.numberOfChannels);

%--- Generate the preamble pattern ----------------------------------------
%preamble_bits = [1 -1 -1 -1 1 -1 1 1];

% "Upsample" the preamble - make 20 vales per one bit. The preamble must be
% found with precision of a sample.
%preamble_ms = kron(preamble_bits, ones(1, 20));

%--- Make a list of channels excluding not tracking channels --------------
activeChnList = 1:length(trackResults);% Morteza: Can include all the channels
CS20 = dec2bin(0x842E9) == '1';
CS20 = 2*CS20 -1;
flag = false;
%=== For all tracking channels ...
for channelNr = activeChnList

    %% Correlate tracking output with preamble ================================
    % Read output from tracking. It contains the navigation bits. The start
    % of record is skiped here to avoid tracking loop transients.
    IP = trackResults(channelNr).I_P(1 + searchStartOffset : end);
    %IP = IP *-1;

    preamble = [1 0 1 1 0 1 1 1 0 0 0 0]; % Morteza: 0xB70
    preamble = (preamble)*2 - 1;
    toCorr = zeros(1, 20*length(preamble));
    for i = 1:length(preamble)
        toCorr((i - 1)*20 +1 : i*20 ) =  preamble(i) * CS20;
    end
    xcorrresult = xcorr( sign(IP),toCorr);
    %plot(xcorrresult
    xcorrLength = (length(xcorrresult) +  1) /2;
    index  = find(abs(xcorrresult(xcorrLength : xcorrLength * 2 - 1))>239);
    % if xcorrresult(xcorrLength + index - 1) < -239
    %     flag = true;
    % else 
    %     flag = false;
    % end
    subframestart=[];
    for i =1 : length(index)
        index2 = index-index(i);
        if (length(nonzeros(mod(index2 , 10000)==0))>1)
            subframestart = index(i);
            break
        end
    end
    if sign(IP(subframestart : subframestart +239)) == -1*toCorr
        disp('here');
    else
        IP = -IP;
    end
    %subframestart = ceil(subframestart/20);
    datalength = floor(length(IP(subframestart : end))/20);
    data  = zeros(1,datalength);
    for i=1:datalength
        data1(i) = sign(sum(IP((i-1)*20+subframestart:(i)*20+subframestart-1)));
        %data(i) = sum(IP((i-1)*20+1:i*20));
    end
    % if flag == true
    %     data1 = -data1;
    % end
    trel = poly2trellis(7,[171 133]); % Trellis
   % data1 = data1(subframestart :end);
    % j = 1;
   % data2 = zeros(1, length(data1) - 12*ceil(length(IP)/10000));
    % for i = 1:length(data1)
   %     if mod(i, 500) > 0 && mod(i , 500) <= 12 
    %         data1(i)
    %     else
    %         data2(j) = data1(i);
    %         j = j + 1;
    %     end
    % end

    decoded = zeros(1 , 244*floor(length(data1)/500));
    for i = 1:floor(length(data1)/500)
        data2 = data1(13+ (i-1)*500 : i*500);
        data2(data2==-1)=0;
        % Create a ViterbiDecoder System object
        hVitDec = comm.ViterbiDecoder(trel, 'InputFormat', 'hard', 'TerminationMethod', 'Truncated');
        % numberofbits = floor(length(data)/7);
        data2= reshape(data2, 61, 8);
        data3= reshape(data2',1,488);
        % data3 = zeros(1, 488);
        % for j = 1 : 61
        %     data3((j-1)*8 +1: j*8) = data2(j, :);
        % end
    
        data4 = zeros(1, length(data3));
        for j = 1: length(data3)/2
            data4(2*j - 1) = data3(2*j -1);
            data4(2*j) = ~data3(2*j);
        end
    
        decoded((i-1)* 244 + 1 : i*244) = step(hVitDec, data4(1:end)')'; % Decode.
        % decoded(decoded==1)=-1;
    
        
        % preamble = [1 -1 1 1 -1 1 1 1 -1 -1 -1 -1]; % Morteza: 0xB70
        % xcorrresult = xcorr( decoded, preamble);
        % %plot(xcorrresult)
        % xcorrLength = (length(xcorrresult) +  1) /2;
        % index  = find(abs(xcorrresult(xcorrLength : xcorrLength * 2 - 1))>7);
        % subframestart=[];
        % for i =1 : length(index)
        %     index2 = index-index(i);
        %     if (length(nonzeros(mod(index2 , 300)==0))>7)
        %         subframestart = index(i);
        %         break
        %     end
        % end
    end
    decoded(decoded==0)=-1;
    % if isempty (subframestart)
    %     clear decoded
    %     decoded = step(hVitDec, data1(2:end-1)');
    %     decoded(decoded==0)=-1;
    %     xcorrresult1 = xcorr( decoded, preamble);
    %     %plot(xcorrresult)
    %     xcorrLength = (length(xcorrresult1) +  1) /2;
    %     index  = find(abs(xcorrresult1(xcorrLength : xcorrLength * 2 - 1))>7);
    %     for i =1 : length(index)
    %         index2 = index-index(i);
    %         if (length(nonzeros(mod(index2 , 300)==0))>7)
    %             subframestart = index(i);
    %             break
    %         end
    %     end
    % end
    %plot(decoded(subframestart:subframestart+30));
    % if (decoded(subframestart)==-1)
    %     decoded = decoded*-1;
    % end
    if (isempty(subframestart)==0)
        firstSubFrame(channelNr)=  floor(subframestart);
    end
    clear subframestart
    % if flag == false
    decodebits(channelNr,1:length(decoded))= decoded;
    % else
    %     decodebits(channelNr,1:length(decoded))= -decoded;
    % end
end % for channelNr = activeChnList
