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
FUNCTION_BLOCK TK_RealToString

(*Group:Inputs*)


VAR_INPUT
	rValue :	REAL;
	uiPrecision :	UINT;
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
NAME: TK_RealToString
IEC_LANGUAGE: ST
*)
IF uiPrecision <= UINT#0 THEN
	uiPrecision			:= UINT#2;
END_IF;

strFormatString			:= CONCAT('%.', UINT_TO_STRING(uiPrecision, '%u'));
strFormatString			:= CONCAT(strFormatString, 'f');

strOutput				:= REAL_TO_STRING(rValue, strFormatString);

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
