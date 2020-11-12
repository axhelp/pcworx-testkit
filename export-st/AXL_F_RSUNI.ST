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
	udtRS485Line :	udtRS485Frame;
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
	iWordsTransmitted :	INT;
	iWordsReceived :	INT;
	wWordsReceived :	WORD;
	wWordsTransmitted :	WORD;
	udtRS485Line_iCounterPrev :	INT;
	iWordsToSend :	INT;
END_VAR


(*Group:Default*)


(*@KEY@: WORKSHEET
NAME: AXL_F_RSUNI
IEC_LANGUAGE: ST
*)
(* ========================================== Clearing data ===================================================== *)
FOR iByteToCopy	:= 1 TO 14 DO

	arrOutputAddress[iByteToCopy] := BYTE#16#00;

END_FOR;
(* ============================================================================================================== *)


(* ============================================= Module status bits ============================================= *)
bStatusBits.X0 := udtBufferReceive.iWordsNo > 0; 	(* Receive buffer not empty *)
bStatusBits.X1 := FALSE; 							(* Receive error *)
bStatusBits.X2 := FALSE; 							(* Transmit error *)
bStatusBits.X3 := FALSE; 							(* DCD *)
bStatusBits.X4 := FALSE; 							(* Receive buffer full *)
bStatusBits.X5 := FALSE; 							(* Transmit buffer full*)
bStatusBits.X6 := udtBufferSend.iWordsNo > 0; 		(* Transmit buffer not empty *)
bStatusBits.X7 := FALSE;							(* DSR *)

(* =============================================================================================================== *)


(* ======================================== Execute commands ======================================================*)

(* "Read number of characters received" command *)
IF arrInputAddress[0] = BYTE#16#00 THEN

	IF xConsoleLog THEN
		Console.strSource				:= strConsoleId;
		Console.strMessage				:= CONCAT('ReadNumberOfChar command, number ', INT_TO_STRING(udtBufferReceive.iWordsNo, '%d'));
		Console();
	END_IF;

	arrOutputAddress[0] 			:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 			:= bStatusBits;								(* Status bits *)

	wNumberOfCharactersReceived 	:= INT_TO_WORD(udtBufferReceive.iWordsNo);
	arrOutputAddress[2] 			:= wNumberOfCharactersReceived.B0;
	arrOutputAddress[3] 			:= wNumberOfCharactersReceived.B1;


(* “Transmit characters” command *)
ELSIF arrInputAddress[0] = BYTE#16#10 
	OR arrInputAddress[0] = BYTE#16#50  
	AND NOT xSending 
	THEN

		IF xConsoleLog THEN
			Console.strSource			:= strConsoleId;
			Console.strMessage			:= 'TransmitChar command';
			Console();
		END_IF;

		iWordsToSend				:= BYTE_TO_INT(arrInputAddress[2]);
		iBytesToCopy				:= iWordsToSend * 2;

		arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
		arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

		iFirstAddressIndex			:= 3;
		iLastAddressIndex			:= MIN(iBytesToCopy - 1, 14);
		iFirstBufferIndex			:= 0;

		FOR iAddressIndex := iFirstAddressIndex TO iLastAddressIndex DO
			udtBufferSend.arrData[iFirstBufferIndex] 	:= arrInputAddress[iAddressIndex];
			iFirstBufferIndex 							:= iFirstBufferIndex + 1;
		END_FOR;

		udtBufferSend.iWordsNo		:= iWordsToSend;

		xSending					:= TRUE;


(* "Read characters" command *)
ELSIF arrInputAddress[0] = BYTE#16#30 THEN

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT('ReadChar command, length ', INT_TO_STRING(udtBufferReceive.iWordsNo, '%d'));
		Console();
	END_IF;

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	bStatusBits.X0 				:= FALSE;
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

	arrOutputAddress[2] 		:= INT_TO_BYTE(udtBufferReceive.iWordsNo);	(* Number of valid characters available in the input data *)

	iBytesToCopy 				:= udtBufferReceive.iWordsNo * 2;

	iFirstAddressIndex			:= 3;
	iLastAddressIndex			:= MIN(iFirstAddressIndex + iBytesToCopy - 1, 14);
	iFirstBufferIndex			:= 0;
	FOR iAddressIndex := iFirstAddressIndex TO iLastAddressIndex DO
		arrOutputAddress[iAddressIndex] := udtBufferReceive.arrData[iFirstBufferIndex];
		iFirstBufferIndex 				:= iFirstBufferIndex + 1;
	END_FOR;

	udtBufferReceive.iWordsNo	:= 0;


