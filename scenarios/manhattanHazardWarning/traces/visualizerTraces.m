classdef visualizerTraces
    % The class has static functions used for visulization of vehiles and
    % various other events
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties(Constant)
        % Event types in scenario
        VEHICLE_ENTRY_EVENT = 1
        HAZARD_ENTRY_EVENT = 2
        MOBILITY_EVENT = 3
        VEHICLE_STOP_EVENT = 4
        ALTERNATE_ROUTE_EVENT = 5
        PACKET_TRACE = 6
        HAZARD_REMOVE = 7
        SUCCESS_FAILURE_COUNT = 8
        HAZARD_COLLISION_EVENT = 9
        JOURNEY_COMPLETE_EVENT = 10
        RSU_INSTALLATION_EVENT = 11
    end
    
    methods(Static)
        % Peridically record the position of vehciles for purpose of
        % visualization
        function logVehicularPositionAndStats (args)
            timeS = Simulator.Now();
            persistent countSetFlag;
            if(isempty(countSetFlag)) % Init stats count to 0
                for i=0:(args.numVehicles-1)
                    nodeListInfo.nodeTxCount(i+1, 0);
                    nodeListInfo.nodeRxCount(i+1, 0);
                    nodeListInfo.nodeHazardWarningRxCount(i+1, 0);
                    nodeListInfo.nodeHazardWarningTxCount(i+1, 0);
                    stats.getSetStats(i+1,'MacRxDrop',0);
                    stats.getSetStats(i+1,'RxError',0);
                    nodeListInfo.hazardStopFlag(i+1, 0);
                end
                
                for i=0:(args.numRogueVehicles-1)
                    % Trace is registered for all nodes including rogue.
                    stats.getSetStats( args.firstRogueVehId+i+1,'MacRxDrop',0);
                    stats.getSetStats( args.firstRogueVehId+i+1,'RxError',0);
                    
                end
                %                 stats.getSetStats(args.numVehicles+1,'MacRxDrop',0);
                %                 stats.getSetStats(args.numVehicles+1,'RxError',0);
                %
                nodeListInfo.nodeTxCount(args.rsuId,0);
                nodeListInfo.nodeRxCount(args.rsuId,0);
                nodeListInfo.nodeTxCount(args.rsuId2,0);
                nodeListInfo.nodeRxCount(args.rsuId2,0);
                nodeListInfo.nodeTxCount(args.rsuId3,0);
                nodeListInfo.nodeRxCount(args.rsuId3,0);
                nodeListInfo.nodeTxCount(args.rsuId4,0);
                nodeListInfo.nodeRxCount(args.rsuId4,0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+1, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+1, 0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+2, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+2, 0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+3, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+3, 0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+4, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+4, 0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+5, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+5, 0);
                nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+6, 0);
                nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+6, 0);
