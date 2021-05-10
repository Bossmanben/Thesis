classdef SmartContracts
    % Smart Contracts construction and sending and reception
    
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
        
        function constructor()
            %called to create smart contract; define/initialization all
            %variables
            global hazardLocation
            global nodeNumber
            global streetId
            hazardLocation = zeros(2,6);
            nodeNumber = zeros(1,2);
            streetId = zeros(1,2);
        end
        
        function register(payloadBuf)
            %register the nodes
            global hazardLocation
            global nodeNumber
            global streetId
            persistent hazardCounter
            if isempty(hazardCounter)
                hazardCounter = 0;
            end
            hazardCounter = hazardCounter+1;
            nodeNumber2 = payloadBuf(3);
            nodeNumber(hazardCounter) = nodeNumber2;   
            streetNumber = payloadBuf(5);
            streetId(hazardCounter) = streetNumber;
            hazard = payloadBuf(7:12);
            if all(hazardLocation(:)==0)
                hazardLocation = hazard;
            else
                hazardLocation = [hazardLocation; hazard];
            end
            
%             %error checking
%             disp('nodeId');
%             disp(nodeNumber);
%             disp('streetId');
%             disp(streetId);
%             disp('payload');
%             disp(payloadBuf);
%             disp('position');
%             disp(hazardLocation);            
        end
        
        function validated = hazardValidation(payload)
            %assumption1: location of real hazards won't change
            %assumption2: there will only be 2 hazards
            global hazardLocation
            global nodeNumber
            global streetId
            checkerval = 0;
            
            payloadBuf = payload.';
            nodeId = payloadBuf(3);
            streetNumber = payloadBuf(5);
            position = payloadBuf(7:12);
            
            if(nodeId == nodeNumber(1))
                checkerval = 1;
            elseif(nodeId == nodeNumber(2))
                checkerval = 1;
            end
            
            if(streetNumber == streetId(1))
                checkerval = checkerval + 1;
            elseif(streetNumber == streetId(2))
                checkerval = checkerval + 1;
            end
            
            if(position == hazardLocation(1, :))
                checkerval = checkerval + 1;
            elseif(position == hazardLocation(2, :))
                checkerval = checkerval + 1;
            end            
            
            validated = 0;
            if(checkerval == 3)
                validated = 1;
            end
        end
        
    end
end