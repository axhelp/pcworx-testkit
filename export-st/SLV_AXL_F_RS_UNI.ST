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
PROGRAM SLV_AXL_F_RS_UNI

(*Group:Slave*)


VAR
	AXL_F_RSUNI_Slave :	MB_AXL_F_RSUNI_Slave_1;
	xActivateSlave :	BOOL := TRUE;
	uiSlaveAddress :	UINT := UINT#1;
	udtHoldingRegisters :	arrModbus2_w_0_1999;
	udtInputRegisters :	arrModbus2_w_2000_2999;
	udtOutputBits :	arrModbus2_x_3000_3999;
	udtInputBits :	arrModbus2_x_4000_4999;
	iRegNum :	INT;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	RTC_SECONDS :	INT;(*System time (seconds)*)
	arrInputAddressSlave :	MB2_AXL_RSUNI2_ARR_B_0_19;
	arrOutputAddressSlave :	MB2_AXL_RSUNI2_ARR_B_0_19;
END_VAR


(*@KEY@: WORKSHEET
NAME: Slave
IEC_LANGUAGE: ST
*)
(* Slave function block *)

AXL_F_RSUNI_Slave.xActivate				:= xActivateSlave;
AXL_F_RSUNI_Slave.uiSlaveAddress		:= uiSlaveAddress;
AXL_F_RSUNI_Slave.udtHoldingRegisters	:= udtHoldingRegisters;
AXL_F_RSUNI_Slave.udtInputRegisters		:= udtInputRegisters;
AXL_F_RSUNI_Slave.udtOutputBits			:= udtOutputBits;
AXL_F_RSUNI_Slave.udtInputBits			:= udtInputBits;
AXL_F_RSUNI_Slave.arrInputData          := arrInputAddressSlave;
AXL_F_RSUNI_Slave.arrOutputData         := arrOutputAddressSlave;

AXL_F_RSUNI_Slave();

udtHoldingRegisters         			:= AXL_F_RSUNI_Slave.udtHoldingRegisters;
udtInputRegisters           			:= AXL_F_RSUNI_Slave.udtInputRegisters;		
udtOutputBits           				:= AXL_F_RSUNI_Slave.udtOutputBits;
udtInputBits            				:= AXL_F_RSUNI_Slave.udtInputBits;
arrInputAddressSlave            		:= AXL_F_RSUNI_Slave.arrInputData;
arrOutputAddressSlave           		:= AXL_F_RSUNI_Slave.arrOutputData;

(*	Fill in register value *)
FOR iRegNum := 1 TO 100 DO
    udtHoldingRegisters[iRegNum]		:= INT_TO_WORD(RTC_SECONDS + iRegNum);
END_FOR;

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