(* "Read counters" command *)
ELSIF arrInputAddress[0] = BYTE#16#3E 
	AND arrInputAddress[1] = BYTE#16#00 THEN

		IF xConsoleLog THEN
			Console.strSource			:= strConsoleId;
			Console.strMessage			:= 'ReadCounters command';
			Console();
		END_IF;

		arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
		arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

		wWordsReceived				:= INT_TO_WORD(iWordsReceived);
		arrOutputAddress[2]			:= wWordsReceived.B0;
		arrOutputAddress[3]			:= wWordsReceived.B1;

		wWordsTransmitted			:= INT_TO_WORD(iWordsTransmitted);
		arrOutputAddress[7]			:= wWordsTransmitted.B0;
		arrOutputAddress[8]			:= wWordsTransmitted.B1;

(* "Write configuration" command *)
ELSIF arrInputAddress[0] = BYTE#16#40 THEN

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= 'Write configuration command';
		Console();
	END_IF;

	arrOutputAddress[0] 		:= arrInputAddress[0];						(* Command mirror *)
	arrOutputAddress[1] 		:= bStatusBits;								(* Status bits *)

ELSE

	IF xConsoleLog THEN
		Console.strSource			:= strConsoleId;
		Console.strMessage			:= CONCAT(BYTE_TO_STRING(arrInputAddress[0], '%x'),' command');
		Console();
	END_IF;

	arrOutputAddress[0] 		:= 	arrInputAddress[0];						(* Command mirror *)

END_IF;

(* ============================================================================================================== *)


(* ==================================== Clear xSending flag if command is changing ============================== *)
IF arrInputAddress[0] <> BYTE#16#10  
	AND arrInputAddress[0] <> BYTE#16#50 
	THEN

		xSending	:= FALSE;

END_IF;

R_TRIG_xSending.CLK	:= xSending;
R_TRIG_xSending();
(* ============================================================================================================== *)


(* ================================= Sending data from internal buffer to serial interface ====================== *)
IF R_TRIG_xSending.Q 
	AND udtBufferSend.iWordsNo > 0 THEN

		IF xConsoleLog THEN
			Console.strSource			:= strConsoleId;
			Console.strMessage			:= CONCAT('Sending to interface, length ', INT_TO_STRING(udtBufferSend.iWordsNo, '%d'));
			Console();
		END_IF;


		iBytesToCopy :=  MIN((udtBufferSend.iWordsNo * 2) - 1, 13);

		FOR iByteNum := 0 TO iBytesToCopy DO

			udtRS485Line.arrData[iByteNum] := udtBufferSend.arrData[iByteNum];

		END_FOR;

		udtRS485Line.iCounter		:= udtRS485Line.iCounter + 1;
		udtRS485Line.iWordsNo		:= udtBufferSend.iWordsNo;
		udtRS485Line_iCounterPrev 	:= udtRS485Line.iCounter;

		udtBufferSend.iWordsNo		:= 0;

(* ======================================== Copy data from interface to internal buffer ======================= *)
ELSIF udtRS485Line.iCounter > udtRS485Line_iCounterPrev 
	AND NOT xSending 
	AND udtRS485Line.iWordsNo > 0 THEN

		IF xConsoleLog THEN
			Console.strSource				:= strConsoleId;
			Console.strMessage				:= CONCAT('Receiving from interface, length ', INT_TO_STRING(udtRS485Line.iWordsNo, '%d'));
			Console();
		END_IF;

		iBytesToCopy :=  MIN((udtRS485Line.iWordsNo * 2) - 1, 13);

		FOR iByteNum := 0 TO iBytesToCopy DO

			udtBufferReceive.arrData[iByteNum] := udtRS485Line.arrData[iByteNum];

		END_FOR;

		udtBufferReceive.iWordsNo	:= udtRS485Line.iWordsNo;
		iWordsReceived				:= iWordsReceived + udtRS485Line.iWordsNo;
		udtRS485Line_iCounterPrev 	:= udtRS485Line.iCounter;

END_IF;
(* ============================================================================================================== *)

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
