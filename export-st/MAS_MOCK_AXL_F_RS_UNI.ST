(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Examples
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
PROGRAM MAS_MOCK_AXL_F_RS_UNI

(*Group:Mock*)


VAR
	AXL_F_RSUNI_Mock_Master :	AXL_F_RSUNI;
	xDebug :	BOOL;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	udtRS485LineAXL :	udtRS485Frame;
	arrInputAddressMaster :	MB2_AXL_RSUNI2_ARR_B_0_19;
	arrOutputAddressMaster :	MB2_AXL_RSUNI2_ARR_B_0_19;
END_VAR


(*@KEY@: WORKSHEET
NAME: Master
IEC_LANGUAGE: ST
*)
(*	AXL F RS UNI software replacement *)
AXL_F_RSUNI_Mock_Master.xConsoleLog		:= xDebug;
AXL_F_RSUNI_Mock_Master.strConsoleId	:= 'MAS';
AXL_F_RSUNI_Mock_Master.udtRS485Line	:= udtRS485LineAXL;
AXL_F_RSUNI_Mock_Master.arrInputAddress	:= arrOutputAddressMaster;
AXL_F_RSUNI_Mock_Master.arrOutputAddress:= arrInputAddressMaster;

AXL_F_RSUNI_Mock_Master();


udtRS485LineAXL							:= AXL_F_RSUNI_Mock_Master.udtRS485Line;
arrOutputAddressMaster					:= AXL_F_RSUNI_Mock_Master.arrInputAddress;
arrInputAddressMaster					:= AXL_F_RSUNI_Mock_Master.arrOutputAddress;

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
