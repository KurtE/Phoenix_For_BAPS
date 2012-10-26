;Project Lynxmotion Phoenix
;Description: 3DOF T-Hex, configuration file.
;      All Hardware connections (excl controls) and body dimensions 
;      are configurated in this file. Can be used with V2.1 and above
;Configuration version: V1.1 alfa
;Date: April 15, 2011
;Programmers: Jeroen Janssen (aka Xan)
;			  Kåre Halvorsen (aka Zenta)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2, (See further for connections)
;
;NEW IN V1.1
;   - Added speaker constant
;	- Added support for different leg lengths
;	- Optional 4DOF
;	- Optional Safety shut down when voltage drops
;
;--------------------------------------------------------------------
;[CONDITIONAL COMPILING] - COMMENT IF NOT WANTED
c4DOF			 con 1	 	; Switch between 3DOF and 4DOF
;cTurnOffVol	 con 630 	; When uncomment the bot will turn off when 
							; the voltage drops below this setpoint (630 = 6.3V)
;--------------------------------------------------------------------
;[SERIAL CONNECTIONS]
cSSC_OUT        con P11     ;Output pin for (SSC32 RX) on BotBoard (Yellow)
cSSC_IN         con P10     ;Input pin for (SSC32 TX) on BotBoard (Blue)
cSSC_BAUD       con i115200	;SSC32 BAUD rate 38400 115200
;--------------------------------------------------------------------
;[BB2 PIN NUMBERS]
; Note the default PS2 definitions are in the PS2 control file.
;cXBEE_RTS		con P7			; for XBee version
;PS2DAT 			con P16		;PS2 Controller DAT (Brown)
;PS2CMD 			con P17		;PS2 controller CMD (Orange)
;PS2SEL 			con P18		;PS2 Controller SEL (Blue)
;PS2CLK 			con P19		;PS2 Controller CLK (White)
cEyesPin      	con P8
cSpeakerPin		con P9
cVoltagePin		con 17		; Defines the analog input to read the voltage
							; for safety shutdown. (16=AX0=VS, 17=AX1=VL) 
;--------------------------------------------------------------------
;[SSC PIN NUMBERS]
cRFCoxaPin      con P0   ;Rear Right leg Hip Horizontal
cRFFemurPin    	con P1   ;Rear Right leg Hip Vertical
cRFTibiaPin    	con P2   ;Rear Right leg Knee
cRFTarsPin		con P3	 ;Rear Right leg foot

cRMCoxaPin      con P4   ;Middle Right leg Hip Horizontal
cRMFemurPin    	con P5   ;Middle Right leg Hip Vertical
cRMTibiaPin    	con P6   ;Middle Right leg Knee
cRMTarsPin		con P7	 ;Middle Right leg foot

cRRCoxaPin      con P8   ;Front Right leg Hip Horizontal
cRRFemurPin    	con P9   ;Front Right leg Hip Vertical
cRRTibiaPin    	con P10  ;Front Right leg Knee
cRRTarsPin		con P11  ;Front Right leg foot

cLFCoxaPin      con P16  ;Rear Left leg Hip Horizontal
cLFFemurPin    	con P17  ;Rear Left leg Hip Vertical
cLFTibiaPin    	con P18  ;Rear Left leg Knee
cLFTarsPin		con P19	 ;Rear Left leg foot

cLMCoxaPin      con P20   ;Middle Left leg Hip Horizontal
cLMFemurPin    	con P21   ;Middle Left leg Hip Vertical
cLMTibiaPin    	con P22   ;Middle Left leg Knee
cLMTarsPin		con P23	  ;Middle Left leg foot

cLRCoxaPin      con P24   ;Front Left leg Hip Horizontal
cLRFemurPin    	con P25   ;Front Left leg Hip Vertical
cLRTibiaPin    	con P26   ;Front Left leg Knee
cLRTarsPin		con P27	  ;Front Left leg foot
;--------------------------------------------------------------------
;[Joint offsets]
;First calibrate the servos in the 0 deg position using the SSC-32 reg offsets, then:
cXXFemurHornOffset	con 150 ;Snap out the horn one click upward
cXXTarsHornOffset	con 150 ;Snap out the horn one click inward

; Set up to have per leg offsets...
cRRFemurHornOffset1	con cXXFemurHornOffset
cRRTarsHornOffset1	con cXXTarsHornOffset	

