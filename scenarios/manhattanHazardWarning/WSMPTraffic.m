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
        prepreparePkt = 5 % pkt type
        preparePkt = 6 % pkt type
        commitPkt = 7 % pkt type
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
            %      1 2 | 3 0 | 8 9 | x x | y y | z z
            
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
%             disp("payloadBuf of hazard warning");
%             disp(payloadBuf);
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
                
        function [payloadBuf, payloadSize] = constructConsensusPacket(Leader, ...
                                             pktType, Data, RSU)                     
            % ***********  Position beacon payload format ****************%
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      0 (6 bytes)
            % 5 : preprepare, 6: prepare, 7: commit, 8: reply
            % example: 5 2 49 0 0 0 0 0 0 0
            % example: 5 | 2 | 52 0 | D D | D 0 | 49 0 | 
     
            % Filling packet: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(pktType); % filling packet type
            payload.ttl = uint8(2); % filling TTL */
            payload.nodeId = uint16(Leader); % Filling Sending Node
            
            DataBlock = Data;
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size for each dimension.            
            
            payload.xpos = [uint8(DataBlock(1)); uint8(DataBlock(2))];
            payload.ypos = uint16(DataBlock(3));
            payload.zpos = uint16(RSU);           
            [payloadBuf, payloadSize] = utils.packStruct(payload);
%             disp("payloadBuf constructed");
%             disp(payloadBuf);

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
        
        
        % Receive packet handler for vehicle
        % 'nodedId' is receiving vehicleId
        function receivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
                    payloadBuf = payload.';
                    if(payloadBuf(6) == 0)
                        if(payloadBuf(4) == 0)                            
                            payloadBuf(4) = nodeId;
                            payloadS = size(payloadBuf);
                            payloadSize = payloadS(2);
                            CCH = 178;
                            channel = CCH;  
                            %  disp('1. receive pkt from hazard');
                            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                            % disp('2. send pkt to rsu');
                            nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);


                            % disp('Vehicle: receive pkt type 4 from rsu');
                            nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                            mobilityIntelligence.handleHazardWarning(nodeId, ...
                                payload, length-WSMPTraffic.headerSize);
                        end
                    end     
                case WSMPTraffic.prepreparePkt                    
                    if(payloadBuf(8) == 0)
                        if(payloadBuf(4) == 0)                                
                            payloadBuf(4) = nodeId;
                            payloadBuf(8) = 1;
                            payloadS = size(payloadBuf);
                            payloadSize = payloadS(2);
                            CCH = 178;
                            channel = CCH;  
                            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                            nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);

                        end
                    end  
                case WSMPTraffic.preparePkt
                    if(payloadBuf(8) == 0)
                        if(payloadBuf(4) == 0)
                            payloadBuf(4) = nodeId;
                            payloadBuf(8) = 1;
                            payloadS = size(payloadBuf);
                            payloadSize = payloadS(2);
                            CCH = 178;
                            channel = CCH;  
                            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);                            
                            nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                        end
                    end
                case WSMPTraffic.commitPkt
                    if(payloadBuf(8) == 0)
                        if(payloadBuf(4) == 0)
                            payloadBuf(4) = nodeId;
                            payloadBuf(8) = 1;
                            payloadS = size(payloadBuf);
                            payloadSize = payloadS(2);
                            CCH = 178;
                            channel = CCH;  
                            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);                            
                            nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                        end
                    end
                case WSMPTraffic.rsuGeneralPkt
                    nodeId = payloadBuf(4);
                    payloadBuf(4) = 0;                  %remove the nodeId from the 4th row
                    payloadBuf(6) = 0;                  %remove the 1 from the 6th row
                    payload = payloadBuf.';
%                     disp('5. receive validated pkt from rsu');
                    nodeListInfo.nodeHazardWarningRxCount(nodeId+1, 1);
                    mobilityIntelligence.handleHazardWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);  
            end
            
        end
        
        % Receive packet handler for RSU (temp)
        function revreceivePkt(nodeId, pkt, length)
            persistent Backup_Flag
            global Prepare_Counter
            persistent Commit_Counter
            persistent Reply_Counter
            global Sample 
            persistent i
            payload = pkt(WSMPTraffic.headerSize+1:end);
            payloadBuf = payload.';
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Updating rx pkt count
            switch(payload(1)) % first byte in payload is pkt type
                case WSMPTraffic.hazardWarning
                    %disp('3. receive pkt from vehicle');
                % Base Blockchain Functionalities
                    
                    %Instantiate Blockchain
                    persistent Blockchain_Flag                                       
                    
                    if isempty(Blockchain_Flag)
                        Blockchain_Flag = 0;
                        Sample = Blockchain.BlockchainNew();
                        disp('Initializing Blockchain');
