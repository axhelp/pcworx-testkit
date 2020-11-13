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
FUNCTION_BLOCK AXL_F_RSUNI

(*Group:Inputs*)


VAR_INPUT
	xConsoleLog :	BOOL;
	strConsoleId :	STRING;
END_VAR


(*Group:Inouts*)


VAR_IN_OUT
	udtRS485Line :	udtAXL_F_RS_UNI_Buffer;
	arrInputAddress :	MB2_AXL_RSUNI2_ARR_B_0_19;(*Process Data Input*)
	arrOutputAddress :	MB2_AXL_RSUNI2_ARR_B_0_19;(*Process Data Output*)
END_VAR


(*Group:FB*)


VAR
	R_TRIG_xSending :	R_TRIG;
	Console :	Console;
END_VAR


(*Group:Internal*)


VAR
	udtBufferReceive :	udtAXL_F_RS_UNI_Buffer;
	udtBufferSend :	udtAXL_F_RS_UNI_Buffer;
	xSending :	BOOL;
	iByteNum :	INT;
	iBytesToCopy :	INT;
	bStatusBits :	BYTE;
	wNumberOfCharactersReceived :	WORD;
	iFirstAddressIndex :	INT;
	iLastAddressIndex :	INT;
	iAddressIndex :	INT;
	iFirstBufferIndex :	INT;
	iByteToCopy :	INT;
	iWordsToSend :	INT;
	arrInputAddressRememdered :	MB2_AXL_RSUNI2_ARR_B_0_19;(*Process Data Input*)
	udtRS485LineCopy :	udtAXL_F_RS_UNI_Buffer;
END_VAR


(*Group:Default*)


VAR
	bFillLevel :	BYTE;
	MAX_SEND_LENGTH :	INT;
	BufferHandler :	Buffer;
	MAX_RCV_LENGTH :	INT;
	xCommandChanged :	BOOL;
	iIndex :	INT;
	diCommandsCounter :	DINT;
	iBytesReceived :	INT;
	iBytesTransmitted :	INT;
	wWordsReceived :	WORD;
	wWordsTransmitted :	WORD;
	iBufferReceiveLengthRemembered :	INT;
	xBufferReceiveLengtChanged :	BOOL;
	iBufferSendLengthRemembered :	INT;
	xBufferSendeLengtChanged :	BOOL;
	xBufferSendLengthChanged :	BOOL;
	bPushByte :	BYTE;
	bPulledByte :	BYTE;
	wBytesReceived :	WORD;
	wBytesTransmitted :	WORD;
	udiRevRemembered :	UDINT;
END_VAR


(*@KEY@: WORKSHEET
NAME: AXL_F_RSUNI
IEC_LANGUAGE: ST
*)
(* ========================================== Constants ========================================================= *)
MAX_SEND_LENGTH := 17;
MAX_RCV_LENGTH  := 17;
(* ============================================================================================================== *)


(* ========================================== Clearing data ===================================================== *)
FOR iByteToCopy	:= 1 TO 14 DO

	arrOutputAddress[iByteToCopy] := BYTE#16#00;

END_FOR;
(* ============================================================================================================== *)


(* ============================================= Module status bits ============================================= *)
bStatusBits.X0 := udtBufferReceive.iLength > 0; 	(* Receive buffer not empty *)
bStatusBits.X1 := FALSE; 							(* Receive error *)
bStatusBits.X2 := FALSE; 							(* Transmit error *)
bStatusBits.X3 := FALSE; 							(* DCD *)
bStatusBits.X4 := FALSE; 							(* Receive buffer full *)
bStatusBits.X5 := FALSE; 							(* Transmit buffer full*)
bStatusBits.X6 := udtBufferSend.iLength > 0; 		(* Transmit buffer not empty *)
bStatusBits.X7 := FALSE;							(* DSR *)

(* =============================================================================================================== *)

(* Check if command changed *)
xCommandChanged                 := FALSE;
FOR iIndex := 0 TO 19 DO
    xCommandChanged             := xCommandChanged OR (arrInputAddress[iIndex] <> arrInputAddressRememdered[iIndex]);
