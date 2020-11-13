(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Serial
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK Buffer_Test

(*Group:Inputa*)


VAR_INPUT
	xPermission :	BOOL;
END_VAR


(*Group:Internal*)


VAR
	strTestName :	STRING_512;
	strActualValue :	STRING_512;
	strExpectedValue :	STRING_512;
	xTestCaseExecuted :	BOOL;
	arrTests :	arrTestItemsResults;
	iTestIndex :	INT;
	iTestNextIndex :	INT;
	xInitFirst :	BOOL;
	xTestFailed :	BOOL;
	xAllBoilersUp :	BOOL;
	xAddBoilersDown :	BOOL;
	iBoilerNum :	INT;
	rIntegralRemembered :	REAL;
	rMaxTempIntegral :	REAL;
	rMinTempIntegral :	REAL;
END_VAR


(*Group:Outputs*)


VAR_OUTPUT
	Result :	udtTestCaseResult;
END_VAR


(*Group:Instances*)


VAR
	GetTestCaseResultInstance :	GetTestCaseResult;
	GetTestResultInstance :	GetTestResult;
	WaitTestResultInstance :	WaitTestResult;
	TK_BoolToStringInstance :	TK_BoolToString;
	TK_IntToStringInstance :	TK_IntToString;
	TK_RealToStringInstance :	TK_RealToString;
	BufferInstance :	Buffer;
	udtBuffer :	udtAXL_F_RS_UNI_Buffer;
END_VAR


(*@KEY@: WORKSHEET
NAME: Init
IEC_LANGUAGE: ST
*)
(*==============================================================================================================================*)
(*==============================================================================================================================*)

iTestIndex											:= -1;

(*==============================================================================================================================*)
(*==============================================================================================================================*)

IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	IF NOT xInitFirst THEN
		xInitFirst	:= TRUE;
	END_IF;
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Test_Push
IEC_LANGUAGE: ST
*)
IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	strTestName										:= 'Should push to Buffer';
	iTestIndex										:= iTestIndex + 1;
	arrTests[iTestIndex].xEnabled					:= TRUE;
	arrTests[iTestIndex].xPermission				:= TRUE;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	IF arrTests[iTestIndex].xEnabled AND NOT arrTests[iTestIndex].xExecuted AND arrTests[iTestIndex].xPermission THEN

        udtBuffer.arrData[0]                        := BYTE#1;
        udtBuffer.arrData[1]                        := BYTE#2;
        udtBuffer.arrData[2]                        := BYTE#0;
        udtBuffer.iLength                           := 2;
        BufferInstance.xPush                        := TRUE;
        BufferInstance.xPull                        := FALSE;
        BufferInstance.bPushByte                    := BYTE#99;
        BufferInstance.udtBuffer                    := udtBuffer;
        BufferInstance();
        udtBuffer                                   := BufferInstance.udtBuffer;

        TK_IntToStringInstance.iValue               := BYTE_TO_INT(udtBuffer.arrData[2]);
        TK_IntToStringInstance();
        
        TK_BoolToStringInstance.xValue              := FALSE;
        TK_BoolToStringInstance();

        GetTestResultInstance.xEnabled              := TRUE;
        GetTestResultInstance.strTestName           := strTestName;
        GetTestResultInstance.strExpected           := '99';
        GetTestResultInstance.strActual             := TK_IntToStringInstance.strOutput;
        GetTestResultInstance.Result                := arrTests[iTestIndex];
        GetTestResultInstance();

        arrTests[iTestIndex]						:= GetTestResultInstance.Result;

	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
		IF arrTests[iTestIndex].xExecuted THEN
			(*	Permssion for next test	*)
			iTestNextIndex								:= iTestIndex + 1;
			arrTests[iTestNextIndex].xPermission		:= TRUE;

			(*	After every test *)

		END_IF;
	ELSE 
		(*	Permssion for next test	*)
		iTestNextIndex								:= iTestIndex + 1;
		arrTests[iTestNextIndex].xPermission		:= arrTests[iTestIndex].xPermission;
	END_IF;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Test_Push_Increment_Leng
IEC_LANGUAGE: ST
*)
IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	strTestName										:= '1.0.1 Should increment legth while push to Buffer';
	iTestIndex										:= iTestIndex + 1;
	arrTests[iTestIndex].xEnabled					:= TRUE;
	arrTests[iTestIndex].xPermission				:= TRUE;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	IF arrTests[iTestIndex].xEnabled AND NOT arrTests[iTestIndex].xExecuted AND arrTests[iTestIndex].xPermission THEN

        udtBuffer.arrData[0]                        := BYTE#1;
        udtBuffer.arrData[1]                        := BYTE#2;
        udtBuffer.arrData[2]                        := BYTE#0;
        udtBuffer.iLength                           := 2;
        BufferInstance.xPush                        := TRUE;
        BufferInstance.xPull                        := FALSE;
        BufferInstance.bPushByte                    := BYTE#99;
        BufferInstance.udtBuffer                    := udtBuffer;
        BufferInstance();
        udtBuffer                                   := BufferInstance.udtBuffer;

        TK_IntToStringInstance.iValue               := udtBuffer.iLength;
        TK_IntToStringInstance();
        
        TK_BoolToStringInstance.xValue              := FALSE;
        TK_BoolToStringInstance();

        GetTestResultInstance.xEnabled              := TRUE;
        GetTestResultInstance.strTestName           := strTestName;
        GetTestResultInstance.strExpected           := '3';
        GetTestResultInstance.strActual             := TK_IntToStringInstance.strOutput;
        GetTestResultInstance.Result                := arrTests[iTestIndex];
        GetTestResultInstance();

        arrTests[iTestIndex]						:= GetTestResultInstance.Result;

	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
		IF arrTests[iTestIndex].xExecuted THEN
			(*	Permssion for next test	*)
			iTestNextIndex								:= iTestIndex + 1;
			arrTests[iTestNextIndex].xPermission		:= TRUE;

			(*	After every test *)

		END_IF;
	ELSE 
		(*	Permssion for next test	*)
		iTestNextIndex								:= iTestIndex + 1;
		arrTests[iTestNextIndex].xPermission		:= arrTests[iTestIndex].xPermission;
	END_IF;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Test_Pull
