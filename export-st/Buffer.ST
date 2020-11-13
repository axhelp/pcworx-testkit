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
FUNCTION_BLOCK Buffer

(*Group:Inputs*)


VAR_INPUT
	xPull :	BOOL;
	xPush :	BOOL;
	xClear :	BOOL;
	bPushByte :	BYTE;
END_VAR


(*Group:Inouts*)


VAR_IN_OUT
	udtBuffer :	udtAXL_F_RS_UNI_Buffer;
END_VAR


VAR
	MAX_LENGTH :	INT;
END_VAR


VAR_OUTPUT
	xError :	BOOL;
	xDone :	BOOL;
END_VAR


VAR
	iNextIndex :	INT;
END_VAR


VAR_OUTPUT
	xEmpty :	BOOL;
	xFull :	BOOL;
END_VAR


VAR
	iPulledIndex :	INT;
	iIndex :	INT;
END_VAR


(*Group:Outputs*)


VAR_OUTPUT
	bPulledByte :	BYTE;
END_VAR


(*Group:Internal*)


(*@KEY@: WORKSHEET
NAME: Buffer
IEC_LANGUAGE: ST
*)
MAX_LENGTH                              := 4096;
xError                                  := FALSE;
xDone                                   := FALSE;

(* Push to buffer *)
IF xPush THEN

    iNextIndex                          := udtBuffer.iLength;
    IF iNextIndex >= MAX_LENGTH THEN
        xError                          := TRUE;
    ELSE
        udtBuffer.arrData[iNextIndex]   := bPushByte;
        udtBuffer.iLength               := udtBuffer.iLength + 1;
        xDone                           := TRUE;
    END_IF;

ELSIF xPull THEN
    IF udtBuffer.iLength <= 0 THEN
        xError                          := TRUE;
    ELSE
        bPulledByte                     := udtBuffer.arrData[0];

        FOR iIndex := 0 TO udtBuffer.iLength - 1 DO
            iNextIndex                  := iIndex + 1;
            udtBuffer.arrData[iIndex]   := udtBuffer.arrData[iNextIndex];
        END_FOR;

        udtBuffer.iLength               := udtBuffer.iLength - 1;
        xDone                           := TRUE;
    END_IF;

ELSIF xClear THEN
    FOR iIndex := 0 TO udtBuffer.iLength - 1 DO
        iNextIndex                      := iIndex + 1;
        udtBuffer.arrData[iIndex]       := BYTE#0;
    END_FOR;
    udtBuffer.iLength                   := 0;
END_IF;

xEmpty                  := udtBuffer.iLength <= 0;
xFull                   := udtBuffer.iLength = MAX_LENGTH;

udtBuffer.xEmpty        := xEmpty;
udtBuffer.xFull         := xFull;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
