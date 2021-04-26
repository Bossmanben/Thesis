classdef WSMPTraffic
    % WSMP TRAFFIC construction and sending and reception
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties(Constant)
        hazardWarning=1  % pkt type
        positionBeacon=2 % pkt type
        hazardRemovedPkt=3 % pkt type
        rsuGeneralPkt=4 % pkt type
        headerSize=12 % Size of WSMP header attached to each packet.
    end
    
    methods(Static)
        function runWSMPApp(args)
            CCH = 178; % CCH to be used for all packet transmission
            channel = CCH;
            switch(args.pType)
                case 'hazardWarning'
                    timeS = Simulator.Now();
                    % Stop sending hazard warning if hazard has been removed 
                    if((timeS*1000) < args.repairTimestamp) % TODO: Some better alternative 
                        %disp(args.nodeId);
                        [payloadBuf, payloadSize]= WSMPTraffic.constructHazardWarning(args.nodeId, args.rInfo, args.mm);
%                         disp('payloadBuf2');
%                         disp('u send the hazard warning here');
%                         disp(payloadBuf);
                        WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
                        disp('nodeId');
                        disp(args.nodeId);
                        disp('hazard sends warning packet');
                        nodeListInfo.nodeHazardWarningTxCount(args.nodeId+1, 1);