END_FOR;

IF xCommandChanged THEN
    diCommandsCounter           := diCommandsCounter + DINT#1;
END_IF;

(* Remember command *)
FOR iIndex := 0 TO 19 DO
    arrInputAddressRememdered[iIndex] := arrInputAddress[iIndex];
END_FOR;

(* Check if Receive Buffer length changed*)
xBufferReceiveLengtChanged      := FALSE;
IF udtBufferReceive.iLength <> iBufferReceiveLengthRemembered THEN
    xBufferReceiveLengtChanged  := TRUE;
END_IF;
iBufferReceiveLengthRemembered  := udtBufferReceive.iLength;

(* Check if Send Buffer length changed*)
xBufferSendLengthChanged         := FALSE;
IF udtBufferSend.iLength <> iBufferSendLengthRemembered THEN
    xBufferSendLengthChanged    := TRUE;
END_IF;
iBufferSendLengthRemembered     := udtBufferSend.iLength;
(* ======================================== Execute commands ======================================================*)

(* "Read number of characters received" command *)
IF arrInputAddress[0] = BYTE#16#00 THEN

	IF xConsoleLog AND xBufferReceiveLengtChanged THEN
		Console.strSource				:= strConsoleId;
		Console.strMessage				:= CONCAT('ReadNumberOfChar command, number ', INT_TO_STRING(udtBufferReceive.iLength, '%d'));
		Console();
	END_IF;

	arrOutputAddress[0] 			:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 			:= bStatusBits;								(* Status bits *)

	wNumberOfCharactersReceived 	:= INT_TO_WORD(udtBufferReceive.iLength);
    IF udtBufferReceive.iLength >= 3096 THEN
        bFillLevel                  := BYTE#03;
    ELSIF udtBufferReceive.iLength >= 2096 THEN
        bFillLevel                  := BYTE#02;
    ELSIF udtBufferReceive.iLength >= 1096 THEN
        bFillLevel                  := BYTE#01;
    ELSE
        bFillLevel                  := BYTE#000;
    END_IF;
	arrOutputAddress[2] 			:= wNumberOfCharactersReceived.B0;
	arrOutputAddress[3] 			:= wNumberOfCharactersReceived.B1;
    arrOutputAddress[4]             := bFillLevel;