cRMFemurHornOffset1	con cXXFemurHornOffset
cRMTarsHornOffset1	con cXXTarsHornOffset	

cRFFemurHornOffset1	con cXXFemurHornOffset
cRFTarsHornOffset1	con cXXTarsHornOffset	

cLRFemurHornOffset1	con cXXFemurHornOffset
cLRTarsHornOffset1	con cXXTarsHornOffset	

cLMFemurHornOffset1	con cXXFemurHornOffset
cLMTarsHornOffset1	con cXXTarsHornOffset	

cLFFemurHornOffset1	con cXXFemurHornOffset
cLFTarsHornOffset1	con cXXTarsHornOffset	


;--------------------------------------------------------------------
;[MIN/MAX ANGLES]
cRRCoxaMin1     con -550      ;Mechanical limits of the Right Rear Leg
cRRCoxaMax1     con 550
cRRFemurMin1   	con -900
cRRFemurMax1   	con 550
cRRTibiaMin1   	con -400
cRRTibiaMax1   	con 750
cRRTarsMin1		con -1300	  ;4DOF ONLY - In theory the kinematics can reach about -160 deg
cRRTarsMax1		con 500		  ;4DOF ONLY - The kinematics will never exceed 23 deg though..

cRMCoxaMin1     con -550      ;Mechanical limits of the Right Middle Leg
cRMCoxaMax1     con 550
cRMFemurMin1   	con -900
cRMFemurMax1   	con 550
cRMTibiaMin1   	con -400
cRMTibiaMax1   	con 750
cRMTarsMin1		con -1300	  ;4DOF ONLY
cRMTarsMax1		con 500	  	  ;4DOF ONLY

cRFCoxaMin1     con -550      ;Mechanical limits of the Right Front Leg
cRFCoxaMax1     con 550
cRFFemurMin1   	con -900
cRFFemurMax1   	con 550
cRFTibiaMin1   	con -400
cRFTibiaMax1   	con 750
cRFTarsMin1		con -1300	  ;4DOF ONLY
cRFTarsMax1		con 500	      ;4DOF ONLY

cLRCoxaMin1     con -550      ;Mechanical limits of the Left Rear Leg
cLRCoxaMax1     con 550
cLRFemurMin1   	con -900
cLRFemurMax1   	con 550
cLRTibiaMin1   	con -400
cLRTibiaMax1   	con 750
cLRTarsMin1		con -1300	  ;4DOF ONLY
cLRTarsMax1		con 500	      ;4DOF ONLY

cLMCoxaMin1     con -550      ;Mechanical limits of the Left Middle Leg
cLMCoxaMax1     con 550
cLMFemurMin1   	con -900
cLMFemurMax1   	con 550
cLMTibiaMin1   	con -400
cLMTibiaMax1   	con 750
cLMTarsMin1		con -1300	  ;4DOF ONLY
cLMTarsMax1		con 500	      ;4DOF ONLY

cLFCoxaMin1     con -550      ;Mechanical limits of the Left Front Leg
cLFCoxaMax1     con 550
cLFFemurMin1   	con -900
cLFFemurMax1   	con 550
cLFTibiaMin1   	con -400
cLFTibiaMax1   	con 750
cLFTarsMin1		con -1300	  ;4DOF ONLY
cLFTarsMax1		con 500	      ;4DOF ONLY

;--------------------------------------------------------------------
;[LEG DIMENSIONS]
;Universal dimensions for each leg
cXXCoxaLength  	con 29		;Length of the Coxa [mm]
cXXFemurLength 	con 75		;Length of the Femur [mm]
cXXTibiaLength 	con 71		;Lenght of the Tibia [mm]
cXXTarsLength	con	85		;Lenght of the Tars [mm]

cRRCoxaLength   con cXXCoxaLength	;Rigth Rear leg
cRRFemurLength  con cXXFemurLength
cRRTibiaLength  con cXXTibiaLength
cRRTarsLength	con cXXTarsLength	;4DOF ONLY

cRMCoxaLength   con cXXCoxaLength	;Rigth middle leg
cRMFemurLength  con cXXFemurLength
cRMTibiaLength  con cXXTibiaLength
cRMTarsLength	con cXXTarsLength	;4DOF ONLY

cRFCoxaLength   con cXXCoxaLength	;Rigth front leg
cRFFemurLength  con cXXFemurLength
cRFTibiaLength  con cXXTibiaLength
cRFTarsLength	con cXXTarsLength	;4DOF ONLY