%                         disp('u send the hazard warning here');
%                         disp(payloadBuf);
                    else
                        % Schedule sending of 'hazard removed' packet so that stopped
                        % vehicles can resume journey.
                        persistent flag;
                        if(isempty(flag))
                            hazard.getSetHazardPresenceFlag(0);
                            file = fopen('log_file.txt','a+');
                            fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS,visualizerTraces.HAZARD_REMOVE, ...
                                args.nodeId, -1, -1 , -1, -1, -1, -1);
                            fclose(file);
                            flag = 1;
                            
                            % Configure and run WSMP app for sending hazard removed packets.
                            args.pType = 'hazardRemovedPkt';
                            args.mm = mobilityModel;
                            args.periodicity = 350;
                            % start sending 'hazard removed' packet
                            %Simulator.Schedule('WSMPTraffic.runWSMPApp', 1, args);
                            
                        end
                    end
                    
                case 'positionBeacon'
                    % Construct and send dummy position beacons to create
                    % network interference
                    [payloadBuf, payloadSize]= WSMPTraffic.constructPositionBeacon(args.nodeId, args.mm);
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
                case 'hazardRemovedPkt'
                    % Construct and send 'hazard removed' packet
                    [payloadBuf, payloadSize]= WSMPTraffic.constructHazardRemovedPkt(args.nodeId, args.rInfo);
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
                case 'rsuWarning'
                    % Construct and send 'rsu warning' packet
                    [payloadBuf, payloadSize]= WSMPTraffic.constructrsuWarning(args.nodeId, args.rInfo);
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
                   
            end
            
            % re-scheduling according to periodicity with 10ms randomness
            Simulator.Schedule('WSMPTraffic.runWSMPApp', args.periodicity +randi(10), args);
            
        end
        
        % Construct 'hazard warning' packet to be sent by hazard.
        function [payloadBuf, payloadSize] = constructHazardWarning(nodeId, routeInfo, mobilityModel)
            
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            
            currentPosition = mmObj.GetPosition ();
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            
            currentStreetId = routeInfo.getStreetIdByIndex();
            
            
            % ***********  Position beacon payload format ****************
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      streetId(2 bytes), xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes)
            
            % Packet filling: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.hazardWarning); % filling packet type
            payload.ttl = uint8(2); % filling TTL */
            payload.nodeId = uint16(nodeId); % Filling Sending Node
            payload.streetId = uint16(currentStreetId); % filling street id  */
            
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size each
            payload.xpos = uint16(bin2dec(utils.dec2twos(currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos(currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos(currentPosition(3), 16)));
            
            [payloadBuf, payloadSize] = utils.packStruct(payload);
        end
        
        % Construct 'hazard warning' packet to be sent by hazard.
        function [payloadBuf, payloadSize] = constructrsuWarning(nodeId, routeInfo, mobilityModel)
            
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            
            currentPosition = mmObj.GetPosition ();
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            
            currentStreetId = routeInfo.getStreetIdByIndex();
            
            
            % ***********  Position beacon payload format ****************
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      streetId(2 bytes), xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes)
            
            % Packet filling: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.rsuGeneralPkt); % filling packet type
            payload.ttl = uint8(2); % filling TTL */
            payload.nodeId = uint16(nodeId); % Filling Sending Node
            payload.streetId = uint16(currentStreetId); % filling street id  */
            
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size each
            payload.xpos = uint16(bin2dec(utils.dec2twos(currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos(currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos(currentPosition(3), 16)));
            
            [payloadBuf, payloadSize] = utils.packStruct(payload);
        end
        
        % Construct 'hazard removed' packet
        function [payloadBuf, payloadSize] = constructHazardRemovedPkt( ...
                                            nodeId, routeInfo)            
            currentStreetId = routeInfo.getStreetIdByIndex();
            % ***********  Payload format ****************
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      streetId(2 bytes)
            
            % Filling packet: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.hazardRemovedPkt); % filling packet type
            payload.ttl = uint8(2); % Fill TTL */
            payload.nodeId = uint16(nodeId); % Fill Sending Node
            payload.streetId = uint16(currentStreetId); % Fill street id  */
            
            [payloadBuf, payloadSize] = utils.packStruct(payload);
        end
        
        function [payloadBuf, payloadSize] = constructPositionBeacon(nodeId, ...
                                             mobilityModel)
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            
            currentPosition = mmObj.GetPosition ();             
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            
            %currentStreetId = routeInfo.getStreetIdByIndex();
            
            
            % ***********  Position beacon payload format ****************%
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes)
     
            % Filling packet: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.positionBeacon); % filling packet type
            payload.ttl = uint8(2); % filling TTL */
            payload.nodeId = uint16(nodeId); % Filling Sending Node
            %payload.streetId = uint16(currentStreetId); % filling street id  */
            
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size for each dimension.
            payload.xpos = uint16(bin2dec(utils.dec2twos(currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos(currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos(currentPosition(3), 16)));           
            [payloadBuf, payloadSize] = utils.packStruct(payload);
        end
                
        % Send the WSMP packet
        function sendWSMPPkt(payloadBuf, payloadSize,nodeId, channel)
            bssWildcard = 'FF:FF:FF:FF:FF:FF';
            WSMP_PROT_NUMBER = '0x88DC';
            SocketInterface.Send(payloadBuf, payloadSize, nodeId, channel, ...
                WSMP_PROT_NUMBER, bssWildcard);
% %             if(payloadBuf(1) == 4)
% %                  disp('send truly works for vehicle');
% %                  disp('nodeId');
% %                  disp(nodeId);
% %                  disp(payloadBuf);
% %             end
            if(payloadBuf(1) == 1)
                 disp('send truly works for rsu');
                 disp('nodeId');
                 disp(nodeId);
                 disp(payloadBuf);
            end
%             disp('send works');
            nodeListInfo.nodeTxCount(nodeId+1, 1);
%             disp('this is what u send in wsmp');
%             disp(payloadBuf);
%             if(payloadBuf(1) == 1)
%                 disp('nodeId');
%                 disp(nodeId);
%                 disp('send truly works for vehicle/hazard');
%                 disp(payloadBuf);
%             end
        end
        
        
        % Receive packet handler for RSU 
        % 'nodedId' is receiving vehicleId
        function receivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
%             disp('does receive function happen');
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
                    %do nothing
                    %do blockchain here
                    nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                    mobilityIntelligence.handleHazardWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize); 
                case WSMPTraffic.positionBeacon
                    % Do nothing
                case WSMPTraffic.hazardRemovedPkt
                    mobilityIntelligence.handleHazardRemovedPkt(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);
                case WSMPTraffic.rsuGeneralPkt
                    %do blockchain here
                    nodeId = payloadBuf(4);
                    payloadBuf(4) = 0;
                    payload = payloadBuf.';
                    nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                    mobilityIntelligence.handleHazardWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);  
                     disp('vehicle receives unique packets');
                     disp('nodeId');
                     disp(nodeId);
                     disp(payloadBuf);
                     disp(payload);
            end
            
        end
        
        % Receive packet handler for rsu 
        function revreceivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
            
%             if(payload(1) == 1)
%                 disp('rsu receives warning packet');
%             end
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
%                     nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
%                     mobilityIntelligence.handleHazardWarning(nodeId, ...
%                         payload, length-WSMPTraffic.headerSize);
                    %some blockchain stuff
                    
                    payloadBuf = payload.';
                    payloadBuf(1) = 4;
                    payloadBuf(4) = nodeId;
                    payloadS = size(payloadBuf);
                    payloadSize = payloadS(2);
                    channel = 178;                    
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
%                     disp('rsu sends unique packets');
                    disp('rsu receives packets');
                    disp('nodeId');
                    disp(nodeId);
                    disp(payloadBuf);
                case WSMPTraffic.positionBeacon
                    % Do nothing
                case WSMPTraffic.hazardRemovedPkt
                    mobilityIntelligence.handleHazardRemovedPkt(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);
            end
            
        end
        
    end
end
