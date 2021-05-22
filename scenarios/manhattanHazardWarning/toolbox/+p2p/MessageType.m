% Copyright 2018 The MathWorks, Inc
classdef MessageType < uint8
   enumeration
      QUERY_LATEST        (0)
      QUERY_ALL           (1)
      RESPONSE_BLOCKCHAIN (2)
      DO_NOTHING          (3)
      BROADCAST_LATEST    (4)
   end
end