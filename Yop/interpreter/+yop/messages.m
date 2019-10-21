classdef messages < handle
   methods (Static)
       function msg = error_size(dim)
           msg = ['Variables are matrix valued. Size of dimension ' num2str(dim) ' is therefore not possible.'];
       end
       
       function msg = wrong_size(operation, x)
            msg = ['Wrong dimensions for operation "', operation,'". You have: [' num2str(size(x)) '].'];
       end
       
       function msg = incompatible_size(operation, x, y)
            msg = ['Incompatible dimensions for operation "', operation,'". You have: [' num2str(size(x)) '] and [' num2str(size(y)) '].'];
       end
       
       function msg = unrecognized_option(option_passed, fn_name)
           msg = ['Option "' option_passed '" passed to ' fn_name ' is not recognized as a valid option'];
       end
       
   end
end