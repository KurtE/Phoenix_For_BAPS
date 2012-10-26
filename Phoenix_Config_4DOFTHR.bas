;Project Lynxmotion Phoenix
;Description: 4DOF THR, configuration file.
;	   Round body (xHR, with T-Hex 4DOF legs)
;      All Hardware connections (excl controls) and body dimensions 
;      are configurated in this file. Can be used with V2.1 and above
;Configuration version: V1.1 alfa
;Date: Oct 8 2011
;Programmers: Jeroen Janssen (aka Xan)
;			  Kåre Halvorsen (aka Zenta)
;			  Kurt (aka KurtE)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2, (See further for connections)
;
;NEW IN V2.1
;   - Added speaker constant
;	- Added support for different leg lengths
;	- Optional 4DOF
;	- Optional Safety shut down when voltage drops
;	- Servo Horn Offsets used with T-Hex legs.
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
cRRCoxaPin 		con P0	;Rear Right leg Hip Horizontal
cRRFemurPin 	con P1	;Rear Right leg Hip Vertical
cRRTibiaPin 	con P2	;Rear Right leg Knee
cRRTarsPin		con P3  ;Front Right leg foot

cRMCoxaPin 		con P4	;Middle Right leg Hip Horizontal
cRMFemurPin 	con P5	;Middle Right leg Hip Vertical
cRMTibiaPin 	con P6	;Middle Right leg Knee
cRMTarsPin		con P7  ;Middle Right leg foot

cRFCoxaPin 		con P8	;Front Right leg Hip Horizontal
cRFFemurPin 	con P9	;Front Right leg Hip Vertical
cRFTibiaPin 	con P10	;Front Right leg Knee
cRFTarsPin		con P11 ;Rear Right leg foot

cLRCoxaPin 		con P16	;Rear Left leg Hip Horizontal
cLRFemurPin 	con P17	;Rear Left leg Hip Vertical
cLRTibiaPin 	con P18	;Rear Left leg Knee
cLRTarsPin		con P19 ;Front Left leg foot

cLMCoxaPin 		con P20	;Middle Left leg Hip Horizontal
cLMFemurPin 	con P21	;Middle Left leg Hip Vertical
cLMTibiaPin 	con P22	;Middle Left leg Knee
cLMTarsPin		con P23	;Middle Left leg foot

cLFCoxaPin 		con P24	;Front Left leg Hip Horizontal
cLFFemurPin 	con P25	;Front Left leg Hip Vertical
cLFTibiaPin 	con P26	;Front Left leg Knee
cLFTarsPin		con P27 ;Rear Left leg foot

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
; T-HEX 4DOF legs
cRRCoxaMin1     con -650      ;Mechanical limits of the Right Rear Leg
cRRCoxaMax1     con 650
cRRFemurMin1   	con -1050
cRRFemurMax1   	con 750
cRRTibiaMin1   	con -530
cRRTibiaMax1   	con 900
cRRTarsMin1		con -1300	  ;4DOF ONLY - In theory the kinematics can reach about -160 deg
cRRTarsMax1		con 500		  ;4DOF ONLY - The kinematics will never exceed 23 deg though..

cRMCoxaMin1     con -650      ;Mechanical limits of the Right Middle Leg
cRMCoxaMax1     con 650
cRMFemurMin1   	con -1050
cRMFemurMax1   	con 750
cRMTibiaMin1   	con -530
cRMTibiaMax1   	con 900
cRMTarsMin1		con -1300	  ;4DOF ONLY
cRMTarsMax1		con 500	  	  ;4DOF ONLY

cRFCoxaMin1		con -650	;Mechanical limits of the Right Front Leg, decimals = 1
cRFCoxaMax1		con 650
cRFFemurMin1	con -1050
cRFFemurMax1	con 750
cRFTibiaMin1	con -530
cRFTibiaMax1	con 900
cRFTarsMin1		con -1300
cRFTarsMax1		con 500

cLRCoxaMin1     con -650      ;Mechanical limits of the Left Rear Leg
cLRCoxaMax1     con 650
cLRFemurMin1   	con -1050
cLRFemurMax1   	con 750
cLRTibiaMin1   	con -530
cLRTibiaMax1   	con 900
cLRTarsMin1		con -1300	  ;4DOF ONLY
cLRTarsMax1		con 500	      ;4DOF ONLY

cLMCoxaMin1     con -650      ;Mechanical limits of the Left Middle Leg
cLMCoxaMax1     con 650
cLMFemurMin1   	con -1050
cLMFemurMax1   	con 750
cLMTibiaMin1   	con -530
cLMTibiaMax1   	con 900
cLMTarsMin1		con -1300	  ;4DOF ONLY
cLMTarsMax1		con 500	      ;4DOF ONLY