(* “Transmit characters” command *)
ELSIF (arrInputAddress[0] = BYTE#16#10 
	OR arrInputAddress[0] = BYTE#16#50)
	AND NOT xSending 
    AND xCommandChanged
	THEN

    iBytesToCopy				:= BYTE_TO_INT(arrInputAddress[2]);

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT ('TransmitChar command length ', INT_TO_STRING(iBytesToCopy, '%d'));
		Console();
	END_IF;

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

	iFirstAddressIndex			:= 3;
	iLastAddressIndex			:= iFirstAddressIndex + MIN(iBytesToCopy - 1, MAX_SEND_LENGTH);
	iFirstBufferIndex			:= 0;

	FOR iAddressIndex := iFirstAddressIndex TO iLastAddressIndex DO
        BufferHandler.xPull     := FALSE;
        BufferHandler.xPush     := TRUE;
        BufferHandler.bPushByte := arrInputAddress[iAddressIndex];
        BufferHandler.udtBuffer := udtBufferSend;
        BufferHandler();
        udtBufferSend           := BufferHandler.udtBuffer;
	END_FOR;

	xSending					:= TRUE;

(* Store characters” command *)
ELSIF (arrInputAddress[0] = BYTE#16#20 
	OR arrInputAddress[0] = BYTE#16#60) 
	AND NOT xSending 
    AND (xCommandChanged OR xBufferSendLengthChanged)
	THEN

    iBytesToCopy				:= BYTE_TO_INT(arrInputAddress[2]);

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT ('StoreChar command length ', INT_TO_STRING(iBytesToCopy, '%d'));
		Console();
	END_IF;

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

	iFirstAddressIndex			:= 3;
	iLastAddressIndex			:= iFirstAddressIndex + MIN(iBytesToCopy - 1, MAX_SEND_LENGTH);
	iFirstBufferIndex			:= 0;

	FOR iAddressIndex := iFirstAddressIndex TO iLastAddressIndex DO
        BufferHandler.xPull     := FALSE;
        BufferHandler.xPush     := TRUE;
        BufferHandler.bPushByte := arrInputAddress[iAddressIndex];
        BufferHandler.udtBuffer := udtBufferSend;
        BufferHandler();
        udtBufferSend           := BufferHandler.udtBuffer;
	END_FOR;

(* "Read characters" command *)
ELSIF arrInputAddress[0] = BYTE#16#30
    AND xCommandChanged THEN

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	bStatusBits.X0 				:= FALSE;
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

	arrOutputAddress[2] 		:= INT_TO_BYTE(udtBufferReceive.iLength);	(* Number of valid characters available in the input data *)

	iBytesToCopy 				:= MIN(udtBufferReceive.iLength, MAX_RCV_LENGTH);
    arrOutputAddress[2]         := INT_TO_BYTE(iBytesToCopy);

    IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT('ReadChar command, length ', INT_TO_STRING(iBytesToCopy, '%d'));
		Console();
	END_IF;

	iFirstAddressIndex			:= 3;
	iLastAddressIndex			:= iFirstAddressIndex + iBytesToCopy - 1;
	iFirstBufferIndex			:= 0;
	FOR iAddressIndex := iFirstAddressIndex TO iLastAddressIndex DO
        BufferHandler.xPull             := TRUE;
        BufferHandler.xPush             := FALSE;
        BufferHandler.udtBuffer         := udtBufferReceive;
        BufferHandler();
        udtBufferReceive                := BufferHandler.udtBuffer;
		arrOutputAddress[iAddressIndex] := BufferHandler.bPulledByte;
	END_FOR;

	(*udtBufferReceive.iWordsNo	:= 0;*)


(* "Read counters" command *)
ELSIF arrInputAddress[0] = BYTE#16#3E 
	AND arrInputAddress[1] = BYTE#16#00
    AND xCommandChanged THEN

		IF xConsoleLog THEN
			Console.strSource			:= strConsoleId;
			Console.strMessage			:= 'ReadCounters command';
			Console();
		END_IF;

		arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
		arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

		wBytesReceived				:= INT_TO_WORD(iBytesReceived);
		arrOutputAddress[2]			:= wWordsReceived.B0;
		arrOutputAddress[3]			:= wWordsReceived.B1;

		wBytesTransmitted			:= INT_TO_WORD(iBytesTransmitted);
		arrOutputAddress[7]			:= wWordsTransmitted.B0;
		arrOutputAddress[8]			:= wWordsTransmitted.B1;

(* "Write configuration" command *)
ELSIF arrInputAddress[0] = BYTE#16#40
    AND xCommandChanged THEN

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= 'Write configuration command';
		Console();
	END_IF;

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

ELSIF xCommandChanged THEN

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT(BYTE_TO_STRING(arrInputAddress[0], '%x'),' command');
		Console();
	END_IF;

	arrOutputAddress[0] 		:= 	arrInputAddress[0];						(* Command mirror *)

END_IF;

(* ============================================================================================================== *)


(* ==================================== Clear xSending flag if command is changing ============================== *)
(*
IF arrInputAddress[0] <> BYTE#16#10  
	AND arrInputAddress[0] <> BYTE#16#50 
	THEN

		xSending	:= FALSE;

END_IF;
*)
(* ============================================================================================================== *)


(* ================================= Sending data from internal buffer to serial interface ====================== *)
IF xSending THEN
        xSending                        := FALSE;

		IF xConsoleLog THEN
			Console.strSource			:= strConsoleId;
			Console.strMessage			:= CONCAT('Sending to interface, length ', INT_TO_STRING(udtBufferSend.iLength, '%d'));
			Console();
		END_IF;

        (* Clear RS485 Line *)
        BufferHandler.xClear            := TRUE;
        BufferHandler.xPull             := FALSE;
        BufferHandler.xPush             := FALSE;
        BufferHandler.udtBuffer         := udtRS485Line;
        BufferHandler();
        udtRS485Line                    := BufferHandler.udtBuffer;

        WHILE NOT udtBufferSend.xEmpty DO
            (* Pull from internal buffer *)
            BufferHandler.xPull             := TRUE;
            BufferHandler.xPush             := FALSE;
            BufferHandler.udtBuffer         := udtBufferSend;
            BufferHandler();
            udtBufferSend                   := BufferHandler.udtBuffer;

            bPulledByte                     := BufferHandler.bPulledByte;

            (* Push to RS485 Line *)
            IF NOT BufferHandler.xError THEN
                BufferHandler.xPull          := FALSE;
                BufferHandler.xPush          := TRUE;
                BufferHandler.bPushByte      := bPulledByte;
                BufferHandler.udtBuffer      := udtRS485Line;
                BufferHandler();
                udtRS485Line                := BufferHandler.udtBuffer;
            END_IF;

            (* Counter update *)
            iBytesTransmitted               := iBytesTransmitted + 1;
        END_WHILE;

        udtRS485Line.udiRev                 := udtRS485Line.udiRev + UDINT#1;
        udiRevRemembered                    := udtRS485Line.udiRev;

(* ======================================== Copy data from interface to internal buffer ======================= *)
ELSIF NOT xSending 
	AND NOT udtRS485Line.xEmpty 
    AND udiRevRemembered <> udtRS485Line.udiRev THEN

		IF xConsoleLog THEN
			Console.strSource				:= strConsoleId;
			Console.strMessage				:= CONCAT('Receiving from interface, length ', INT_TO_STRING(udtRS485Line.iLength, '%d'));
			Console();
		END_IF;

        udtRS485LineCopy                    := udtRS485Line;

        WHILE NOT udtRS485LineCopy.xEmpty DO
            (* Pull from RS485 Line *)
            BufferHandler.xPull             := TRUE;
            BufferHandler.xPush             := FALSE;
            BufferHandler.udtBuffer         := udtRS485LineCopy;
            BufferHandler();
            udtRS485LineCopy                := BufferHandler.udtBuffer;

            bPulledByte                     := BufferHandler.bPulledByte;

            (* Push to internal buffer *)
            IF NOT BufferHandler.xError THEN
                BufferHandler.xPull          := FALSE;
                BufferHandler.xPush          := TRUE;
                BufferHandler.bPushByte      := bPulledByte;
                BufferHandler.udtBuffer      := udtBufferReceive;
                BufferHandler();
                udtBufferReceive             := BufferHandler.udtBuffer;
            END_IF;

            (* Counter update *)
            iBytesReceived                   := iBytesReceived + 1;
        END_WHILE;


		udiRevRemembered 	                 := udtRS485Line.udiRev;
END_IF;
(* ============================================================================================================== *)

(* Update buffers Info *)
BufferHandler.xPull          := FALSE;
BufferHandler.xPush          := FALSE;
BufferHandler.xClear         := FALSE;
BufferHandler.bPushByte      := bPulledByte;
BufferHandler.udtBuffer      := udtBufferReceive;
BufferHandler();
udtBufferReceive             := BufferHandler.udtBuffer;

BufferHandler.xPull          := FALSE;
BufferHandler.xPush          := FALSE;
BufferHandler.xClear         := FALSE;
BufferHandler.bPushByte      := bPulledByte;
BufferHandler.udtBuffer      := udtBufferSend;
BufferHandler();
udtBufferSend                := BufferHandler.udtBuffer;

BufferHandler.xPull          := FALSE;
BufferHandler.xPush          := FALSE;
BufferHandler.xClear         := FALSE;
BufferHandler.bPushByte      := bPulledByte;
BufferHandler.udtBuffer      := udtRS485Line;
BufferHandler();
udtRS485Line                 := BufferHandler.udtBuffer;

udiRevRemembered             := udtRS485Line.udiRev;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
