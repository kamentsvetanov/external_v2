function SPM = wfu_SPM_template

%   Return a blank SPM structure
%   FORMAT SPM = wfu_SPM_template
%   
%   SPM - structure (from SPM.mat)
%
%   ## v1.1, Aaron Baer, Wake Forest University ##
%______________________________________________________________


%----- SPM fields -----%
SPM.SPMid               =   'WFU'; 

SPM.xBF                 =   [];

SPM.xY.RT               =   [];
SPM.xY.P                =   [];
SPM.xY.VY(1).fname      =   [];
SPM.xY.VY(1).mat        =   [];
SPM.xY.VY(1).dim        =   [];
SPM.xY.VY(1).dt         =   [];
SPM.xY.VY(1).pinfo      =   [];
SPM.xY.VY(1).n          =   [];
SPM.xY.VY(1).descrip    =   [];
SPM.xY.VY(1).private    =   []; 

SPM.nscan               =   [];
SPM.Sess                =   [];

SPM.xX.X                =   [];
SPM.xX.iH               =   [];
SPM.xX.iC               =   [];
SPM.xX.iB               =   [];
SPM.xX.iG               =   [];
SPM.xX.name             =   [];   
SPM.xX.K                =   [];
SPM.xX.W                =   [];
SPM.xX.xKXs.X           =   [];  
SPM.xX.xKXs.tol         =   [];     
SPM.xX.xKXs.ds          =   [];       
SPM.xX.xKXs.u           =   [];   
SPM.xX.xKXs.v           =   [];   
SPM.xX.xKXs.rk          =   [];    
SPM.xX.xKXs.oP          =   [];
SPM.xX.xKXs.oPp         =   [];
SPM.xX.xKXs.ups         =   [];
SPM.xX.xKXs.sus         =   []; 
SPM.xX.pKX              =   [];
SPM.xX.V                =   [];
SPM.xX.trRV             =   []; 
SPM.xX.erdf             =   [];              
SPM.xX.Bcov             =   [];                
SPM.xX.nKX              =   [];

SPM.xGX                 =   [];   

SPM.xVi                 =   [];
SPM.xVi.V               =   [];

SPM.xM                  =   [];
SPM.xM.T                =   []; 
SPM.xM.TH               =   [];
SPM.xM.I                =   []; 
SPM.xM.VM               =   []; 
SPM.xM.xs               =   [];

SPM.xsDes               =   [];   
SPM.swd                 =   [];

SPM.xVol.XYZ            =   [];               
SPM.xVol.M              =   [];              
SPM.xVol.iM             =   [];
SPM.xVol.DIM            =   [];         
SPM.xVol.FWHM           =   [];              
SPM.xVol.R              =   [];             
SPM.xVol.S              =   [];                 
SPM.xVol.VRpv           =   [];

SPM.xCon(1).name            =   [];      
SPM.xCon(1).STAT            =   [];       
SPM.xCon(1).c               =   []; 
SPM.xCon(1).X0              =   []; 
SPM.xCon(1).iX0             =   [];
SPM.xCon(1).X1o             =   [];
SPM.xCon(1).eidf            =   [];  
SPM.xCon(1).Vcon.fname      =   [];
SPM.xCon(1).Vcon.dim        =   [];
SPM.xCon(1).Vcon.mat        =   [];
SPM.xCon(1).Vspm.fname      =   [];           
SPM.xCon(1).Vspm.dim        =   [];  
SPM.xCon(1).Vspm.mat        =   [];           
SPM.xCon(1).Vspm.pinfo      =   [];       
SPM.xCon(1).Vspm.descrip    =   [];
SPM.xCon(1).Vspm.n          =   [];
SPM.xCon(1).Vspm.private    =   []; 

SPM.Vbeta                   =   [];   
SPM.VResMS                  =   [];   
SPM.VM                      =   [];
%---------------------------------%

return