cLFCoxaMin1     con -650      ;Mechanical limits of the Left Front Leg
cLFCoxaMax1     con 650
cLFFemurMin1	con -1050
cLFFemurMax1	con 750
cLFTibiaMin1	con -530
cLFTibiaMax1	con 900
cLFTarsMin1		con -1300
cLFTarsMax1		con 500

;--------------------------------------------------------------------
;[LEG DIMENSIONS]
;Universal dimensions for each leg
cXXCoxaLength  	con 29		;Length of the Coxa [mm]
cXXFemurLength 	con 75		;Length of the Femur [mm]
cXXTibiaLength 	con 71		;Lenght of the Tibia [mm]
cXXTarsLength	con	85		;Lenght of the Tars [mm]
; end of added stuff

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
cRRCoxaAngle1   con -600    ;Default Coxa setup angle, decimals = 1
cRMCoxaAngle1   con 0       ;Default Coxa setup angle, decimals = 1
cRFCoxaAngle1   con 600     ;Default Coxa setup angle, decimals = 1
cLRCoxaAngle1   con -600    ;Default Coxa setup angle, decimals = 1
cLMCoxaAngle1   con 0       ;Default Coxa setup angle, decimals = 1
cLFCoxaAngle1   con 600     ;Default Coxa setup angle, decimals = 1

cRROffsetX 		con -69     ;Distance X from center of the body to the Right Rear coxa
cRROffsetZ 		con 119     ;Distance Z from center of the body to the Right Rear coxa
cRMOffsetX 		con -138    ;Distance X from center of the body to the Right Middle coxa
cRMOffsetZ 		con 0       ;Distance Z from center of the body to the Right Middle coxa
cRFOffsetX 		con -69     ;Distance X from center of the body to the Right Front coxa
cRFOffsetZ 		con -119    ;Distance Z from center of the body to the Right Front coxa

cLROffsetX 		con 69      ;Distance X from center of the body to the Left Rear coxa
cLROffsetZ 		con 119     ;Distance Z from center of the body to the Left Rear coxa
cLMOffsetX 		con 138     ;Distance X from center of the body to the Left Middle coxa
cLMOffsetZ 		con 0       ;Distance Z from center of the body to the Left Middle coxa
cLFOffsetX 		con 69      ;Distance X from center of the body to the Left Front coxa
cLFOffsetZ 		con -119    ;Distance Z from center of the body to the Left Front coxa

;--------------------------------------------------------------------
;[START POSITIONS FEET]
; THEX legs
cHexInitPosY	con 30
cHexInitXZ		con 80		
cHexInitXZCos60  con (cHexInitXZ * 0.5 + 0.5)
cHexInitXZSin60 con  (cHexInitXZ * 0.866 + 0.5)

cRRInitPosX 	con CHexInitXZCos60		;Start positions of the Right Rear leg
cRRInitPosY 	con cHexInitPosY
cRRInitPosZ 	con CHexInitXZSin60

cRMInitPosX 	con cHexInitXZ		;Start positions of the Right Middle leg
cRMInitPosY 	con cHexInitPosY
cRMInitPosZ 	con 0

cRFInitPosX 	con cHexInitXZCos60		;Start positions of the Right Front leg
cRFInitPosY 	con cHexInitPosY
cRFInitPosZ 	con -cHexInitXZSin60

cLRInitPosX 	con CHexInitXZCos60		;Start positions of the Left Rear leg
cLRInitPosY 	con cHexInitPosY
cLRInitPosZ 	con CHexInitXZSin60

cLMInitPosX 	con cHexInitXZ		;Start positions of the Left Middle leg
cLMInitPosY 	con cHexInitPosY
cLMInitPosZ 	con 0

cLFInitPosX 	con cHexInitXZCos60		;Start positions of the Left Front leg
cLFInitPosY 	con cHexInitPosY ; cXXInitPosY
cLFInitPosZ 	con -cHexInitXZSin60

;--------------------------------------------------------------------
;[Tars factors used in formula to calc Tarsus angle relative to the ground]
cTarsConst		con	720	;4DOF ONLY
cTarsMulti		con 2	;4DOF ONLY
cTarsFactorA	con 70	;4DOF ONLY
cTarsFactorB	con 60	;4DOF ONLY
cTarsFactorC	con 50	;4DOF ONLY
;--------------------------------------------------------------------