%                 disp('args.resuId');
%                 disp(args.rsuId);
%                 disp('arg.numVeh+args.numRogue+1');
%                 disp(args.numVehicles+args.numRogueVehicles+1);
%                 disp('arg.numVeh+args.numRogue+2');
%                 disp(args.numVehicles+args.numRogueVehicles+2);
                
                nodeListInfo.nodeHazardWarningRxCount(args.rsuId, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.rsuId, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.rsuId2, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.rsuId2, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.rsuId3, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.rsuId3, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.rsuId4, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.rsuId4, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+1, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+1, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+2, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+2, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+3, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+3, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+4, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+4, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+5, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+5, 0);
                nodeListInfo.nodeHazardWarningRxCount(args.numVehicles + ...
                                               args.numRogueVehicles+6, 0);
                nodeListInfo.nodeHazardWarningTxCount(args.numVehicles + ...
                                               args.numRogueVehicles+6, 0);
                stats.getSetStats(args.numVehicles+args.numRogueVehicles + ...
                                               1,'MacRxDrop',0);
                stats.getSetStats(args.numVehicles+args.numRogueVehicles + ...
                                           1, 'RxError', 0);
                
                % Initiaze success/failure counts to zero
                nodeListInfo.hazardAvoidanceCount(0);
                nodeListInfo.hazardStoppageCount(0);
                nodeListInfo.hazardCollisionCount(0);
                countSetFlag = 1;
            end
            file = fopen('log_file.txt','a+');
            % Log mobility of normal vehicles.
            for i=0:(args.numVehicles-1)
                node = NodeList.GetNode(i);
                mmObj = node.GetObject(args.mm);
                currentPosition = mmObj.GetPosition ();
                txCount = nodeListInfo.nodeTxCount(i+1);
                rxCount = nodeListInfo.nodeRxCount(i+1);
                hazardWarningTxCount = nodeListInfo.nodeHazardWarningTxCount(i+1);
                hazardWarningRxCount = nodeListInfo.nodeHazardWarningRxCount(i+1);
                phyRxErrorCount = stats.getSetStats(i+1, 'RxError');
                macRxErrorCount = stats.getSetStats(i+1, 'MacRxDrop');
                fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS, ...
                    visualizerTraces.MOBILITY_EVENT, i, currentPosition(1), ...
                    currentPosition(2),currentPosition(3), -1, -1, -1);
                fprintf (file,'%f %d %d %f %f %f %d %d %d\n', timeS, ...
                    visualizerTraces.PACKET_TRACE, i, txCount, hazardWarningTxCount, ...
                    rxCount, hazardWarningRxCount, phyRxErrorCount, macRxErrorCount);
            end
            % Log mobility of rogue vehicles
            for i=0:(args.numRogueVehicles-1)
                node = NodeList.GetNode(args.firstRogueVehId + i);
                mmObj = node.GetObject(args.mm);
                currentPosition = mmObj.GetPosition ();
                fprintf (file,'%f %d %d %f %f %f %d %d %d\n', timeS, ...
                    visualizerTraces.MOBILITY_EVENT, args.firstRogueVehId + i, ...
                    currentPosition(1),currentPosition(2),currentPosition(3), ...
                    -1, -1, -1);
            end
            
            %do we need to add to this for RSU?
            txCount =  nodeListInfo.nodeTxCount(args.numVehicles+args.numRogueVehicles+6);
            rxCount =  nodeListInfo.nodeRxCount(args.numVehicles+args.numRogueVehicles+6);
            hazardWarningTxCount = nodeListInfo.nodeHazardWarningTxCount( ...
                                 args.numVehicles+args.numRogueVehicles+6);
            hazardWarningRxCount = nodeListInfo.nodeHazardWarningRxCount(...
                                 args.numVehicles+args.numRogueVehicles+6);
            phyRxErrorCount = stats.getSetStats(args.numVehicles + ...
                                 args.numRogueVehicles+1, 'RxError');
            macRxErrorCount = stats.getSetStats(args.numVehicles + ...
                                 args.numRogueVehicles+1, 'MacRxDrop');
            fprintf (file,'%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.PACKET_TRACE, args.numVehicles + ...
                args.numRogueVehicles, txCount, hazardWarningTxCount, rxCount, ...
                hazardWarningRxCount, phyRxErrorCount, macRxErrorCount);
            
            % Get Success/Failure Counts
            hazardAvoidanceCount = nodeListInfo.hazardAvoidanceCount();
            hazardStoppageCount   = nodeListInfo.hazardStoppageCount();
            hazardCollisionCount =    nodeListInfo.hazardCollisionCount();
            
            fprintf (file,'%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.SUCCESS_FAILURE_COUNT, hazardAvoidanceCount, ...
                hazardStoppageCount, hazardCollisionCount , -1, -1, -1, -1);
            fclose(file);
            Simulator.Schedule('visualizerTraces.logVehicularPositionAndStats', ...
                args.logPeriodicity, args);
        end
        
        % Logging manhattan configuration in log file (to be later read by
        % visualizer)
        function logManhattanGridConfig(hBlocks, vBlocks, streetWidth, ...
                streetLen)
            
            file = fopen('scenario_info.txt','a+');
            fprintf (file,'%f %f %f %f %f ',hBlocks, vBlocks, streetWidth, ...
                streetLen, streetLen);
            fclose(file);
        end
        
        % Log Initial position of a all vehicles
        function logVehicles(numVehicles , numRogueVehicles, firstRogueVehId, rsuId, rsuId2, rsuId3, rsuId4)
