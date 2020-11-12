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
PROGRAM IB_IL_RS_UNI

(*Group:Master*)


VAR
	MB_IL_UNI07_Master :	MB_IL_UNI07_Master_7;
	xActivateMaster :	BOOL := TRUE;
	xResetMaster :	BOOL;
	MB_RTU_FC3 :	MB_RTU_FC3_7;
	xSendRequest :	BOOL;
	iDataCount :	INT := 1;
	uiStartAddress :	UINT := UINT#1;
	xEnablePoll :	BOOL := TRUE;
	arrReadData :	arrModbus2_W_1_125;
	udtMbDataMaster :	udtModbus2_Data;
	arrInputAddressMaster :	MB2_RSUNI_ARR_B_1_14;
	arrOutputAddressMaster :	MB2_RSUNI_ARR_B_1_14;
	iRegisterValue01 :	INT;
	xDoneFC3 :	BOOL;
	xErrorFC3 :	BOOL;
	wDiagCodeFC3 :	WORD;
	wAddDiagCodeFC3 :	WORD;
END_VAR


(*Group:Slave*)


VAR
	MB_IL_UNI07_Slave :	MB_IL_UNI07_Slave_5;
	xActivateSlave :	BOOL := TRUE;
	uiSlaveAddress :	UINT := UINT#1;
	udtHoldingRegisters :	arrModbus2_w_0_1999;
	udtInputRegisters :	arrModbus2_w_2000_2999;
	udtOutputBits :	arrModbus2_x_3000_3999;
	udtInputBits :	arrModbus2_x_4000_4999;
	arrInputAddressSlave :	MB2_RSUNI_ARR_B_1_14;
	arrOutputAddressSlave :	MB2_RSUNI_ARR_B_1_14;
END_VAR


(*Group:Mock*)


VAR
	IL_UNI07_Slave :	IL_UNI07;
	udtRS485Line :	udtRS485Frame;
	xDebug :	BOOL;
	IB_IL_RS_UNI_07_Master :	IL_UNI07;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	RTC_SECONDS :	INT;(*System time (seconds)*)
END_VAR


(*@KEY@: WORKSHEET
NAME: Master
IEC_LANGUAGE: ST
*)
(*
MB_Master block sends data to 
mocked IB IL RS UNI function block instead of Process data
*)

MB_IL_UNI07_Master.xActivate			:= xActivateMaster;
MB_IL_UNI07_Master.bSelectMode			:= BYTE#01;
MB_IL_UNI07_Master.diBaudrate			:= DINT#9600;
MB_IL_UNI07_Master.wDataWidth			:= WORD#4;
MB_IL_UNI07_Master.tTimeout				:= T#30s;
MB_IL_UNI07_Master.xReset				:= xResetMaster;
MB_IL_UNI07_Master.udtMBData			:= udtMbDataMaster;
MB_IL_UNI07_Master.arrInputAddress		:= arrInputAddressMaster;
MB_IL_UNI07_Master.arrOutputAddress		:= arrOutputAddressMaster;

MB_IL_UNI07_Master();

udtMbDataMaster							:= MB_IL_UNI07_Master.udtMBData;
arrInputAddressMaster					:= MB_IL_UNI07_Master.arrInputAddress;
arrOutputAddressMaster					:= MB_IL_UNI07_Master.arrOutputAddress;

(*	FC3 = Read multiple registers *)
MB_RTU_FC3.xActivate					:= MB_IL_UNI07_Master.xActive;
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

(*	IB IL RS UNI (Proceess data 7 words) software replacement *)
IB_IL_RS_UNI_07_Master.xConsoleLog		:= xDebug;
IB_IL_RS_UNI_07_Master.strConsoleId		:= 'MAS';
IB_IL_RS_UNI_07_Master.udtRS485Line		:= udtRS485Line;
IB_IL_RS_UNI_07_Master.arrInputAddress	:= arrOutputAddressMaster;
IB_IL_RS_UNI_07_Master.arrOutputAddress	:= arrInputAddressMaster;

IB_IL_RS_UNI_07_Master();

udtRS485Line							:= IB_IL_RS_UNI_07_Master.udtRS485Line;
arrOutputAddressMaster					:= IB_IL_RS_UNI_07_Master.arrInputAddress;
arrInputAddressMaster					:= IB_IL_RS_UNI_07_Master.arrOutputAddress;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Slave
IEC_LANGUAGE: ST
*)
(*	IB IL RS UNI (Proceess data 7 words) software replacement *)
IL_UNI07_Slave.xConsoleLog				:= xDebug;
IL_UNI07_Slave.strConsoleId				:= 'SLV';
IL_UNI07_Slave.udtRS485Line				:= udtRS485Line;
IL_UNI07_Slave.arrInputAddress			:= arrOutputAddressSlave;
IL_UNI07_Slave.arrOutputAddress			:= arrInputAddressSlave;

IL_UNI07_Slave();

udtRS485Line							:= IL_UNI07_Slave.udtRS485Line;
arrOutputAddressSlave					:= IL_UNI07_Slave.arrInputAddress;
arrInputAddressSlave					:= IL_UNI07_Slave.arrOutputAddress;

(*
MB_Master block receives data from 
mocked IB IL RS UNI function block instead of Process data
*)

MB_IL_UNI07_Slave.xActivate				:= xActivateSlave;
MB_IL_UNI07_Slave.bSelectMode			:= BYTE#01;
MB_IL_UNI07_Slave.diBaudrate			:= DINT#9600;
MB_IL_UNI07_Slave.wDataWidth			:= WORD#4;
MB_IL_UNI07_Slave.uiSlaveAddress		:= uiSlaveAddress;
MB_IL_UNI07_Slave.udtHoldingRegisters	:= udtHoldingRegisters;
MB_IL_UNI07_Slave.udtInputRegisters		:= udtInputRegisters;
MB_IL_UNI07_Slave.udtOutputBits			:= udtOutputBits;
MB_IL_UNI07_Slave.udtInputBits			:= udtInputBits;
MB_IL_UNI07_Slave.arrInputAddress		:= arrInputAddressSlave;
MB_IL_UNI07_Slave.arrOutputAddress		:= arrOutputAddressSlave;

MB_IL_UNI07_Slave();

udtHoldingRegisters         			:= MB_IL_UNI07_Slave.udtHoldingRegisters;
udtInputRegisters           			:= MB_IL_UNI07_Slave.udtInputRegisters;		
udtOutputBits           				:= MB_IL_UNI07_Slave.udtOutputBits;
udtInputBits            				:= MB_IL_UNI07_Slave.udtInputBits;
arrInputAddressSlave            		:= MB_IL_UNI07_Slave.arrInputAddress;
arrOutputAddressSlave           		:= MB_IL_UNI07_Slave.arrOutputAddress;

(*	Fill in register value *)
udtHoldingRegisters[1]					:= INT_TO_WORD(RTC_SECONDS);

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
