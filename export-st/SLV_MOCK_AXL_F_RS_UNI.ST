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
PROGRAM SLV_MOCK_AXL_F_RS_UNI

(*Group:Mock*)


VAR
	AXL_F_RSUNI_Mock_Slave :	AXL_F_RSUNI;
	xDebug :	BOOL;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	RTC_SECONDS :	INT;(*System time (seconds)*)
	udtRS485LineAXL :	udtRS485Frame;
	arrInputAddressSlave :	MB2_AXL_RSUNI2_ARR_B_0_19;
	arrOutputAddressSlave :	MB2_AXL_RSUNI2_ARR_B_0_19;
END_VAR


(*@KEY@: WORKSHEET
NAME: Slave
IEC_LANGUAGE: ST
*)
(*	IB IL RS UNI (Proceess data 7 words) software replacement *)
AXL_F_RSUNI_Mock_Slave.xConsoleLog				:= xDebug;
AXL_F_RSUNI_Mock_Slave.strConsoleId				:= 'SLV';
AXL_F_RSUNI_Mock_Slave.udtRS485Line				:= udtRS485LineAXL;
AXL_F_RSUNI_Mock_Slave.arrInputAddress			:= arrOutputAddressSlave;
AXL_F_RSUNI_Mock_Slave.arrOutputAddress			:= arrInputAddressSlave;

AXL_F_RSUNI_Mock_Slave();

udtRS485LineAXL							:= AXL_F_RSUNI_Mock_Slave.udtRS485Line;
arrOutputAddressSlave					:= AXL_F_RSUNI_Mock_Slave.arrInputAddress;
arrInputAddressSlave					:= AXL_F_RSUNI_Mock_Slave.arrOutputAddress;

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
