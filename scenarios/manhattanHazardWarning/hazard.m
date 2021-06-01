classdef hazard
    methods(Static)
        % Create hazard, install WAVE stack on it and configure it to send
        % warning packets.
        
        %
        % Copyright (C) Vamsi.  2017-18 All rights reserved.
        %
        % This copyrighted material is made available to anyone wishing to use,
        % modify, copy, or redistribute it subject to the terms and conditions
        % of the GNU General Public License version 2.
        %
        
        function createHazard(hazardArgs)
            hazard.getSetHazardPresenceFlag(1); % Set flag of hazard presence.
            hazard.getSetHazardRoad(hazardArgs.roadId); %c Set hazard road id.
            m_hc = NodeContainer();
            m_hc.Create(1); % Create 1 hazard
            node = m_hc.Get(0);
            % Install wave stack on  hazard
            roadHazards = hazardArgs.waveHelper.Install(hazardArgs.phy, ...
                hazardArgs.mac, m_hc);
            
            % Register RX callback on hazard
            % SocketInterface.RegisterRXCallback(roadHazards, @WaveRXCallback);
            
            nodeId = node.GetId();
            hazardPositionInfo = vehicularRoute ; % Instantiate route object
            
            % Set route
            hazardPositionInfo.setRoute(nodeId+1, hazardArgs.roadId);
            nodeListInfo.routeObj(nodeId+1,hazardPositionInfo);
            vehicularMobility.setMobilityModel(nodeId,'ConstantVelocityMobilityModel');
            
            mobConfig.topology = hazardArgs.topology;
            mobConfig.nodeId = nodeId;
            mobConfig.routeInfo = hazardPositionInfo;
            mobConfig.mm = 'ConstantVelocityMobilityModel';
            mobConfig.acceleration = 0;
            mobConfig.speed = 0;  % Hazard is stationary
            
            % Offset from start of road.
            mobConfig.offset = hazardArgs.offsetFromStart;
            % Set mobility with configured parameters
            vehicularMobility.setVehiclePosAndVelocity(mobConfig);
            
            % Calculate hazard position coordinates
            streetInfo = hazardArgs.topology.getStreetInfo(hazardArgs.roadId);
            if(streetInfo.direction == [1 0 0])
                pos = streetInfo.startPosition + ...
                    [hazardArgs.offsetFromStart 0 0];
            elseif(streetInfo.direction == [-1 0 0])
                pos = streetInfo.startPosition + ...
                    [-hazardArgs.offsetFromStart 0 0];
            elseif(streetInfo.direction == [0 1 0])
                pos = streetInfo.startPosition + ...
                    [0 hazardArgs.offsetFromStart 0];
            elseif(streetInfo.direction == [0 -1 0])
                pos = streetInfo.startPosition + ...
                    [0 -hazardArgs.offsetFromStart 0];
            end
            hazard.getSetHazardPos(pos); % Store hazard coordinates.
            
            % Configure and run WSMP app for sending warning packets.
            WSMPArgs.pType = 'hazardWarning';
            WSMPArgs.nodeId = nodeId;
            WSMPArgs.rInfo = hazardPositionInfo;
            WSMPArgs.mm = 'ConstantVelocityMobilityModel';
            WSMPArgs.periodicity = hazardArgs.warningPeriodicity;
            WSMPArgs.repairTimestamp = hazardArgs.entryTime + hazardArgs.repairTime;
            WSMPArgs.hazardId = nodeId;            
            
            % start sending periodic hazard warning                                    
            %WSMPTraffic.runWSMPApp(WSMPArgs);
            Simulator.Schedule('WSMPTraffic.runWSMPApp', 1, WSMPArgs);
            
            % Register Hazard to Smart Contract
            [payloadBuf, payloadSize]= WSMPTraffic.constructHazardWarning(WSMPArgs.nodeId, WSMPArgs.rInfo, WSMPArgs.mm);
            SmartContracts.register(payloadBuf);
            
