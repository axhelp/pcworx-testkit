(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: TestKit
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK GetTestResult

(*Group:Inputs*)


VAR_INPUT
	xEnabled :	BOOL;
	strTestName :	STRING_512;
	strExpected :	STRING_512;
	strActual :	STRING_512;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	Result :	udtTestItemResult;
END_VAR


(*@KEY@: WORKSHEET
NAME: GetTestResult
IEC_LANGUAGE: ST
*)
Result.strName					:= strTestName;
Result.strMessage				:= '';
Result.xEnabled					:= FALSE;
Result.xExecuted				:= FALSE;
Result.xFailed					:= FALSE;


IF xEnabled THEN
	Result.xEnabled				:= xEnabled;

	IF EQ_STRING(strActual, strExpected) THEN
	    Result.xFailed   		:= FALSE;
	    Result.strMessage 		:= 'PASS';

	ELSE
	    Result.xFailed			:= TRUE;

	    Result.strMessage		:= '';
	    Result.strMessage		:= CONCAT(Result.strMessage, 'FAIL. Expected: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, strExpected);
	    Result.strMessage		:= CONCAT(Result.strMessage, '. Actual: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, strActual);
	END_IF;

	Result.xExecuted			:= TRUE;
END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