IEC_LANGUAGE: ST
*)
IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	strTestName										:= 'Should pull from Buffer';
	iTestIndex										:= iTestIndex + 1;
	arrTests[iTestIndex].xEnabled					:= TRUE;
	arrTests[iTestIndex].xPermission				:= TRUE;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	IF arrTests[iTestIndex].xEnabled AND NOT arrTests[iTestIndex].xExecuted AND arrTests[iTestIndex].xPermission THEN

        udtBuffer.arrData[0]                        := BYTE#99;
        udtBuffer.arrData[1]                        := BYTE#2;
        udtBuffer.arrData[2]                        := BYTE#0;
        udtBuffer.iLength                           := 2;
        BufferInstance.xPush                        := FALSE;
        BufferInstance.xPull                        := TRUE;
        BufferInstance.bPushByte                    := BYTE#99;
        BufferInstance.udtBuffer                    := udtBuffer;
        BufferInstance();
        udtBuffer                                   := BufferInstance.udtBuffer;

        TK_IntToStringInstance.iValue               := BYTE_TO_INT(BufferInstance.bPulledByte);
        TK_IntToStringInstance();
        
        TK_BoolToStringInstance.xValue              := FALSE;
        TK_BoolToStringInstance();

        GetTestResultInstance.xEnabled              := TRUE;
        GetTestResultInstance.strTestName           := strTestName;
        GetTestResultInstance.strExpected           := '99';
        GetTestResultInstance.strActual             := TK_IntToStringInstance.strOutput;
        GetTestResultInstance.Result                := arrTests[iTestIndex];
        GetTestResultInstance();

        arrTests[iTestIndex]						:= GetTestResultInstance.Result;

	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
		IF arrTests[iTestIndex].xExecuted THEN
			(*	Permssion for next test	*)
			iTestNextIndex								:= iTestIndex + 1;
			arrTests[iTestNextIndex].xPermission		:= TRUE;

			(*	After every test *)

		END_IF;
	ELSE 
		(*	Permssion for next test	*)
		iTestNextIndex								:= iTestIndex + 1;
		arrTests[iTestNextIndex].xPermission		:= arrTests[iTestIndex].xPermission;
	END_IF;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Test_Pull_Decrement_Leng
IEC_LANGUAGE: ST
*)
IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	strTestName										:= 'Should decrement length while pull from Buffer';
	iTestIndex										:= iTestIndex + 1;
	arrTests[iTestIndex].xEnabled					:= TRUE;
	arrTests[iTestIndex].xPermission				:= TRUE;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	IF arrTests[iTestIndex].xEnabled AND NOT arrTests[iTestIndex].xExecuted AND arrTests[iTestIndex].xPermission THEN

        udtBuffer.arrData[0]                        := BYTE#99;
        udtBuffer.arrData[1]                        := BYTE#2;
        udtBuffer.arrData[2]                        := BYTE#0;
        udtBuffer.iLength                           := 2;
        BufferInstance.xPush                        := FALSE;
        BufferInstance.xPull                        := TRUE;
        BufferInstance.bPushByte                    := BYTE#99;
        BufferInstance.udtBuffer                    := udtBuffer;
        BufferInstance();
        udtBuffer                                   := BufferInstance.udtBuffer;

        TK_IntToStringInstance.iValue               := BYTE_TO_INT(BufferInstance.bPulledByte);
        TK_IntToStringInstance();
        
        TK_BoolToStringInstance.xValue              := FALSE;
        TK_BoolToStringInstance();

        GetTestResultInstance.xEnabled              := TRUE;
        GetTestResultInstance.strTestName           := strTestName;
        GetTestResultInstance.strExpected           := '99';
        GetTestResultInstance.strActual             := TK_IntToStringInstance.strOutput;
        GetTestResultInstance.Result                := arrTests[iTestIndex];
        GetTestResultInstance();

        arrTests[iTestIndex]						:= GetTestResultInstance.Result;

	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
		IF arrTests[iTestIndex].xExecuted THEN
			(*	Permssion for next test	*)
			iTestNextIndex								:= iTestIndex + 1;
			arrTests[iTestNextIndex].xPermission		:= TRUE;

			(*	After every test *)

		END_IF;
	ELSE 
		(*	Permssion for next test	*)
		iTestNextIndex								:= iTestIndex + 1;
		arrTests[iTestNextIndex].xPermission		:= arrTests[iTestIndex].xPermission;
	END_IF;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Results
IEC_LANGUAGE: ST
*)
IF NOT Result.Summary.Result.xExecuted AND xPermission THEN
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
	GetTestCaseResultInstance.Tests					:= arrTests;
	GetTestCaseResultInstance();
	Result											:= GetTestCaseResultInstance.Result;
	(*==========================================================================================================================*)
	(*==========================================================================================================================*)
END_IF;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Buffer_Test
IEC_LANGUAGE: ST
*)
(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