%                         Blockchain.print(Sample);
                    end
                    Blockchain_Flag = Blockchain_Flag + 1;
                    
                    %validate packet
                    validated = SmartContracts.hazardValidation(payload);
                                        
                    if(validated == 1)                        
                        
                        %Create Data Blocks
                        
                        if isempty(i)
                            i = 0;
                        end
                        nonce = uint32(i);
                        transaction = [payloadBuf(3), payloadBuf(5), payloadBuf(6)];        
                        CurBlock = Blockchain.create_block(Sample, transaction, nonce);
                        i = i + 1;
                        
                        if (Sample.blockchain(end).data == 198)
                            %Add block to Blockchain, validates before adding
                            is_addblock_success = Blockchain.add_mined_block(Sample, CurBlock);
                            if(is_addblock_success == false)
                                disp('Block not added to chain');
                            end
                        else                
                            checker = 0;
                            for idx=1:numel(Sample.blockchain) %go through Blockchain                                
                                if(CurBlock.data == Sample.blockchain(idx).data)                                
                                    checker = 1;        %(Data Block is not Unique if Checker = 1)
                                end
                            end
                            
                            if(checker == 0)   
                                %Unique packet scenario -> Go through
                                %consensus + send to vehicle
                                Backup_Flag = 0;
                                Data = CurBlock.data;
                                ConsensusAlgorithm.controller(Data, nodeId);
                            end
                            
                        end                                                                                               
                        
                        % RSU sends back packets to vehicles                        
                        payloadBuf(1) = 4;      %pkt type 4: to send rsuGeneral
                        payloadBuf(4) = nodeId; %store the nodeId in the 4th payloadBuf
                        payloadBuf(6) = 1;      %put 1 on 6th row to not allow vehicle from resending stuff
                        payloadS = size(payloadBuf);
                        payloadSize = payloadS(2); %get payloadSize
                        channel = 178;       
                        WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                        % disp('4. send pkt to vehicle');
                        nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                        
                    else 
                        disp('saw a fake hazard, did not continue with consensus');
                        %%do nothing
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
                case WSMPTraffic.prepreparePkt
                    if (Backup_Flag == 0)
                        Backup_Flag = 1;
                        global Backup
                        RSU1 = struct('state', {}, 'leadermsg', {});
                        RSU2 = struct('state', {}, 'leadermsg', {});
                        RSU3 = struct('state', {}, 'leadermsg', {});
                        RSU4 = struct('state', {}, 'leadermsg', {});
                        
                        Backup = [RSU1 RSU2 RSU3 RSU4];
                        sender = payloadBuf(9);
                        Leader = payloadBuf(3);
                                                                        
                        
%                       faulty = [payloadBuf(9), payload(10)];
                        checker = 1;

%                     for i = 1:length(faulty)
%                         if(faulty(i) ~= 0)
%                             checker = 0;
%                         end
%                     end
%                         disp("PayloadBuf of RSU");
%                         disp(payloadBuf);
                        if(sender == Leader)||(checker == 0 )
                            %do nothing
                        else
                            % else prepare a message and add to backup
                            leadermessage = payloadBuf(5:7);
                            msg.state = "preprepare";
                            msg.leadermsg = leadermessage;
                            for j = 45:48
                                if(j ~= Leader)
                                    %append message to backup
                                    Backup(j-44, 1) = msg;
                                else
                                    msg.state = 0;
                                    msg.leadermsg = 0;
                                    Backup(j-44, 1) = msg;
                                end

                            end
                            ConsensusAlgorithm.prepare(Leader);
                            disp("Finished prepare");
                            Prepare_Counter = 0;
                        end   
                    end
                    Backup_Flag = Backup_Flag + 1;                                     
                case WSMPTraffic.preparePkt
                    if (Prepare_Counter == 0)
                        Prepare_Counter = 1;
                        global Backup

                        Leader = payloadBuf(3);
                        leadermessage = payloadBuf(5:7);                        
                        
                        for j = 1:4
                            for k = 2:4
                                if(j ~= k)
                                    %append message to backup
                                    msg.state = "prepare";
                                    msg.leadermsg = leadermessage;
                                    Backup(j,k) = msg;
%                                     disp("j"+j);
%                                     disp("k"+k);
%                                     disp(Backup(j,k));
                                else
                                    msg.state = 0;
                                    msg.leadermsg = 0;
                                    Backup(j,k) = msg;
%                                     disp("j"+j);
%                                     disp("k"+k);
%                                     disp(Backup(j,k));
                                end
                            end                                                
                        end
                        ConsensusAlgorithm.commit(Leader);
                        disp("Finished commit");
                        Commit_Counter = 0;
                    end                                                                                
                    Prepare_Counter = Prepare_Counter + 1;    
                case WSMPTraffic.commitPkt
                    if(Commit_Counter == 0)
                        Commit_Counter = 1;
                        
                        global Backup                        
                        leadermessage = payloadBuf(5:7);
                        
                        for j = 1:4
                            for k = 5:7
                                % append message to backup
                                msg.state = "commit";
                                msg.leadermsg = leadermessage;
                                Backup(j,k) = msg;
%                                 disp("j"+j);
%                                 disp("k"+k);
%                                 disp(Backup(j,k));
                                
                            end                                                
                        end
                        
                        ConsensusAlgorithm.reply();
                        disp("Finished reply");
                        
                        %Create Data Blocks
                        if isempty(i)
                            i = 0;
                        end
                        nonce = uint32(i);
                        transaction = [payloadBuf(5), payloadBuf(6), payloadBuf(7)];        
                        CurBlock = Blockchain.create_block(Sample, transaction, nonce);
                        i = i + 1;
                        
                        %Add block to Blockchain, validates before adding
                        is_addblock_success = Blockchain.add_mined_block(Sample, CurBlock);
                        if(is_addblock_success == false)
                            disp('Block not added to chain');
                        end
                        Blockchain.print(Sample);
                        
                        %Block tracker
                        filey = fopen('blocks.txt','a+');
                        for idx=1:numel(Sample.blockchain)
                            fprintf(filey, 'index: %d\n', Sample.blockchain(idx).index); 
                            fprintf(filey, 'timestamp: %s\n', Sample.blockchain(idx).timestamp);
                            fprintf(filey, 'data: %d\n', Sample.blockchain(idx).data);
                            fprintf(filey, 'nonce: %d\n', Sample.blockchain(idx).nonce);
                            fprintf(filey, 'hash: %s\n', Sample.blockchain(idx).hash);
                            fprintf(filey, 'previous_hash: %s\n\n', Sample.blockchain(idx).previous_hash);
                        end
                        fclose(filey);
                        
                        Reply_Counter = 0;
                    end
                    Commit_Counter = Commit_Counter + 1;
            end
            
        end
        
    end
end
