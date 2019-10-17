classdef messages < handle
   methods (Static)
       function msg = error_size(dim)
           msg = ['Variables are matrix valued. Size of dimension ' num2str(dim) ' is therefore not possible.'];
       end
       
       function msg = error_plus(sx, sy)
           msg = ['Wrong dimensions for operation "+". You have: [' num2str(sx) '] and [' num2str(sy) '].'];
       end
   end
end