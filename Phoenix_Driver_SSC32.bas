;Project Lynxmotion Phoenix
;Description: Phoenix, driver file
; 			  SSC Driver - Contains all of the code that knows anything about the SSC-32
;					 	   It also has timer functions as this may also change with drivers...
;						   Can be used with V2.1 and above
;
;SSC Driver version: V1.0
;Date: 19-04-2011
;Programmer: Jeroen Janssen (aka Xan)
;			 Kurt (aka KurtE)

;====================================================================
lTimerCnt			var long	

;--------------------------------------------------------------------
;[TIMER INTERRUPT INIT]
#ifdef BASICATOMPRO28
TIMERINT	con	TIMERAINT
ONASMINTERRUPT TIMERAINT, HANDLE_TIMERA_ASM 

;--------------------------------------------------------------------
;[InitServoDriver] - Initializes the servo driver including the main timer used in the phoenix code
InitTimer:
;Timer
; Timer A init, used for timing of messages and some times for timing code...
  TIMERINT	con	TIMERAINT

  WTIMERTICSPERMSMUL con 64	; BAP28 is 16mhz need a multiplyer and divider to make the conversion with /8192
  WTIMERTICSPERMSDIV con 125  ; 
  TMA = 0	; clock / 8192					; Low resolution clock - used for timeouts...
  ENABLE TIMERINT
return

;==============================================================================
;[Handle_Timer_asm] - Handle timer A overflow in assembly language.  Currently only
;used for timings for debuging the speed of the code
;Now used to time how long since we received a message from the remote.
;this is important when we are in the NEW message mode, as we could be hung
;out with the robot walking and no new commands coming in.
;==============================================================================
BEGINASMSUB 
HANDLE_TIMERA_ASM 
	push.l 	er1                  ; first save away ER1 as we will mess with it. 
	bclr 	#6,@IRR1:8               ; clear the cooresponding bit in the interrupt pending mask 
	mov.l 	@LTIMERCNT:16,er1      ; Add 256 to our counter 
	add.l	#256,er1 
	mov.l 	er1, @LTIMERCNT:16 
	pop.l 	er1 
	rte 
ENDASMSUB 

return		; Put a basic statement before...
;==============================================================================
;[GetCurrentTime] - Gets the Timer value from our overflow counter as well as the TCA counter.  It
;                makes sure of consistancy. That is it is very posible that 
;                after we grabed the timers value it overflows, before we grab the other part
;                so we check to make sure it is correct and if necesary regrab things.
;==============================================================================
GetCurrentTime:
  lCurrentTime = lTimerCnt + TCA
	
  ; handle wrap
  if lTimerCnt <> (lCurrentTime & 0xffffff00) then
	lCurrentTime = lTimerCnt + TCA
  endif

return lCurrentTime

#else ; Arc32 or Bap40
TIMERINT	con	TIMERB1INT
ONASMINTERRUPT TIMERB1INT, HANDLE_TIMERB1_ASM 

;--------------------------------------------------------------------
;[InitServoDriver] - Initializes the servo driver including the main timer used in the phoenix code
InitTimer:
;Timer
; Timer A init, used for timing of messages and some times for timing code...
  TIMERINT	con	TIMERB1INT
  WTIMERTICSPERMSMUL con 256	; Arc32 is 20mhz need a multiplyer and divider to make the conversion with /8192
  WTIMERTICSPERMSDIV con 625  ; 
  TMB1 = 0	; clock / 8192					; Low resolution clock - used for timeouts...
  ENABLE TIMERINT
return

;==============================================================================
;[Handle_Timer_asm] - Handle timer A overflow in assembly language.  Currently only
;used for timings for debuging the speed of the code
;Now used to time how long since we received a message from the remote.
;this is important when we are in the NEW message mode, as we could be hung
;out with the robot walking and no new commands coming in.
;==============================================================================
   BEGINASMSUB 
HANDLE_TIMERB1_ASM 
	push.l 	er1                  ; first save away ER1 as we will mess with it. 
	bclr 	#5,@IRR2:8           ; clear the cooresponding bit in the interrupt pending mask 
	mov.l 	@LTIMERCNT:16,er1    ; Add 256 to our counter 
	add.l	#256,er1 
	mov.l 	er1, @LTIMERCNT:16 
	pop.l 	er1 
	rte 
	ENDASMSUB 

BEGINASMSUB 

