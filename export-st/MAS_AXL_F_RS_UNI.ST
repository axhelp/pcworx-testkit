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
PROGRAM MAS_AXL_F_RS_UNI

(*Group:Master*)


VAR
	AXL_F_RSUNI_Master :	MB_AXL_F_RSUNI_Master_2;
	MB_RTU_FC3 :	MB_RTU_FC3_7;
	xActivateMaster :	BOOL := TRUE;
	xResetMaster :	BOOL;
	xSendRequest :	BOOL;
	iDataCount :	INT := 1;
	uiSlaveAddress :	UINT := UINT#1;
	uiStartAddress :	UINT := UINT#1;
	xEnablePoll :	BOOL := TRUE;
	arrReadData :	arrModbus2_W_1_125;
	udtMbDataMaster :	udtModbus2_Data;
	iRegisterValue01 :	INT;
	xDoneFC3 :	BOOL;
	xErrorFC3 :	BOOL;
	wDiagCodeFC3 :	WORD;
	wAddDiagCodeFC3 :	WORD;
	uiRequestsCounter :	UINT;
	uiResponsesCounter :	UINT;
	diDoneCounter :	DINT;
	diErrorCounter :	DINT;
END_VAR


(*Group:Mock*)
(*Group:Global*)


VAR_EXTERNAL
	arrInputAddressMaster :	MB2_AXL_RSUNI2_ARR_B_0_19;
	arrOutputAddressMaster :	MB2_AXL_RSUNI2_ARR_B_0_19;
END_VAR


(*@KEY@: WORKSHEET
NAME: Master
IEC_LANGUAGE: ST
*)
(*
MB_Master block sends data to 
mocked IB IL RS UNI function block instead of Process data
*)

AXL_F_RSUNI_Master.xActivate			:= xActivateMaster;
AXL_F_RSUNI_Master.tModbus_Timeout      := T#3s;
AXL_F_RSUNI_Master.tPD_Timeout          := T#3s;
AXL_F_RSUNI_Master.xReset				:= xResetMaster;
AXL_F_RSUNI_Master.udtMBData			:= udtMbDataMaster;
AXL_F_RSUNI_Master.arrInputPD           := arrInputAddressMaster;
AXL_F_RSUNI_Master.arrOutputPD          := arrOutputAddressMaster;

AXL_F_RSUNI_Master();

udtMbDataMaster							:= AXL_F_RSUNI_Master.udtMBData;
arrInputAddressMaster					:= AXL_F_RSUNI_Master.arrInputPD;
arrOutputAddressMaster					:= AXL_F_RSUNI_Master.arrOutputPD;
uiRequestsCounter                       := AXL_F_RSUNI_Master.uiRequestsCounter;
uiResponsesCounter                      := AXL_F_RSUNI_Master.uiResponsesCounter;

(*	FC3 = Read multiple registers *)
MB_RTU_FC3.xActivate					:= AXL_F_RSUNI_Master.xActive;
MB_RTU_FC3.xSendRequest					:= xSendRequest;
MB_RTU_FC3.xEnablePoll					:= xEnablePoll;
MB_RTU_FC3.tPollInterval				:= t#200ms;
MB_RTU_FC3.uiSlaveAddress				:= uiSlaveAddress;
MB_RTU_FC3.uiStartAddress				:= uiStartAddress;
MB_RTU_FC3.iDataCount					:= iDataCount;
MB_RTU_FC3.arrReadData					:= arrReadData;
MB_RTU_FC3.udtMbData					:= udtMbDataMaster;

MB_RTU_FC3();

xDoneFC3								:= MB_RTU_FC3.xDone;
xErrorFC3								:= MB_RTU_FC3.xError;
wDiagCodeFC3							:= MB_RTU_FC3.wDiagCode;
wAddDiagCodeFC3							:= MB_RTU_FC3.wAddDiagCode;

arrReadData								:= MB_RTU_FC3.arrReadData;
udtMbDataMaster							:= MB_RTU_FC3.udtMbData;

(*	Readed value *)
iRegisterValue01						:= WORD_TO_INT(arrReadData[1]);

IF xDoneFC3 THEN
    diDoneCounter                       := diDoneCounter + DINT#1;
END_IF;

IF xErrorFC3 THEN
    diErrorCounter                      := diErrorCounter + DINT#1;
END_IF;

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
