function [decodeInterResult] = decodeInterleaving(trackResults, settings, PageStart, activeChnList, invertSymbol )
%decode interleaving from the data channel
%   Inputs:
%       trackResults       - output from the tracking function.
%       settings           - Receiver settings.
%       PageStart          -
%
%   Outputs:
%       decodeInterResult  - symbols after the processing of interleaving decoder

for channelNr = activeChnList
    % for channelNr = 3:3
    % The position of first preamble in Galileo message.
    FirstPageStartNr = PageStart(channelNr);

    % The number of pages in data channel. (One page is 1 second, and the
    % nominal page of Galileo I/NAV is 2 pages)
    symbolRate = uint32(250); % 250 bits/sec
    PageNr = idivide(settings.msToProcess/4-FirstPageStartNr,symbolRate ,'floor');%  Morteza: same as division here since the arguments
                                                                                  %           are not vectors
    datalength = floor(length(trackResults(channelNr).I_P(FirstPageStartNr:end))/4);
    data  = zeros(1,datalength);
    for i=1:datalength
        data(i) = sign(sum(trackResults(channelNr).I_P((i-1)*4+FirstPageStartNr:(i)*4+FirstPageStartNr-1)));
    end
    % Decode interleaving
    for i=1:PageNr

        % Record tracking results in every page. ( 1 second )
        onePageDataBeforeInter = data...
            ( 10 + 1 + symbolRate * (i-1) : ... % Morteza: 10 bits blonging to preamble ignored, hence 10 + 1 !
              symbolRate*i );

        % Convert tracking results to symbol.(240 symbolds)
        if invertSymbol(channelNr) == 0
            onePageDataBeforeInter (onePageDataBeforeInter > 0 ) = 0;
            onePageDataBeforeInter (onePageDataBeforeInter < 0 ) = 1;
        else
            onePageDataBeforeInter (onePageDataBeforeInter < 0 ) = 0;
            onePageDataBeforeInter (onePageDataBeforeInter > 0 ) = 1;
        end

        % Implement interleaving decoder. 30 columns(where data is written)
        % * 8 rows£¨where the data is read£©
        PageTypeandNavigationDatafelds= reshape(onePageDataBeforeInter,30,8);
        decodeInter = reshape(PageTypeandNavigationDatafelds',1,[]);
        decodeInterResult(channelNr).data((i-1)*240+1:i*240) = decodeInter;
    end
end
end