%         function logVehicles(numVehicles , numRogueVehicles, firstRogueVehId)
%         function logVehicles(numVehicles , numRogueVehicles, firstRogueVehId, secondRogueVehId)    
            % Logging number of vehicles
            file = fopen('scenario_info.txt','a+');
            fprintf(file,'%f %f',numVehicles, numRogueVehicles);
            fclose(file);
            
            % Logging initial position of normal vehicles.
            mobilityModel = 'ConstantVelocityMobilityModel';
            for i=0:(numVehicles-1)
                node = NodeList.GetNode(i);
                mmObj = node.GetObject(mobilityModel);
                currentPosition = mmObj.GetPosition ();
                timeS = Simulator.Now();
                file = fopen('log_file.txt','a+');
                fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS, ...
                visualizerTraces.VEHICLE_ENTRY_EVENT, i, currentPosition(1), ...
                currentPosition(2), currentPosition(3), -1, -1, -1);
                fclose(file);
            end
            
            % Logging initial position of rogue vehicles vehicles.
            mobilityModel = 'ConstantVelocityMobilityModel';
            for i=0:(numRogueVehicles-1)
                node = NodeList.GetNode(firstRogueVehId + i);
                mmObj = node.GetObject(mobilityModel);
                currentPosition = mmObj.GetPosition ();
                timeS = Simulator.Now();
                file = fopen('log_file.txt','a+');
                fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS, ...
                visualizerTraces.VEHICLE_ENTRY_EVENT, firstRogueVehId + i, ...
                currentPosition(1), currentPosition(2), currentPosition(3), ...
                -1, -1, -1);
                fclose(file);
            end
            
            %Use RSU ID for something
            rsu = NodeList.GetNode(rsuId);
            mmObj = rsu.GetObject('ConstantPositionMobilityModel');         %%changed
            currentPosition = mmObj.GetPosition();
            file = fopen('log_file.txt', 'a+');
            fprintf (file, '%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.RSU_INSTALLATION_EVENT, rsuId, ...
                currentPosition(1), currentPosition(2), currentPosition(3), ...
                -1, -1, -1);
            fclose(file);
            
            %Use RSU ID2 for something
            rsu2 = NodeList.GetNode(rsuId2);
            mmObj2 = rsu2.GetObject('ConstantPositionMobilityModel');         %%changed
            currentPosition2 = mmObj2.GetPosition();
            file = fopen('log_file.txt', 'a+');
            fprintf (file, '%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.RSU_INSTALLATION_EVENT, rsuId2, ...
                currentPosition2(1), currentPosition2(2), currentPosition2(3), ...
                -1, -1, -1);
            fclose(file);
            
            %Use RSU ID3 for something
            rsu3 = NodeList.GetNode(rsuId3);
            mmObj3 = rsu3.GetObject('ConstantPositionMobilityModel');         %%changed
            currentPosition3 = mmObj3.GetPosition();
            file = fopen('log_file.txt', 'a+');
            fprintf (file, '%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.RSU_INSTALLATION_EVENT, rsuId3, ...
                currentPosition3(1), currentPosition3(2), currentPosition3(3), ...
                -1, -1, -1);
            fclose(file);
            
            %Use RSU ID4 for something
            rsu4 = NodeList.GetNode(rsuId4);
            mmObj4 = rsu4.GetObject('ConstantPositionMobilityModel');         %%changed
            currentPosition4 = mmObj4.GetPosition();
            file = fopen('log_file.txt', 'a+');
            fprintf (file, '%f %d %d %f %f %f %d %d %d\n', timeS, ...
                visualizerTraces.RSU_INSTALLATION_EVENT, rsuId4, ...
                currentPosition4(1), currentPosition4(2), currentPosition4(3), ...
                -1, -1, -1);
            fclose(file);
        end
        
        % Log hazard position
        function logHazard(hazardId)
            %disp('hi');
            timeS = Simulator.Now();
            node = NodeList.GetNode(hazardId);
            mmObj = node.GetObject('ConstantVelocityMobilityModel');
            currentPosition = mmObj.GetPosition ();
            file = fopen('log_file.txt','a+');
            fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS, ...
            visualizerTraces.HAZARD_ENTRY_EVENT, hazardId, ...
            currentPosition(1), currentPosition(2), currentPosition(3), ...
            -1, -1, -1);
            fclose(file);
        end
        % Open fresh log files, deleting any older ones
        function initLog()
            file1 = fopen('scenario_info.txt','w');
            file2 = fopen('log_file.txt','w');
            fclose(file1);
            fclose(file2);
        end
    end
end

