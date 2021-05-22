% Copyright 2018 The MathWorks, Inc
classdef ClientNodeSet < handle

    properties
        node_set
    end
    
    methods
        function obj = ClientNodeSet()
            
        end
        
        function delete(obj)
            for idx=1:numel(obj.node_set)
                obj.node_set{idx}.delete();
            end
        end
        
        function node = add_client(obj, addr, remote_port, local_port)
            disp('### Inside Add Client');
            tmp_node = p2p.ClientNode(addr, remote_port, local_port);
            if tmp_node.ok
                obj.node_set{end+1} = tmp_node;
                node = obj.node_set{end};
            else
               disp('*** ERROR could not add client');
               node = [];
            end
            disp('### Leaving Inside Add Client');
        end
        
        function broadcast(obj, cmd, mess)
            for idx = 1:numel(obj.node_set)
                try
                    obj.node_set{idx}.transmit(cmd, mess);
                catch ME
                   disp('*** ERROR could not transmit'); 
                end
            end
        end
        
        function nodes = select(obj)
            nodes = {};
            %obj.print(); % FIXME
            for idx = 1:numel(obj.node_set)
               if (obj.node_set{idx}.bytes_available())
                   nodes{end+1} = obj.node_set{idx};
               end
            end
        end
        
        function print(obj)
            fprintf('============================\n');
            for idx = 1:numel(obj.node_set)
                fprintf('address: %s local_port:%d remote_port:%d ok:%d\n', ...
                    obj.node_set{idx}.address, ...
                    obj.node_set{idx}.local_port, ...
                    obj.node_set{idx}.remote_port, ...
                    obj.node_set{idx}.ok);
                udp_obj = obj.node_set{idx}.udp_obj;
                fprintf('  BytesAvailable: %d\n', udp_obj.BytesAvailable);
                fprintf('  ValuesReceived: %d\n', udp_obj.ValuesReceived);
                fprintf('  ValuesSend: %d\n\n', udp_obj.ValuesSent);
            end
            fprintf('============================\n\n');
        end
        
    end
end