(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Debug
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK Console

(*Group:Default*)


VAR_EXTERNAL
	PLC_SYS_TICK_CNT :	DINT;(*Number of system ticks*)
END_VAR


VAR
	strDelimeter :	STRING;
END_VAR


VAR_INPUT
	strSource :	STRING;
	strMessage :	STRING;
END_VAR


VAR_EXTERNAL
	udtConsole :	udtConsole;
END_VAR


VAR
	strConsole :	STRING;
	iConsoleCounter :	INT;
END_VAR


(*@KEY@: WORKSHEET
NAME: Console
IEC_LANGUAGE: ST
*)
strDelimeter						:= ';';

strConsole							:= DINT_TO_STRING(PLC_SYS_TICK_CNT, '%d');
strConsole							:= CONCAT(strConsole, strDelimeter);

strConsole							:= CONCAT(strConsole, strSource);
strConsole							:= CONCAT(strConsole, strDelimeter);

strConsole							:= CONCAT(strConsole, strMessage);

IF udtConsole.iCounter >= 1000 
THEN
	iConsoleCounter					:= 0;
ELSE
	iConsoleCounter					:= udtConsole.iCounter + 1;
END_IF;

udtConsole.arrData[iConsoleCounter] := strConsole;
udtConsole.iCounter					:= iConsoleCounter;
(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
