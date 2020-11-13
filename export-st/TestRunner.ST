(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Tests
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
PROGRAM TestRunner

(*Group:Default*)


VAR
	Buffer_Test :	Buffer_Test;
	xAllTestsExecuted :	BOOL;
	xAnyTestFailed :	BOOL;
	xNextTestPermssion :	BOOL;
	BufferTestResult :	udtTestCaseResult;
END_VAR


(*@KEY@: WORKSHEET
NAME: TestRunner
IEC_LANGUAGE: ST
*)
(*	Test case instances *)
xNextTestPermssion							:= TRUE;

Buffer_Test.xPermission                     := xNextTestPermssion;
Buffer_Test();
BufferTestResult                            := Buffer_Test.Result;
xNextTestPermssion							:= BufferTestResult.Summary.Result.xExecuted;


(*	Executed *)
xAllTestsExecuted							:= 	(
													BufferTestResult.Summary.Result.xExecuted
												);

(*	Faled *)
xAnyTestFailed								:= 	(
													BufferTestResult.Summary.Result.xFailed
												);


(*	Messages	*)
BufferTestResult.Summary.Result.strMessage	:= 	(
													BufferTestResult.Summary.Result.strMessage
												);

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
