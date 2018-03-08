WFU TOOLBOXES BETA RELEASE NOTES

12/08/05
Version 1.0
- initial release

01/09/06
Version 1.1
- contrast manager slice by slice i/o to allow bigger data sets
- new regression code
- FWE now a viable SPM choice for correlation
- 01/04/06 WFU_PickAtlas version included in wfu_toolboxes

04/10/06
Version 1.2
- SPM2, SPM5 compatibility
- all file prefixes set to wfu_bpm
- additional notes, comments
- 02/24/06 WFU_PickAtlas version included in wfu_toolboxes

06/29/06
Version 1.3
- added ANCOVA with ROI
- added correlation with ROI
- added regression choice of F or +/- T
- removed contrast manager constant d
- speeded up analysis and contrast manager
- modified spm_est_smoothness function:
     removed Inf values from SPM's estimation of smoothness
     and created maskInf image to show location of values removed

08/01/06
Version 1.4
- added homologous correlation field
- 08/01/06 WFU_PickAtlas version included in wfu_toolboxes

10/02/06
Version 1.5
- added partial correlation
- added spm insertion tool choice of correlation inference
      (homologous correlation field or T field)
- misc updates
- 09/28/06 WFU_PickAtlas version included in wfu_toolboxes

10/20/06
Version 1.5b
- README files renamed and inserted into PDF document
- modified wfu_insert_map to remove +2 on map.erdf for
  	homologous correlation field
- commented out display of two messages in compatibility code
- posted to the ANSIR lab web site

01/11/07
Version 1.5c
- 01/09/07 WFU_PickAtlas version included in wfu_toolboxes
- updated the NEUROIMAGE reference

02/14/07, 03/02/07
Version 1.5d
- 02/13/07, /03/02/07 WFU_PickAtlas version included in wfu_toolboxes
- modified wfu_startup.m to reference lower case wfu_pickatlas dir name
