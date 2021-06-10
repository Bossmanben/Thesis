classdef ConsensusAlgorithm
    % Implementation of Consensus Algorithm
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties(Constant)
        
    end
    
    methods(Static)
        
        function controller(Data, nodeId)
            global F            %F: number of faulty nodes
            F = 0;
            
            netState = "Start";
            while(netState == "Start")                
                Leader = ConsensusAlgorithm.request();
                disp("Finished Request");
                disp("Leader: " + Leader);
                ConsensusAlgorithm.preprepare(Data, Leader, nodeId);
                disp("Finished Preprepare");
                netState = "End";
            end
            
        end
        
        function Leader = request()
            % A primary node collects vehicular data in the vicinity and 
            % compiles it into a data block. This data block would contain 
            % a block hash and a digital signature of the node, which then
            % becomes a leader RSU.
            
            %NodeId of RSU: 49 - 52 (@ 9 cars)
            %NodeId of RSU: 45 - 48 (@ 5 cars)
            %NodeId of RSU: 50 - 53 (@ 10 cars)
            %NodeId of RSU: 55 - 58 (@ 15 cars)
            % F = number of nodes
            xmin = 45;
            xmax = 48;
            n = 1;
            Leader = xmin+randi(1,n)*(xmax-xmin);
        end   
        
        function preprepare(Data, Leader, nodeId)
            % The leader RSU broadcasts the request to other pre-selected 
            % RSUs. Specifically, the primary node/leader RSU sends the 
            % transaction list, generated from the earlier data block to 
            % the entire network of pre-selected nodes            
            
            %Create and initialize packet 
            
            RSU = nodeId;
            pktType = 5;
            disp("CurBlock");
            disp(Data);
            [payloadBuf, payloadSize] = WSMPTraffic.constructConsensusPacket(Leader, ...
                                             pktType, Data, RSU);

            %Send packet to channel 
            channel = 178;
            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
            nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
            
            %Receive function of RSUs will initialize a dictionary/array
            %for them to keep track of each others messages
            
            %We will loop through this dictionary then append (without
            %verifying cause its the first step) the messages to the not
            %senders/non leader
            
            % In the WSMPTraffic.prepreparePkt     
            % Has a preprepare counter so Consensus will know that we're
            % ready for prepare phase
                                   
        end
        
        function prepare(Leader)
            % The received transaction list of pre-selected nodes is 
            % verified. The result of the verification is added to the 
            % signature of the evaluating node and is sent to the 
            % permutation of the network consisting of pre-selected nodes.
            global Backup
            
            for i=1:4                                
                if(Leader-44 ~= i)
                    curObj = Backup(i, 1);
                    mess = curObj.leadermsg;
                    RSU = i + 44;
                    nodeId = RSU;
                    pktType = 6;
                    [payloadBuf, payloadSize] = WSMPTraffic.constructConsensusPacket(Leader, ...
                        pktType, mess, RSU);
                    %Send packet to channel
                    channel = 178;
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
                    nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                end
            end
            
            
        end
        
        function commit(Leader)
            % The transaction lists, together with their audits come back 
            % to the primary node and are cross-verified. The primary node 
            % broadcasts an acknowledgment message to the network of
            % pre-selected nodes. A block is formed.
            
            global Backup
            global F
            
            for k=2:4
                COUNT = 0;
                for j = 1:4
                    if(j ~= k)
                        curObj = Backup(j, k);
                        if (curObj.state == "prepare")
                            COUNT = COUNT + 1;
                        end
                    end                    
                end
                SUM = 2*F + 1;
                if (COUNT >= (SUM))         
                    curObj = Backup(1, k);
                    mess = curObj.leadermsg;
                    RSU = k + 44;
                    nodeId = RSU;
                    pktType = 7;
                    [payloadBuf, payloadSize] = WSMPTraffic.constructConsensusPacket(Leader, ...
                        pktType, mess, RSU);
                    %Send packet to channel
                    channel = 178;
                    WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, nodeId, channel);
%                     disp("Commit Packet Sent to Vehicle");
%                     disp(payloadBuf);
                    nodeListInfo.nodeHazardWarningTxCount(nodeId+1, 1);
                    
                end                             
            end            
        end
        
        function reply()
            % Primary node broadcasts digitally signed authenticated data 
            % blocks to pre-selected RSUs. The block is stored and appended
            % to the chain.                       
            
            % instantiate array
            global Backup
            global F
            D = zeros(12, 3);
            Final_Counter = 0;
            D_Counter = 1;
            
            for k = 5:7
                COUNT = 0;
                for j = 1:4
                    if(j ~= k)
                        curObj = Backup(j, k);
                        if (curObj.state == "commit")
                            COUNT = COUNT + 1;
                        end
                    end                    
                end
                SUM = 2*F;
                if (COUNT >= (SUM)) 
                    for a = 1:4                     
                        D(D_Counter,1:3) = Backup(a, k).leadermsg;
                        D_Counter = D_Counter + 1;
                    end                                
                end                
            end
            
            for c = 1:length(D)
                if(D(1) == D(c))
                    Final_Counter = Final_Counter + 1;
                end
            end
            
            disp("Final Counter" + Final_Counter);
            
        end               
                
    end
end