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
FUNCTION_BLOCK GetTestCaseResult

(*Group:Inputs*)


VAR_INPUT
	Tests :	arrTestItemsResults;
END_VAR


VAR
	iTestItemNum :	INT;
	Test :	udtTestItemResult;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	Result :	udtTestCaseResult;
END_VAR


(*@KEY@: WORKSHEET
NAME: GetTestCaseResult
IEC_LANGUAGE: ST
*)
Result.Summary.Result.strMessage			:= '';
Result.Summary.Result.xExecuted				:= TRUE;
Result.Summary.Result.xFailed				:= FALSE;
Result.Summary.Stats.iFailed				:= 0;
Result.Summary.Stats.iPassed				:= 0;
Result.Summary.Stats.iTotal					:= 0;


FOR iTestItemNum := 0 TO 49 DO
	Test									:= Tests[iTestItemNum];

	IF Tests[iTestItemNum].xEnabled THEN
		Result.Summary.Stats.iTotal			:= Result.Summary.Stats.iTotal + 1;
		Result.Summary.Result.xExecuted		:= Result.Summary.Result.xExecuted AND Test.xExecuted;

		IF Test.xExecuted THEN
			Result.Summary.Result.xFailed	:= Result.Summary.Result.xFailed OR Test.xFailed;

			IF Test.xFailed THEN
				Result.Summary.Stats.iFailed:= Result.Summary.Stats.iFailed + 1;
			ELSE
				Result.Summary.Stats.iPassed:= Result.Summary.Stats.iPassed + 1;
			END_IF;
		END_IF;
	END_IF;
END_FOR;


Result.Tests								:= Tests;
Result.Summary.Result.strMessage			:= '';

Result.Summary.Result.strMessage			:= CONCAT(Result.Summary.Result.strMessage, 'Passed: ');
Result.Summary.Result.strMessage			:= CONCAT(
													Result.Summary.Result.strMessage, 
													INT_TO_STRING(Result.Summary.Stats.iPassed, '%d')
												);
Result.Summary.Result.strMessage			:= CONCAT(Result.Summary.Result.strMessage, '/');
Result.Summary.Result.strMessage			:= CONCAT(
													Result.Summary.Result.strMessage, 
													INT_TO_STRING(Result.Summary.Stats.iTotal, '%d')
												);

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
