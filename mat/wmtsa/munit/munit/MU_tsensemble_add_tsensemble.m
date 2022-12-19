function [tse] = MU_tsensemble_add_tsensemble(tse, tse1)
      
tse.tsuites = [tse.tsuites tse1.tsuites];
  
return
