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
                        [payloadBuf, payloadSize]= WSMPTraffic.constructHazardWarning(args.nodeId, args.rInfo, args.mm);
                        WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
                        nodeListInfo.nodeHazardWarningTxCount(args.nodeId+1, 1);                      
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
%             if(payloadBuf(1) == 4)
%                  disp('pkt type 4 sent to vehicle');
%             end
%             if(payloadBuf(1) == 1)
%                  disp('pkt type 1 sent to vehicle and rsu');
%             end
            nodeListInfo.nodeTxCount(nodeId+1, 1);
        end
        
        
        % Receive packet handler for RSU -> for vehicle (temp)
        % 'nodedId' is receiving vehicleId
        function receivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
                    %do blockchain here
                    %disp('Vehicle: send pkt 1 to rsu');
                    payloadBuf = payload.';
                    payloadBuf(1) = 1;
                    payloadBuf(4) = nodeId;
                    payloadS = size(payloadBuf);
                    payloadSize = payloadS(2);
                    CCH = 178;
                    channel = CCH;                  
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                    nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                    
                    nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                    mobilityIntelligence.handleHazardWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);
                    
                    %disp('Vehicle: receive pkt type 4 from rsu');
                    nodeId = payloadBuf(4);
                    payloadBuf(4) = 0;
                    payload = payloadBuf.';
                    nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                    mobilityIntelligence.handleHazardWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);  
            end
            
        end
        
        % Receive packet handler for VEHICLE -> for RSU (temp)
        function revreceivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
                    
                    
                % Base Blockchain Functionalities
                    
                    %Instantiate Blockchain
                    persistent Blockchain_Flag
                    global Sample
                    
                    if isempty(Blockchain_Flag)
                        Blockchain_Flag = 0;
                        Sample = Blockchain.BlockchainNew();
                        disp('Initializing Blockchain');
                        Blockchain.print(Sample);
                    end
                    Blockchain_Flag = Blockchain_Flag + 1;
                                            
                    %validate packet
                    validated = SmartContracts.hazardValidation(payload);
                                
                    if(validated == 1)
                        disp('continue with consensus');
                        
                        %Create Data Blocks
                        persistent i
                        if isempty(i)
                            i = 0;
                        end
                        nonce = uint32(i);
                        transaction = [payloadBuf(4), payloadBuf(5), payloadBuf(6)];        
                        CurBlock = Blockchain.add_block(Sample, transaction, nonce);
                        i = i + 1;
                        %Block tracker
                        filey = fopen('blocks.txt','a+');
                        fclose(filey);
                        fprintf (filey,'index: %d\ntimestamp: %s\ndata: %d %d %d\nnonce: %d\nhash: %s\nprevious_hash: %s\n\n', CurBlock.index, CurBlock.timestamp, CurBlock.data, CurBlock.nonce, CurBlock.hash, CurBlock.previous_hash); 

                        %Consensus shit

%                         %Add block to Blockchain, validates before adding
%                         is_addblock_success = Blockchain.add_mined_block(Sample, CurBlock);
%                         if(is_addblock_success == false)
%                             disp('Block not added to chain');
%                         end
%                         Blockchain.print(Sample);
                    end
                    
%                     %Validate chain
%                     is_bc_valid = Blockchain.validate_chain(Sample);
%                     if(is_bc_valid == false)
%                         disp('Chain corrupted');
%                         %Replace Chain
%                         NewSample = Blockchain.BlockchainNew();
%                         new_chain_broadcast = Blockchain.replace_blockchain(Sample, NewSample);
%                         %Broadcast creation of new chain
%                         %payload = new_chain_broadcast
%                     end  
                   
                    
                    %RSU sends back packets to vehicles
                    payloadBuf = payload.';
                    payloadBuf(1) = rsuGeneralPkt;      %pkt type 4: to send rsuGeneral
                    payloadBuf(4) = nodeId; %store the nodeId in the 4th payloadBuf
                    payloadS = size(payloadBuf);
                    payloadSize = payloadS(2); %get payloadSize
                    channel = 178;                    
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                    nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);

                case WSMPTraffic.rsuGeneralPkt
                    % Do something
            end
            
        end
        
    end
end
