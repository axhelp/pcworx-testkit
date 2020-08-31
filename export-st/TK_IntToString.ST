(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Helpers
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK TK_IntToString

(*Group:Inputs*)


VAR_INPUT
	iValue :	INT;
END_VAR


(*Group:Internal*)


VAR
	strFormatString :	STRING;
END_VAR


(*Group:Outputs*)


VAR_OUTPUT
	strOutput :	STRING;
END_VAR


(*@KEY@: WORKSHEET
NAME: TK_IntToString
IEC_LANGUAGE: ST
*)
strOutput					:= INT_TO_STRING(iValue, '%d');

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
