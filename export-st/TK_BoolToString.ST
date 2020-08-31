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
FUNCTION_BLOCK TK_BoolToString

(*Group:Inputs*)


VAR_INPUT
	xValue :	BOOL;
END_VAR


VAR_OUTPUT
	strOutput :	STRING_512;
END_VAR


(*@KEY@: WORKSHEET
NAME: TK_BoolToString
IEC_LANGUAGE: ST
*)
IF xValue THEN
    strOutput    := 'true';
ELSE
    strOutput    := 'false';
END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