return		; Put a basic statement before...
;==============================================================================
;[GetCurrentTime] - Gets the Timer value from our overflow counter as well as the TCA counter.  It
;                makes sure of consistancy. That is it is very posible that 
;                after we grabed the timers value it overflows, before we grab the other part
;                so we check to make sure it is correct and if necesary regrab things.
;==============================================================================
GetCurrentTime:
  lCurrentTime = lTimerCnt + TCB1
	
  ; handle wrap
  if lTimerCnt <> (lCurrentTime & 0xffffff00) then
	lCurrentTime = lTimerCnt + TCB1
  endif

return lCurrentTime


#endif

;-------------------------------------------------------------------------------------
;[ConvertTimeMS]
_ttconv	var	long
ConvertTimeMS[_ttconv]:
	return (_ttconv * WTIMERTICSPERMSMUL)/WTIMERTICSPERMSDIV 


;--------------------------------------------------------------------
;[CheckGPEnable] Checks to see if the SSC-32 support the general purpose sequences
#ifndef cNOGP
GPVerData	var byte(100)		;Received data to check the SSC Version
CheckGPEnable:
	
  pause 10
  input cSSC_IN  ; should not be needed... 
  GPEnable=0
  serout cSSC_OUT, cSSC_BAUD, ["ver", 13]
  serin cSSC_IN, cSSC_BAUD, 10000, timeout, [str GPVerData\100\13]
    hserout 1, ["SSC Ver: ", hex GPVerData(0), hex GPVerData(1), " ", str GPVerData\100\13, 13]
  index = 0
  while (GPVerData(Index) <> 13) and (index < 100)
  	index = index + 1
  wend
  if ((index >=2) and (GPVerData(Index-2) = "G") and (GPVerData(Index-1) = "P")) then
    hserout 1, ["SSC GP enabled", 13]
    pause 1000
  	return 1
  endif
  
Timeout:
    hserout 1, ["SSC Not GP enabled", 13]
  	sound cSpeakerPin, [40\5000,40\5000]
 pause 1000

return 0

;--------------------------------------------------------------------
;[GP PLAYER]
GPStatSeq       var byte
GPStatFromStep  var byte
GPStatToStep   	var byte
GPStatTime      var byte
GPSMPrev		var sword
GPSeqStart		var	word
GPCntSteps		var byte

GPPlayer:
  IF GPStart = 0 THEN			; If we are not playing anything bail out quickly.
    return; 
  ENDIF
  
  gosub ControlAllowInput[0];
  pause 1  ; give a little time
    
  ;Start sequence
  IF (GPStart=1) THEN
  
	gosub GPSeqNumSteps		; gets the count of steps for the sequence.  Should check error state.
	IF GPCntSteps <> 0xff THEN	
      disable TIMERINT 		;disable timer interrupt
      serout cSSC_OUT, cSSC_BAUD, ["PL0SQ", dec GPSeq,"SM", sdec GPSM, 13] ;Start sequence
      serout S_OUT, i38400, ["PL0SQ", dec GPSeq,"SM", sdec GPSM, 13] ;Start sequence
      GPSMPrev = GPSM
      enable TIMERINT
      GPStart=2   ; set the state to do query...
    ELSE
      GPStart=0		; else bail out
    ENDIF

  ELSEIF (GPStart=2)
    ;See if  GPPlayer has completed sequence
    disable TIMERINT 		;disable timer interrupt
    serout cSSC_OUT, cSSC_BAUD, ["QPL0", 13]
    serin cSSC_IN, cSSC_BAUD, [GPStatSeq, GPStatFromStep, GPStatToStep, GPStatTime]
    enable TIMERINT
    ;The ONCE command does not work after PL0SM cmd, therefore our own function for stopping the player
    ;NB! Reuse of the GPVerData, now it contains total # of steps in current sequence
    IF (GPStatFromStep = (GPCntSteps-1))&(GPStatTime=0)THEN;Stop SQ at the last step in SQ, 
      disable TIMERINT 		;disable timer interrupt
      serout cSSC_OUT, cSSC_BAUD, ["PL0", 13] ;Stop player
	  enable TIMERINT
      GPStart=0
    ELSEIF GPSMPrev <> GPSM
      disable TIMERINT
      serout cSSC_OUT, cSSC_BAUD, ["PL0SM", sdec GPSM, 13]   
      serout s_out, i38400, ["PL0SM", sdec GPSM, 13]  
      enable TIMERINT
      GPSMPrev = GPSM
    ENDIF
  ELSEIF GPStart=0xff
    ; user requested us to abort the sequence.
    disable TIMERINT 		;disable timer interrupt
    serout cSSC_OUT, cSSC_BAUD, ["PL0", 13] ;Stop the sequence now
    enable TIMERINT
    GPStart = 0
  ENDIF
  gosub ControlAllowInput[1];

return