%             disp('hazard sends warning packet');
            hazard.getSetHazardTimeSlot(hazardArgs.entryTime, ...
                hazardArgs.entryTime + hazardArgs.repairTime);
            visualizerTraces.logHazard(nodeId);
            
            % Set fake route
            fakelocation = hazardArgs.fakeLoc;
            fakehazardRoadId = hazardArgs.topology.getStreetIdForBlock(cell2mat(fakelocation(2)), ...
                cell2mat(fakelocation(3)), ...
                cell2mat(fakelocation(1)));
            fakehazardPositionInfo = vehicularRoute;
            fakehazardPositionInfo.setRoute(nodeId+1, fakehazardRoadId); %Change second argument to rand between 1 to 48?
            nodeListInfo.routeObj(nodeId+1, fakehazardPositionInfo); %not sure if needed
            fakehazardPositionInfo.setCurrentStreetIndex(1);
             
            % Configure GPS Spoofing Attack                                   
            GPSArgs.pType = 'hazardWarning';
            GPSArgs.nodeId = nodeId;
            GPSArgs.rInfo = fakehazardPositionInfo;
            GPSArgs.mm = 'ConstantVelocityMobilityModel';
            GPSArgs.periodicity = hazardArgs.fakewarningPeriodicity;
            GPSArgs.repairTimestamp = hazardArgs.entryTime + hazardArgs.repairTime;
            GPSArgs.hazardId = nodeId;            
            
            Simulator.Schedule('WSMPTraffic.runWSMPApp', 1, GPSArgs);

        end
        
        % Get/Set hazard entry and exit time. Acts as a get function if no
        % argument is passed
        function [hazardEntryTime, hazardExitTime] = getSetHazardTimeSlot ...
                ( entryTime, exitTime)
            persistent hazardEntryT;
            persistent hazardExitT;
            if(isempty(hazardEntryT))
                hazardEntryT =0;
            end
            if(isempty(hazardExitT))
                hazardExitT =0;
            end
            if(nargin==2)
                hazardEntryT = entryTime;
                hazardExitT = exitTime;
            end
            hazardEntryTime = hazardEntryT;
            hazardExitTime = hazardExitT;
            
            
        end
        % Get/Set hazard presence flag
        function hazardPresenceFlag = getSetHazardPresenceFlag(flag)
            persistent hazardFlag;
            if(isempty(hazardFlag))
                hazardFlag = 0;
            end
            if(nargin==1)
                hazardFlag = flag;
            end
            hazardPresenceFlag = hazardFlag;
        end
        % Get/Set hazard Road
        function [roadId1, roadId2] = getSetHazardRoad(road)
            persistent hazardRoadId1;
            persistent hazardRoadId2;
            if(isempty(hazardRoadId1))
                hazardRoadId1 = 0;
            end
            if(isempty(hazardRoadId2))
                hazardRoadId2 = 0;
            end
            if(nargin==1)
                if(hazardRoadId1 == 0)
                    hazardRoadId1 = road;
                else
                    hazardRoadId2 = road;
                end
            end
            roadId1 = hazardRoadId1;
            roadId2 = hazardRoadId2;
%             roadId = hazardRoadId;
%             disp(roadId);
        end
        
        % Get/Set hazard Position
        function [position1, position2] = getSetHazardPos(pos)
            persistent hazardPos1;
            persistent hazardPos2;
            if(isempty(hazardPos1))
                hazardPos1 = [0 0 0];
            end
            if(isempty(hazardPos2))
                hazardPos2 = [0 0 0];
            end
            if(nargin==1)
                if(hazardPos1 == [0 0 0])
                    hazardPos1 = pos;
                else
                    hazardPos2 = pos;
                end
            end
            position1 = hazardPos1;
            position2 = hazardPos2;
%             disp(position);
        end
        
    end
end