cLRCoxaLength   con cXXCoxaLength	;Left Rear leg
cLRFemurLength  con cXXFemurLength
cLRTibiaLength  con cXXTibiaLength
cLRTarsLength	con cXXTarsLength	;4DOF ONLY

cLMCoxaLength   con cXXCoxaLength	;Left middle leg
cLMFemurLength  con cXXFemurLength
cLMTibiaLength  con cXXTibiaLength
cLMTarsLength	con cXXTarsLength	;4DOF ONLY

cLFCoxaLength   con cXXCoxaLength	;Left front leg
cLFFemurLength  con cXXFemurLength
cLFTibiaLength  con cXXTibiaLength
cLFTarsLength	con cXXTarsLength	;4DOF ONLY
;--------------------------------------------------------------------
;[BODY DIMENSIONS]
cRRCoxaAngle1   con -450    ;Default Coxa setup angle, decimals = 1
cRMCoxaAngle1   con 0       ;Default Coxa setup angle, decimals = 1
cRFCoxaAngle1   con 450     ;Default Coxa setup angle, decimals = 1
cLRCoxaAngle1   con -450    ;Default Coxa setup angle, decimals = 1
cLMCoxaAngle1   con 0       ;Default Coxa setup angle, decimals = 1
cLFCoxaAngle1   con 450     ;Default Coxa setup angle, decimals = 1

cRROffsetX      con -53     ;Distance X from center of the body to the Right Rear coxa
cRROffsetZ      con 102     ;Distance Z from center of the body to the Right Rear coxa
cRMOffsetX      con -72     ;Distance X from center of the body to the Right Middle coxa
cRMOffsetZ      con 0       ;Distance Z from center of the body to the Right Middle coxa
cRFOffsetX      con -60     ;Distance X from center of the body to the Right Front coxa
cRFOffsetZ      con -102    ;Distance Z from center of the body to the Right Front coxa

cLROffsetX      con 53      ;Distance X from center of the body to the Left Rear coxa
cLROffsetZ      con 102     ;Distance Z from center of the body to the Left Rear coxa
cLMOffsetX      con 72      ;Distance X from center of the body to the Left Middle coxa
cLMOffsetZ      con 0       ;Distance Z from center of the body to the Left Middle coxa
cLFOffsetX      con 60      ;Distance X from center of the body to the Left Front coxa
cLFOffsetZ      con -102    ;Distance Z from center of the body to the Left Front coxa

;--------------------------------------------------------------------
;[START POSITIONS FEET]
cHexInitPosY   	con 18	   ;Global start hight
cHexInitXZ		con 102		
cHexInitXZCos45 con (cHexInitXZ * 0.707 + 0.5)
cHexInitXZSin45 con  (cHexInitXZ * 0.707 + 0.5)

cRRInitPosX 	con CHexInitXZCos45		;Start positions of the Right Rear leg
cRRInitPosY 	con cHexInitPosY
cRRInitPosZ 	con CHexInitXZSin45

cRMInitPosX 	con cHexInitXZ		;Start positions of the Right Middle leg
cRMInitPosY 	con cHexInitPosY
cRMInitPosZ 	con 0

cRFInitPosX 	con cHexInitXZCos45		;Start positions of the Right Front leg
cRFInitPosY 	con cHexInitPosY
cRFInitPosZ 	con -cHexInitXZSin45

cLRInitPosX 	con CHexInitXZCos45		;Start positions of the Left Rear leg
cLRInitPosY 	con cHexInitPosY
cLRInitPosZ 	con CHexInitXZSin45

cLMInitPosX 	con cHexInitXZ		;Start positions of the Left Middle leg
cLMInitPosY 	con cHexInitPosY
cLMInitPosZ 	con 0

cLFInitPosX 	con cHexInitXZCos45		;Start positions of the Left Front leg
cLFInitPosY 	con cHexInitPosY ; cXXInitPosY
cLFInitPosZ 	con -cHexInitXZSin45

;--------------------------------------------------------------------
;[Tars factors used in formula to calc Tarsus angle relative to the ground]
cTarsConst		con	720	;4DOF ONLY
cTarsMulti		con 2	;4DOF ONLY
cTarsFactorA	con 70	;4DOF ONLY
cTarsFactorB	con 60	;4DOF ONLY
cTarsFactorC	con 50	;4DOF ONLY
;--------------------------------------------------------------------