;--------------------------------------------------------------------
;[GPSeqNumSteps] returns the number of steps a specific sequence has 
;		as defined in the variable GPSEQ has or -1 if the sequence is not defined
GPSeqNumSteps:
  pause 1
  GPCntSteps = 0xff		; assume an error

  disable TIMERINT 		;disable timer interrupt
  serout cSSC_OUT, cSSC_BAUD, ["EER -", dec GPSEQ*2, ";2",13];Read adr to current seq
  serin cSSC_IN, cSSC_BAUD, 50000, _TO_GPSNS, [str GPSeqStart\2] ;read in 2 byte header - bugbug reuse a local variable
  enable TIMERINT
  				
  IF (GPSeqStart <> 0)  and (GPSeqStart <> 0xffff)	THEN
    disable TIMERINT 		;disable timer interrupt
    serout cSSC_OUT, cSSC_BAUD, ["EER -", dec (GPSeqStart.highbyte*256+GPSeqStart.lowbyte)+2, ";1",13] 
    serin cSSC_IN, cSSC_BAUD, 50000,_TO_GPSNS, [GPCntSteps];
  ENDIF

_TO_GPSNS:		 	
  enable TIMERINT
return GPCntSteps  ; SSC-32 did not respond, so assume not supported...
;-------------------------------------------------------------------
;[GPGetCurrentStep] returns the current step number of an active sequence or -1 
GPGetCurrentStep:
  IF GPStart THEN
    return GPStatFromStep
  ENDIF
return -1
#endif
;--------------------------------------------------------------------
;[SERVO DRIVER] Updates the positions of the servos
;Binary version
;**********************************************************************
;Extended binary commands.
;
;Commands 0x80-0x9F are group move servo number 0-31.  The next 2 bytes
;must be pulse width for the servo:
;    0x80+servoNum, pwHigh, pwLow
;
;Command 0xA0 is the group move servo speed, which must immediately
;follow the pulse width:
;    0xA0, spdHigh, spdLow
;
;Command 0xA1 is the group move time, which must follow all of the
;pulse widths and speeds:
;    0xA1, timeHigh, timeLow
;
;Command 0xA2 is the stop all command, 1 byte
;    0xA2
;**********************************************************************
UpdateServoDriver:
   gosub ControlAllowInput[0];

  disable TIMERINT 		;disable timer interrupt
  for LegIndex = 0 to 5
    ; Calulate 
	GOSUB GetPWMValues [LegIndex]
	
    serout cSSC_OUT, cSSC_BAUD, [0x80+cCoxaPin(LegIndex) ,CoxaPWM.highbyte,  CoxaPWM.lowbyte,|
    	                         0x80+cFemurPin(LegIndex),FemurPWM.highbyte, FemurPWM.lowbyte,|
    	                         0x80+cTibiaPin(LegIndex),TibiaPWM.highbyte, TibiaPWM.lowbyte]
#ifdef c4DOF
	; Support for Coxa - also allows for some legs being 3DOF while others are 4DOF
	if cTarsLength(LegIndex) then
	    serout cSSC_OUT, cSSC_BAUD, [0x80+cTarsPin(LegIndex) ,TarsPWM.highbyte,  TarsPWM.lowbyte]
	endif
#endif    	                         
  next
  
  gosub ControlAllowInput[1];

  PrevSSCTime = SSCTime
return
;--------------------------------------------------------------------
;[FREE SERVOS] Frees all the servos (binary)
FreeServos
    gosub ControlAllowInput[0];
    disable TIMERINT
	for LegIndex = 0 to 31
      serout cSSC_OUT, cSSC_BAUD, [0x80+LegIndex, 0, 0]
    next
    serout cSSC_OUT, cSSC_BAUD, [0xA1, 0, 200]
    enable TIMERINT
    gosub ControlAllowInput[1];
return
;--------------------------------------------------------------------
;[COMMIT SERVO POSITIONS]
CommitServoDriver:
  ;Send <CR>
  gosub ControlAllowInput[0];
  disable TIMERINT
  ; With Binary mode we need to output the speed 3 bytes to do a commit. 
  ;Send speed
  serout cSSC_OUT, cSSC_BAUD, [0xA1,SSCTime.highbyte,SSCTime.lowbyte]
  enable TIMERINT
  ;serout cSSC_OUT, cSSC_BAUD, [13]	; Ascii text commit of a command
  enable TIMERINT
  gosub ControlAllowInput[1];
return
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;[Read Servo Offsets
SERVOSAVECNT	con	32				
aServoOffsets	var	sword(SERVOSAVECNT)		; Our new values - must take stored away values into account...

ReadServoOffsets:
return	