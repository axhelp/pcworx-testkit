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
FUNCTION_BLOCK WaitTestResult

(*Group:Inputs*)


VAR_INPUT
	xEnabled :	BOOL;
	xDoNotThrow :	BOOL;
	xPermission :	BOOL;
	xExternalFail :	BOOL;
	xExternalFailMessage :	STRING_512;
	strTestName :	STRING_512;
	strWaitForValue :	STRING_512;
	strActual :	STRING_512;
	tTimeout :	TIME;
END_VAR


(*Group:Instances*)


VAR
	TON_TIMEOUT :	TON;
	iDummy :	INT;
END_VAR


(*Group:Internal*)


VAR
	xTimeout :	BOOL;
	xEnableTimeout :	BOOL;
END_VAR


(*Group:Inouts*)


VAR_IN_OUT
	Result :	udtTestItemResult;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	tEt :	TIME;
END_VAR


(*@KEY@: WORKSHEET
NAME: WaitTestResult
IEC_LANGUAGE: ST
*)
Result.strName					:= strTestName;
Result.strMessage				:= '';
Result.xEnabled					:= FALSE;
Result.xExecuted				:= FALSE;
Result.xFailed					:= FALSE;
xEnableTimeout					:= FALSE;


IF xEnabled THEN
	Result.xEnabled				:= xEnabled;
	Result.xPermission			:= xPermission;
	xEnableTimeout				:= TRUE;

	Result.strMessage			:= '';
    Result.strMessage 			:= CONCAT(Result.strMessage, 'Waiting');
	Result.strMessage			:= CONCAT(Result.strMessage, '. Elapsed: ');
    Result.strMessage			:= CONCAT(Result.strMessage, TIME_TO_STRING(TON_TIMEOUT.ET, '%u'));
	
	IF xExternalFail THEN
		Result.xFailed			:= TRUE;

	    Result.strMessage		:= '';
	    Result.strMessage		:= CONCAT(Result.strMessage, 'FAIL. External fail: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, xExternalFailMessage);

		Result.xExecuted		:= TRUE;
		xEnableTimeout			:= FALSE;

	ELSIF xTimeout THEN
	    Result.xFailed			:= TRUE;

	    Result.strMessage		:= '';
	    Result.strMessage		:= CONCAT(Result.strMessage, 'FAIL. Wait for: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, strWaitForValue);
	    Result.strMessage		:= CONCAT(Result.strMessage, '. Actual: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, strActual);
		Result.strMessage		:= CONCAT(Result.strMessage, '. Timeout: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, TIME_TO_STRING(tTimeout, '%u'));

		Result.xExecuted		:= TRUE;
		xEnableTimeout			:= FALSE;

	ELSIF EQ_STRING(strActual, strWaitForValue) THEN
	    Result.xFailed   		:= FALSE;

		Result.strMessage		:= '';
	    Result.strMessage 		:= CONCAT(Result.strMessage, 'PASS');
		Result.strMessage		:= CONCAT(Result.strMessage, '. Elapsed: ');
	    Result.strMessage		:= CONCAT(Result.strMessage, TIME_TO_STRING(TON_TIMEOUT.ET, '%u'));

		Result.xExecuted		:= TRUE;
		xEnableTimeout			:= FALSE;
	END_IF;
END_IF;

TON_TIMEOUT.IN					:= xEnableTimeout;
TON_TIMEOUT.PT					:= tTimeout;
TON_TIMEOUT();
xTimeout						:= TON_TIMEOUT.Q;
tEt								:= TON_TIMEOUT.ET;

IF Result.xFailed AND NOT xDoNotThrow THEN
	iDummy				:= 0 / 0;
END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
