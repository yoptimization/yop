classdef messages < handle
   methods (Static)
       function msg = error_size(dim)
           msg = ['Variables are matrix valued. Size of dimension ' num2str(dim) ' is therefore not possible.'];
       end
       
       function msg = wrong_size(operation, x)
            msg = ['Wrong dimensions for operation "', operation,'". You have: [' num2str(size(x)) '].'];
       end
       
       function msg = incompatible_size(operation, x, y)
            msg = ['Wrong dimensions for operation "', operation,'". You have: [' num2str(size(x)) '] and [' num2str(size(y)) '].'];
       end
       
   end
end