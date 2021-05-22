% Copyright 2018 The MathWorks, Inc
classdef ClientNode < handle
    
    properties
        local_port
        remote_port
        address
        udp_obj
        ok
    end
    
    methods
        function obj = ClientNode(addr, remote_port, local_port)
            obj.local_port = local_port;
            obj.remote_port = remote_port;
            obj.address = addr;
            obj.udp_obj = udp(addr, ...
                          'RemotePort', remote_port, ...
                          'LocalPort', local_port);
            set(obj.udp_obj, 'DatagramTerminateMode', 'off');
            set(obj.udp_obj, 'InputBufferSize', 2048);
            set(obj.udp_obj, 'OutputBufferSize', 2048);
            set(obj.udp_obj, 'Timeout', 10);
            try
                fopen(obj.udp_obj);
                obj.ok = true;
            catch ME
                disp('*** ERROR could not open client');
                delete(obj.udp_obj);
                obj.ok = false;
            end          
        end
        
        function delete(obj)
            try
                fclose(obj.udp_obj);
            catch ME
               disp('*** ERROR closing client'); 
            end
        end

        function transmit(obj, cmd, mess)
            cmd = uint8(cmd);
            mess = uint8(mess);
            
            % Write header
            fwrite(obj.udp_obj, length(mess), 'uint32');
            fwrite(obj.udp_obj, cmd, 'uint8');
            
            reply = fread(obj.udp_obj, 1, 'uint8');
            assert(reply == 255);
            
            bytes_remaining = length(mess);
            while (bytes_remaining > 0)
                disp(num2str(bytes_remaining)); % FIXME
                if length(mess) > 2048
                    fwrite(obj.udp_obj, mess(1:2048), 'uint8');
                    mess = mess(2049:end);
                    bytes_remaining = length(mess);
                    reply = fread(obj.udp_obj, 1, 'uint8');
                    assert(reply == 255);
                else
                    fwrite(obj.udp_obj, mess, 'uint8');
                    mess = '';
                    bytes_remaining = 0;
                    reply = fread(obj.udp_obj, 1, 'uint8');
                    assert(reply == 255);
                end
            end
        end
        
        function [cmd, mess] = receive(obj)
            % Receive header
            len = double(fread(obj.udp_obj, 1, 'uint32'));
            cmd = p2p.MessageType(fread(obj.udp_obj, 1, 'uint8'));
            
            % Acknowledge
            fwrite(obj.udp_obj, uint8(255), 'uint8');
            
            % Read data
            mess = [];
            bytes_remaining = len;
            while bytes_remaining > 0 
                disp(num2str(bytes_remaining));
                if bytes_remaining > 2048
                    rec = fread(obj.udp_obj, 2048, 'uint8');
                    mess = [mess; rec ];
                    bytes_remaining = bytes_remaining - 2048;
                    fwrite(obj.udp_obj, uint8(255), 'uint8');
                else
                    rec = fread(obj.udp_obj, bytes_remaining, 'uint8');
                    mess = [mess; rec];
                    bytes_remaining = 0;
                    fwrite(obj.udp_obj, uint8(255), 'uint8');
                end
            end
            mess = char(mess');
        end
        
        function ready = bytes_available(obj)
            if obj.udp_obj.BytesAvailable > 1
                ready = true;
            else
                ready = false;
            end
        end
       
    end
end