;USE_IDLEPROC con 1
;Project Lynxmotion Phoenix
;Description: Phoenix software
;Software version: V2.1 alfa
;Date: 19-04-2011
;Programmer: Jeroen Janssen (aka Xan)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2
;
;NEW IN V2.1
;	- Improved SSC sync function (K�re)
;	- Added a commit function for the SSC
;	- Changed SSC command set to binary mode (Kurt)
;	- Added new gaits and improved gait engine with 5 lifted leg positions (K�re)
;	- Added support for different leg lengths
;	- Optional 4DOF (Configure at cfg file)
;	- Single point of configuration for the Angle to PWM calculations (K�re)
;	- Optional Safety turn off when voltage drops below setpoint
;	- Moved SSC and BAP timer functions to a separate Driver file
;	- Variable speed for GP sequences
;
;KNOWN BUGS:
;	- None at the moment ;)
;
;Project file order:
;	1. Phoenix_Config_xxx.bas
;	2. Phoenix_Core.bas
;	3. Phoenix_Control_xxx.bas
;	4. Phoenix_Driver_xxx.bas
;====================================================================
;[CONSTANTS]
BUTTON_DOWN con 0
BUTTON_UP 	con 1

c1DEC		con 10
c2DEC		con 100
c4DEC		con 10000
c6DEC		con 1000000

cRR			con 0
cRM			con 1
cRF			con 2
cLR			con 3
cLM			con 4
cLF			con 5
;--------------------------------------------------------------------
;[TABLES]
;ArcCosinus Table
;Table build in to 3 part to get higher accuracy near cos = 1. 
;The biggest error is near cos = 1 and has a biggest value of 3*0.012098rad = 0.521 deg.
;-	Cos 0 to 0.9 is done by steps of 0.0079 rad. (1/127)
;-	Cos 0.9 to 0.99 is done by steps of 0.0008 rad (0.1/127)
;-	Cos 0.99 to 1 is done by step of 0.0002 rad (0.01/64)
;Since the tables are overlapping the full range of 127+127+64 is not necessary. Total bytes: 277
GetACos bytetable	255,254,252,251,250,249,247,246,245,243,242,241,240,238,237,236,234,233,232,231,229,228,227,225, |
					224,223,221,220,219,217,216,215,214,212,211,210,208,207,206,204,203,201,200,199,197,196,195,193, |
					192,190,189,188,186,185,183,182,181,179,178,176,175,173,172,170,169,167,166,164,163,161,160,158, |
					157,155,154,152,150,149,147,146,144,142,141,139,137,135,134,132,130,128,127,125,123,121,119,117, |
					115,113,111,109,107,105,103,101,98,96,94,92,89,87,84,81,79,76,73,73,73,72,72,72,71,71,71,70,70, |
					70,70,69,69,69,68,68,68,67,67,67,66,66,66,65,65,65,64,64,64,63,63,63,62,62,62,61,61,61,60,60,59, |
					59,59,58,58,58,57,57,57,56,56,55,55,55,54,54,53,53,53,52,52,51,51,51,50,50,49,49,48,48,47,47,47, |
					46,46,45,45,44,44,43,43,42,42,41,41,40,40,39,39,38,37,37,36,36,35,34,34,33,33,32,31,31,30,29,28, |
					28,27,26,25,24,23,23,23,23,22,22,22,22,21,21,21,21,20,20,20,19,19,19,19,18,18,18,17,17,17,17,16, |
					16,16,15,15,15,14,14,13,13,13,12,12,11,11,10,10,9,9,8,7,6,6,5,3,0
					
;Sin table 90 deg, persision 0.5 deg (180 values)
GetSin wordtable 0, 87, 174, 261, 348, 436, 523, 610, 697, 784, 871, 958, 1045, 1132, 1218, 1305, 1391, 1478, 1564, |
				 1650, 1736, 1822, 1908, 1993, 2079, 2164, 2249, 2334, 2419, 2503, 2588, 2672, 2756, 2840, 2923, 3007, |
				 3090, 3173, 3255, 3338, 3420, 3502, 3583, 3665, 3746, 3826, 3907, 3987, 4067, 4146, 4226, 4305, 4383, |
				 4461, 4539, 4617, 4694, 4771, 4848, 4924, 4999, 5075, 5150, 5224, 5299, 5372, 5446, 5519, 5591, 5664, |
				 5735, 5807, 5877, 5948, 6018, 6087, 6156, 6225, 6293, 6360, 6427, 6494, 6560, 6626, 6691, 6755, 6819, |
				 6883, 6946, 7009, 7071, 7132, 7193, 7253, 7313, 7372, 7431, 7489, 7547, 7604, 7660, 7716, 7771, 7826, |
				 7880, 7933, 7986, 8038, 8090, 8141, 8191, 8241, 8290, 8338, 8386, 8433, 8480, 8526, 8571, 8616, 8660, |
				 8703, 8746, 8788, 8829, 8870, 8910, 8949, 8987, 9025, 9063, 9099, 9135, 9170, 9205, 9238, 9271, 9304, |
				 9335, 9366, 9396, 9426, 9455, 9483, 9510, 9537, 9563, 9588, 9612, 9636, 9659, 9681, 9702, 9723, 9743, |
				 9762, 9781, 9799, 9816, 9832, 9848, 9862, 9876, 9890, 9902, 9914, 9925, 9935, 9945, 9953, 9961, 9969, |
				 9975, 9981, 9986, 9990, 9993, 9996, 9998, 9999, 10000


;Build tables for Leg configuration like I/O and MIN/MAX values to easy access values using a FOR loop
;Constants are still defined as single values in the cfg file to make it easy to read/configure

;SSC Pin numbers
cCoxaPin 	byteTable cRRCoxaPin,  cRMCoxaPin,  cRFCoxaPin,  cLRCoxaPin,  cLMCoxaPin,  cLFCoxaPin
cFemurPin 	byteTable cRRFemurPin, cRMFemurPin, cRFFemurPin, cLRFemurPin, cLMFemurPin, cLFFemurPin
cTibiaPin 	byteTable cRRTibiaPin, cRMTibiaPin, cRFTibiaPin, cLRTibiaPin, cLMTibiaPin, cLFTibiaPin
#ifdef c4DOF
cTarsPin 	byteTable cRRTarsPin, cRMTarsPin, cRFTarsPin, cLRTarsPin, cLMTarsPin, cLFTarsPin
#endif

; Servo Offset Table
cFemurHornOffset1 	swordTable cRRFemurHornOffset1,  cRMFemurHornOffset1,  cRFFemurHornOffset1,  cLRFemurHornOffset1,  cLMFemurHornOffset1,  cLFFemurHornOffset1
#ifdef c4DOF
cTarsHornOffset1 	swordTable cRRTarsHornOffset1,  cRMTarsHornOffset1,  cRFTarsHornOffset1,  cLRTarsHornOffset1,  cLMTarsHornOffset1,  cLFTarsHornOffset1
#endif

;Min / Max values
cCoxaMin1 	swordTable cRRCoxaMin1,  cRMCoxaMin1,  cRFCoxaMin1,  cLRCoxaMin1,  cLMCoxaMin1,  cLFCoxaMin1
cCoxaMax1 	swordTable cRRCoxaMax1,  cRMCoxaMax1,  cRFCoxaMax1,  cLRCoxaMax1,  cLMCoxaMax1,  cLFCoxaMax1
cFemurMin1 	swordTable cRRFemurMin1, cRMFemurMin1, cRFFemurMin1, cLRFemurMin1, cLMFemurMin1, cLFFemurMin1
cFemurMax1 	swordTable cRRFemurMax1, cRMFemurMax1, cRFFemurMax1, cLRFemurMax1, cLMFemurMax1, cLFFemurMax1
cTibiaMin1 	swordTable cRRTibiaMin1, cRMTibiaMin1, cRFTibiaMin1, cLRTibiaMin1, cLMTibiaMin1, cLFTibiaMin1
cTibiaMax1 	swordTable cRRTibiaMax1, cRMTibiaMax1, cRFTibiaMax1, cLRTibiaMax1, cLMTibiaMax1, cLFTibiaMax1
#ifdef c4DOF
cTarsMin1 	swordTable cRRTarsMin1, cRMTarsMin1, cRFTarsMin1, cLRTarsMin1, cLMTarsMin1, cLFTarsMin1
cTarsMax1 	swordTable cRRTarsMax1, cRMTarsMax1, cRFTarsMax1, cLRTarsMax1, cLMTarsMax1, cLFTarsMax1
#endif

;Leg Lengths
cCoxaLength  sbyteTable cRRCoxaLength,  cRMCoxaLength,  cRFCoxaLength,  cLRCoxaLength,  cLMCoxaLength,  cLFCoxaLength
cFemurLength sbyteTable cRRFemurLength, cRMFemurLength, cRFFemurLength, cLRFemurLength, cLMFemurLength, cLFFemurLength
cTibiaLength sbyteTable cRRTibiaLength, cRMTibiaLength, cRFTibiaLength, cLRTibiaLength, cLMTibiaLength, cLFTibiaLength
#ifdef c4DOF
cTarsLength	 sbytetable cRRTarsLength, cRMTarsLength, cRFTarsLength, cLRTarsLength, cLMTarsLength, cLFTarsLength
#endif

;Body Offsets (distance between the center of the body and the center of the coxa)
cOffsetX	sbyteTable cRROffsetX, cRMOffsetX, cRFOffsetX, cLROffsetX, cLMOffsetX, cLFOffsetX
cOffsetZ	sbyteTable cRROffsetZ, cRMOffsetZ, cRFOffsetZ, cLROffsetZ, cLMOffsetZ, cLFOffsetZ

;Default leg angle
cCoxaAngle1 swordTable cRRCoxaAngle1, cRMCoxaAngle1, cRFCoxaAngle1, cLRCoxaAngle1, cLMCoxaAngle1, cLFCoxaAngle1

;Start positions for the leg
cInitPosX	swordTable cRRInitPosX, cRMInitPosX, cRFInitPosX, cLRInitPosX, cLMInitPosX, cLFInitPosX
cInitPosY	swordTable cRRInitPosY, cRMInitPosY, cRFInitPosY, cLRInitPosY, cLMInitPosY, cLFInitPosY
cInitPosZ	swordTable cRRInitPosZ, cRMInitPosZ, cRFInitPosZ, cLRInitPosZ, cLMInitPosZ, cLFInitPosZ
;--------------------------------------------------------------------
;[REMOTE]				 
cTravelDeadZone	con 4	;The deadzone for the analog input from the remote
;====================================================================
;[ANGLES]
CoxaAngle1		var sword(6)	;Actual Angle of the horizontal hip, decimals = 1
FemurAngle1		var sword(6)	;Actual Angle of the vertical hip, decimals = 1
TibiaAngle1		var sword(6)	;Actual Angle of the knee, decimals = 1
#ifdef c4DOF
TarsAngle1		var sword(6)	;Actual Angle of the knee, decimals = 1
#endif
;--------------------------------------------------------------------
;[POSITIONS SINGLE LEG CONTROL]
SLHold	var bit		 	;Single leg control mode

LegPosX	var sword(6)	;Actual X Posion of the Leg
LegPosY	var sword(6)	;Actual Y Posion of the Leg
LegPosZ	var sword(6)	;Actual Z Posion of the Leg
;--------------------------------------------------------------------
;[INPUTS]
butA 	var bit
butB 	var bit
butC 	var bit

prev_butA var bit
prev_butB var bit
prev_butC var bit
;--------------------------------------------------------------------
;[GP PLAYER]
GPStart		var byte		;Start the GP Player
GPSeq		var byte		;Number of the sequence
GPEnable	var bit			;Enables the GP player when the SSC version ends with "GP<cr>"
GPSM		var sword		;Speed Multiply ratio +- 200
;--------------------------------------------------------------------
;[OUTPUTS]
LedA var bit	;Red
LedB var bit	;Green
LedC var bit	;Orange
Eyes var bit	;Eyes output
;--------------------------------------------------------------------
;[VARIABLES]
Index 			var byte		;Index universal used
LegIndex		var byte		;Index used for leg Index Number

;GetSinCos / ArcCos
AngleDeg1 		var sword		;Input Angle in degrees, decimals = 1
ABSAngleDeg1 	var word		;Absolute value of the Angle in Degrees, decimals = 1
sin4         	var sword		;Output Sinus of the given Angle, decimals = 4
cos4			var sword		;Output Cosinus of the given Angle, decimals = 4
AngleRad4		var sword		;Output Angle in radials, decimals = 4
NegativeValue	var bit			;If the the value is Negative

;GetAtan2
AtanX			var sword		;Input X
AtanY			var sword		;Input Y
Atan4			var sword		;ArcTan2 output
XYhyp2			var sword		;Output presenting Hypotenuse of X and Y

;Body position
BodyPosX 		var sbyte		;Global Input for the position of the body
BodyPosY 		var sword
BodyPosZ 		var sbyte

;Body Forward Rotation Kinematics
BodyRotX1 				var sword ;Global Input pitch of the body
BodyRotY1				var sword ;Global Input rotation of the body
BodyRotZ1  				var sword ;Global Input roll of the body
PosX					var sword ;Input position of the feet X
PosZ					var sword ;Input position of the feet Z
PosY					var sword ;Input position of the feet Y
RotationY				var sbyte ;Input for rotation of a single feet for the gait
sinA4          			var sword ;Sin buffer for BodyRotX calculations
cosA4          			var sword ;Cos buffer for BodyRotX calculations
sinB4          			var sword ;Sin buffer for BodyRotX calculations
cosB4          			var sword ;Cos buffer for BodyRotX calculations
sinG4          			var sword ;Sin buffer for BodyRotZ calculations
cosG4          			var sword ;Cos buffer for BodyRotZ calculations
CPR_X					var sword ;Center Point of Rotation for the body on X axis
CPR_Y					var sword ;Center Point of Rotation for the body on Y axis
CPR_Z					var sword ;Center Point of Rotation for the body on Z axis
BodyFKPosX				var sword ;Output Position X of feet with Rotation
BodyFKPosY				var sword ;Output Position Y of feet with Rotation
BodyFKPosZ				var sword ;Output Position Z of feet with Rotation
BodyRotOffsetX			var sword ;Offset for the Center Point of Rotation for the body
BodyRotOffsetY			var sword ;Offset for the Center Point of Rotation for the body
BodyRotOffsetZ			var sword ;Offset for the Center Point of Rotation for the body

;Leg Inverse Kinematics
IKFeetPosX	    	var sword	;Input position of the Feet X
IKFeetPosY	    	var sword	;Input position of the Feet Y
IKFeetPosZ			var sword	;Input Position of the Feet Z
IKFeetPosXZ			var sword	;Diagonal direction from Input X and Z
#ifdef c4DOF
TarsOffsetXZ		var sword	;Vector value \ ;
TarsOffsetY			var sword	;Vector value / The 2 DOF IK calcs (femur and tibia) are based upon these vectors
TarsToGroundAngle1	var sword   ;Angle between tars and ground. Note: the angle are 0 when the tars are perpendicular to the ground
TGA_A_H4			var sword
TGA_B_H3			var sword
#else
TarsOffsetXZ		con 0		;Vector value \ ;
TarsOffsetY			con 0		;Vector value / The 2 DOF IK calcs (femur and tibia) are based upon these vectors
#endif
IKSW2				var long	;Length between Shoulder and Wrist, decimals = 2
IKA14		    	var long	;Angle of the line S>W with respect to the ground in radians, decimals = 4
IKA24		    	var long	;Angle of the line S>W with respect to the femur in radians, decimals = 4
Temp1				var long
Temp2				var long
IKSolution			var bit		;Output true if the solution is possible
IKSolutionWarning 	var bit		;Output true if the solution is NEARLY possible
IKSolutionError		var bit		;Output true if the solution is NOT possible
;--------------------------------------------------------------------
;[TIMING]
lCurrentTime		var long	
lTimerStart			var long	;Start time of the calculation cycles
lTimerEnd			var long 	;End time of the calculation cycles
CycleTime			var word	;Total Cycle time

SSCTime  			var word	;Time for servo updates
PrevSSCTime			var word	;Previous time for the servo updates

InputTimeDelay		var byte	;Delay that depends on the input to get the "sneaking" effect
SpeedControl		var word	;Adjustible Delay
;--------------------------------------------------------------------
;[GLOABAL]
HexOn	 			var bit		;Switch to turn on Phoenix
Prev_HexOn			var bit		;Previous loop state 

SafetyShutDown 		var bit		;If 1 the bot shuts down because the input voltage is to low
Voltage				var word	;Voltage value
;--------------------------------------------------------------------
;[Balance]
BalanceMode			var bit
TotalTransX			var sword
TotalTransZ			var sword
TotalTransY			var sword
TotalYbal1			var sword
TotalXBal1			var sword
TotalZBal1			var sword
TotalY				var sword ;Total Y distance between the center of the body and the feet

;[Single Leg Control]
SelectedLeg			var byte
Prev_SelectedLeg	var byte
SLLegX				var sword
SLLegY				var sword
SLLegZ				var sword
AllDown				var bit

;[gait]
NrOfGaits		var nib		;Current amount of Gaits in program
GaitType		var byte	;Gait type
NomGaitSpeed	var byte	;Nominal speed of the gait

LegLiftHeight 	var byte	;Current Travel height
TravelLengthX 	var sword	;Current Travel length X
TravelLengthZ 	var sword	;Current Travel length Z
TravelRotationY var sword	;Current Travel Rotation Y

TLDivFactor		var byte	;Number of steps that a leg is on the floor while walking
NrLiftedPos   	var nib		;Number of positions that a single leg is lifted (1-3)
HalfLiftHeigth	var nib		;3/3, 3/6, 3/4 the outer positions of the ligted legs will be half height
LiftDivFactor	var nib		;Normaly: 2, when NrLiftedPos=5: 4

TravelRequest 	var bit		;Temp to check if the gait is in motion
StepsInGait		var byte	;Number of steps in gait
LastLeg 		var bit		;TRUE when the current leg is the last leg of the sequence
GaitStep 	 	var byte	;Actual Gait step

GaitLegNr		var byte(6)	;Init position of the leg

GaitLegNrIn	 	var byte	;Input Number of the leg

GaitPosX 		var sbyte(6) ;Array containing Relative X position corresponding to the Gait
GaitPosY 		var sbyte(6) ;Array containing Relative Y position corresponding to the Gait
GaitPosZ 		var sbyte(6) ;Array containing Relative Z position corresponding to the Gait
GaitRotY 		var sbyte(6) ;Array containing Relative Y rotation corresponding to the Gait

GaitPeak		var byte	; Saving the largest (ABS) peak value from GaitPosX,Y,Z and GaitRotY
Walking			var bit		; True if the robot are walking

;====================================================================
;[INIT]

  ; DEBUG: setup  only on Arc32...

#ifdef BASICATOMPROARC32
  pause 500
  sethserial1 H38400
  hserout 1, ["Phoenix Arc32 New XBee test", 13]
#endif

;Checks SSC version number if it ends with "GP"
;enable the GP player if it does
#ifndef cNOGP
GOSUB CheckGPEnable[], GPEnable
#endif
pause 10

;Turning off all the leds
LedA = 0
LedB = 0
LedC = 0
Eyes = 0
  
;Tars Init Positions
for LegIndex  = 0 to 5
  LegPosX(LegIndex) = cInitPosX(LegIndex)	;Set start positions for each leg
  LegPosY(LegIndex) = cInitPosY(LegIndex)
  LegPosZ(LegIndex) = cInitPosZ(LegIndex)  
next

;Single leg control. Make sure no leg is selected
SelectedLeg = 255 ; No Leg selected
Prev_SelectedLeg = 255
AllDown = 1  ; Init to say everything is down...

;Body Positions
BodyPosX = 0
BodyPosY = 0
BodyPosZ = 0

;Body Rotations
BodyRotX1 = 0
BodyRotY1 = 0
BodyRotZ1 = 0

;Gait
GaitType = 0
BalanceMode = 0
LegLiftHeight = 50
GaitStep = 1
GOSUB GaitSelect

;Initialize Timer
GOSUB InitTimer
enable					;enables all interrupts

;Initialize Controller
gosub InitController

#ifdef USE_IDLEPROC
gosub InitIdleProc
#endif

;SSC
SSCTime = 150
HexOn = 0
SafetyShutDown = 0 
GPSM = 100		; default to 100 percent of the speed 
;====================================================================
;[MAIN]	
main:

  'Start time
  GOSUB GetCurrentTime[], lTimerStart 
  
  ;Read input
  IF NOT SafetyShutDown THEN
  	GOSUB ControlInput	
    GOSUB ReadButtons	;I/O used by the remote
  ENDIF  
  GOSUB WriteOutputs	;Write Outputs
  GOSUB CheckVoltage	;Check input voltage

  ;GP Player
#ifndef cNOGP
  IF GPEnable THEN
    GOSUB GPPlayer
    IF GPStart <> 0 THEN Main
  ENDIF
#endif
  
#ifndef cNoSL
  ;Single leg control
  GOSUB SingleLegControl 
#endif
  ;Gait
  GOSUB GaitSeq
 
  ;Balance calculations
  TotalTransX = 0 'reset values used for calculation of balance
  TotalTransZ = 0
  TotalTransY = 0
  TotalXBal1 = 0
  TotalYBal1 = 0
  TotalZBal1 = 0
  IF (BalanceMode>0) THEN
    for LegIndex = 0 to 2	; balance calculations for all Right legs
      gosub BalCalcOneLeg [-LegPosX(LegIndex)+GaitPosX(LegIndex), |
      						LegPosZ(LegIndex)+GaitPosZ(LegIndex), |
      						(LegPosY(LegIndex)-cInitPosY(LegIndex))+GaitPosY(LegIndex), |
      						LegIndex]
    next
    
    for LegIndex = 3 to 5	; balance calculations for all Left legs
      gosub BalCalcOneLeg [LegPosX(LegIndex)+GaitPosX(LegIndex), |
    						LegPosZ(LegIndex)+GaitPosZ(LegIndex), |
    						(LegPosY(LegIndex)-cInitPosY(LegIndex))+GaitPosY(LegIndex), |
    						LegIndex]
    next
	gosub BalanceBody
  ENDIF
   
  'Reset IKsolution indicators 
  IKSolution = 0 
  IKSolutionWarning = 0 
  IKSolutionError = 0 

  ;Do IK for all Right legs
  for LegIndex = 0 to 2	
	  GOSUB BodyFK [-LegPosX(LegIndex)+BodyPosX+GaitPosX(LegIndex) - TotalTransX, |
	  				 LegPosZ(LegIndex)+BodyPosZ+GaitPosZ(LegIndex) - TotalTransZ, |
	  				 LegPosY(LegIndex)+BodyPosY+GaitPosY(LegIndex) - TotalTransY, |
	  				 GaitRotY(LegIndex), LegIndex] 
	  GOSUB LegIK [LegPosX(LegIndex)-BodyPosX+BodyFKPosX-(GaitPosX(LegIndex) - TotalTransX), |
	  				LegPosY(LegIndex)+BodyPosY-BodyFKPosY+GaitPosY(LegIndex) - TotalTransY, |
	  				LegPosZ(LegIndex)+BodyPosZ-BodyFKPosZ+GaitPosZ(LegIndex) - TotalTransZ, LegIndex]    
  next  
  
  ;Do IK for all Left legs  
  for LegIndex = 3 to 5	
	  GOSUB BodyFK [LegPosX(LegIndex)-BodyPosX+GaitPosX(LegIndex) - TotalTransX, |
	  				LegPosZ(LegIndex)+BodyPosZ+GaitPosZ(LegIndex) - TotalTransZ, |
	  				LegPosY(LegIndex)+BodyPosY+GaitPosY(LegIndex) - TotalTransY, |
	  				GaitRotY(LegIndex), LegIndex] 
	  GOSUB LegIK [LegPosX(LegIndex)+BodyPosX-BodyFKPosX+GaitPosX(LegIndex) - TotalTransX, |
	  				LegPosY(LegIndex)+BodyPosY-BodyFKPosY+GaitPosY(LegIndex) - TotalTransY, |
	  				LegPosZ(LegIndex)+BodyPosZ-BodyFKPosZ+GaitPosZ(LegIndex) - TotalTransZ, LegIndex] 
  next
  
  ;Check mechanical limits
  GOSUB CheckAngles

  ;Write IK errors to leds
  LedC = IKSolutionWarning
  LedA = IKSolutionError

  ;Drive Servos
  IF HexOn THEN
    IF HexOn AND Prev_HexOn=0 THEN
      Sound cSpeakerPin,[60\4000,80\4500,100\5000]
      Eyes = 1
  	ENDIF

    ;Set SSC time
  	IF(ABS(TravelLengthX)>cTravelDeadZone | ABS(TravelLengthZ)>cTravelDeadZone | ABS(TravelRotationY*2)>cTravelDeadZone) THEN
  	  SSCTime = NomGaitSpeed + (InputTimeDelay*2) + SpeedControl
  	  
	  ;Add aditional delay when Balance mode is on
      IF BalanceMode THEN
 	    SSCTime = SSCTime + 100
      ENDIF
      
	ELSE ;Movement speed excl. Walking
	  SSCTime = 200 + SpeedControl
  	ENDIF

	; Update servo positions without commiting
	GOSUB UpdateServoDriver 

   ;Sync BAP with SSC while walking to ensure the prev is completed before sending the next one
   GaitPeak = 0 ;Reset
   LegIndex = 0
    ; Finding any the biggest value for GaitPos/Rot:
   WHILE (LegIndex < 6) AND NOT (GaitPeak > 2);Walking 
      GaitPeak = ABS(GaitPosX(LegIndex)) MIN |
               ABS(GaitPosY(LegIndex)) MIN |
               ABS(GaitPosZ(LegIndex)) MIN |
               ABS(GaitRotY(LegIndex)) MIN |
               GaitPeak
      
      LegIndex = LegIndex+1
   WEND

   IF (GaitPeak > 2)  or Walking THEN ; Walking, sync required
      Walking = (GaitPeak > 2)      ; This make sure the last walking cycle to be synced
       ;Get endtime and calculate wait time
#ifdef BACKGROUND_CHECK_INPUT
      GOSUB DelayWithBackgroundInput[PrevSSCTime]	; do the delay
#else	  
       ;Wait for previous commands to be completed while walking
      GOSUB GetCurrentTime[], lTimerEnd   
      GOSUB ConvertTimeMS[lTimerEnd-lTimerStart], CycleTime
	  if (PrevSSCTime > CycleTime) then 
      	pause (PrevSSCTime - CycleTime) ;   Min 1 ensures that there alway is a value in the pause command  
      endif 	
#endif
#ifdef BACKGROUND_CHECK_INPUT
   ELSE
      GOSUB DelayWithBackgroundInput[50]	; do the delay
#endif	  

   ENDIF

   ; Commit servo positions - Note: moved here by Kurt
   GOSUB CommitServoDriver  

 ELSE
  
    ;Turn the bot off
    IF (Prev_HexOn OR NOT AllDown) THEN
      SSCTime = 600
      GOSUB UpdateServoDriver
   	  GOSUB CommitServoDriver ;Send commit before pause command
      Sound cSpeakerPin,[100\5000,80\4500,60\4000]      

#ifdef BACKGROUND_CHECK_INPUT
      GOSUB GetCurrentTime[], lTimerStart   
      GOSUB DelayWithBackgroundInput[600]	; do the delay
#else
      pause 600
#endif
    ELSE   
#ifdef BACKGROUND_CHECK_INPUT
      GOSUB GetCurrentTime[], lTimerStart   
      GOSUB DelayWithBackgroundInput[50]	; do the delay
#endif
	  GOSUB FreeServos
	  Eyes = 0
    ENDIF
#ifdef USE_IDLEPROC
	gosub IdleProc
#endif


  ENDIF	

#ifdef NeededHere ;???  
  ; Commit servo positions
  GOSUB CommitServoDriver  
#endif  
  ;Store previous HexOn State
  IF HexOn THEN
    Prev_HexOn = 1
  ELSE
    Prev_HexOn = 0
  ENDIF
  
goto main

;====================================================================
; [DelayWithBackgroundInput]
;====================================================================
#ifdef BACKGROUND_CHECK_INPUT
_wDelayMS var word		
DelayWithBackgroundInput[_wDelayMS]:
	GOSUB GetCurrentTime[], lTimerEnd   
    GOSUB ConvertTimeMS[lTimerEnd-lTimerStart], CycleTime
	if (_wDelayMS > CycleTime) then 
	    WHILE ((_wDelayMS > CycleTime) and ((_wDelayMS - CycleTime) > BACKGROUND_CHECK_INPUT))
;	      hserout 1, ["BCI ", dec PrevSSCTime, " > ", dec CycleTime, "(", dec lTimerEnd, "-", dec lTimerStart,")", 13]
	      GOSUB ControlBackgroundInput	; Read in any pending inputs as to not overflow queues
	      pause 5;	// sleep at least a little...	
	      GOSUB GetCurrentTime[], lTimerEnd   
          GOSUB ConvertTimeMS[lTimerEnd-lTimerStart], CycleTime
	    WEND
		if (_wDelayMS > CycleTime) then 
			pause (_wDelayMS - CycleTime)
	    endif
	endif
	return 
#endif

;dead:
;goto dead
;====================================================================
;[ReadButtons] Reading input buttons from the ABB
ReadButtons:
  input P4
  input P5
  input P6
	
  prev_butA = butA
  prev_butB = butB
  prev_butC = butC
	
  butA = IN4
  butB = IN5
  butC = IN6
return
;--------------------------------------------------------------------
;[WriteOutputs] Updates the state of the leds
WriteOutputs:
  IF ledA = 1 THEN
	low p4
  ENDIF
  IF ledB = 1 THEN
	low p5
  ENDIF
  IF ledC = 1 THEN
	low p6
  ENDIF
  IF Eyes = 0 THEN
    low cEyesPin
  ELSE
    high cEyesPin
  ENDIF
return
;--------------------------------------------------------------------
;[CHECK VOLTAGE]
;Reads the input voltage and shuts down the bot when the power drops
CheckVoltage:
#IFDEF cTurnOffVol
	adin cVoltagePin, Voltage ; Battery voltage
	Voltage = (Voltage*1955)/1000
	
	IF (NOT SafetyShutDown) THEN
		IF (Voltage < cTurnOffVol) OR (Voltage >= 1999) THEN
			;Turn off
	  		BodyPosX = 0
	  		BodyPosY = 0
	  		BodyPosZ = 0
	  		BodyRotX = 0
	  		BodyRotY = 0
	  		BodyRotZ = 0
	  		TravelLengthX = 0
	  		TravelLengthZ = 0
	  		TravelRotationY = 0
	  		SelectedLeg = 255
		
	  		SafetyShutDown = 1
	  		HexOn = 0
		ENDIF
	ELSE
	  Sound cSpeakerPin,[45\1000]
      pause 2000
	ENDIF
#ENDIF	
return

;--------------------------------------------------------------------
#ifndef cNoSL
;[SINGLE LEG CONTROL]
SingleLegControl

  ;Check if all legs are down
  AllDown = LegPosY(cRF)=cInitPosY(cRF) & LegPosY(cRM)=cInitPosY(cRM) & LegPosY(cRR)=cInitPosY(cRR) & LegPosY(cLR)=cInitPosY(cLR) & LegPosY(cLM)=cInitPosY(cLM) & LegPosY(cLF)=cInitPosY(cLF)

  IF (SelectedLeg>=0 AND SelectedLeg<=5) THEN    
    IF(SelectedLeg<>Prev_SelectedLeg) THEN
    
      IF(AllDown)THEN ;Lift leg a bit when it got selected
        LegPosY(SelectedLeg) = cInitPosY(SelectedLeg)-20  
        
		;Store current status
  		Prev_SelectedLeg = SelectedLeg	         
           
      ELSE ;Return prev leg back to the init position
	    LegPosX(Prev_SelectedLeg) = cInitPosX(Prev_SelectedLeg)
	    LegPosY(Prev_SelectedLeg) = cInitPosY(Prev_SelectedLeg)
	    LegPosZ(Prev_SelectedLeg) = cInitPosZ(Prev_SelectedLeg)
      ENDIF
      
    ELSEIF (NOT SLHold)
      LegPosY(SelectedLeg) = LegPosY(SelectedLeg)+SLLegY
      LegPosX(SelectedLeg) = cInitPosX(SelectedLeg)+SLLegX
      LegPosZ(SelectedLeg) = cInitPosZ(SelectedLeg)+SLLegZ      
    ENDIF

 
  ELSE ;All legs to init position
    IF (NOT AllDown) THEN
      for LegIndex = 0 to 5 
	    LegPosX(LegIndex) = cInitPosX(LegIndex)
	    LegPosY(LegIndex) = cInitPosY(LegIndex)
	    LegPosZ(LegIndex) = cInitPosZ(LegIndex)
      next
    ENDIF
    IF Prev_SelectedLeg<>255 THEN
      Prev_SelectedLeg = 255
    ENDIF
  ENDIF

return
#endif


;--------------------------------------------------------------------
GaitSelect
  ;Configure number of gaits in code
  NrOfGaits = 5

  ;Gait selector  
  Branch GaitType, [Ripple12, Tripod8, Tripod12, Tripod16, Wave24]
  return ;index of GaitType does not exist

  Ripple12: ;Ripple Gait 12 steps
	GaitLegNr(cLR) = 1
	GaitLegNr(cRF) = 3
	GaitLegNr(cLM) = 5
	GaitLegNr(cRR) = 7
	GaitLegNr(cLF) = 9
	GaitLegNr(cRM) = 11

	NrLiftedPos = 3
	HalfLiftHeigth = 3 ; -LegLiftHeight/2 
	TLDivFactor = 8	  
	StepsInGait = 12	
    NomGaitSpeed = 70
  return
  
  Tripod8: ;Tripod 8 steps
	GaitLegNr(cLR) = 5
	GaitLegNr(cRF) = 1
	GaitLegNr(cLM) = 1
	GaitLegNr(cRR) = 1
	GaitLegNr(cLF) = 5
	GaitLegNr(cRM) = 5
	  
	NrLiftedPos = 3
	HalfLiftHeigth = 3; -LegLiftHeight/2 	
	TLDivFactor = 4	  
	StepsInGait = 8	    
    NomGaitSpeed = 70
  return
  
  Tripod12: ;Triple Tripod 12 steps
	GaitLegNr(cRF) = 3
	GaitLegNr(cLM) = 4
	GaitLegNr(cRR) = 5
	GaitLegNr(cLF) = 9
	GaitLegNr(cRM) = 10
	GaitLegNr(cLR) = 11
	  
	NrLiftedPos = 3
	HalfLiftHeigth = 3 	
	TLDivFactor = 8  
	StepsInGait = 12	    
    NomGaitSpeed = 60
  return
  
  Tripod16: ;Triple Tripod 16 steps, use 5 lifted positions!
	GaitLegNr(cRF) = 4
	GaitLegNr(cLM) = 5
	GaitLegNr(cRR) = 6
	GaitLegNr(cLF) = 12
	GaitLegNr(cRM) = 13
	GaitLegNr(cLR) = 14
	  
	NrLiftedPos = 5
	HalfLiftHeigth = 1 ;-LegLiftHeight*(3/4) 	
	TLDivFactor = 10  
	StepsInGait = 16	    
    NomGaitSpeed = 60
  return
  
  Wave24: ;Wave 24 steps
	GaitLegNr(cLR) = 1
	GaitLegNr(cRF) = 21
	GaitLegNr(cLM) = 5

	GaitLegNr(cRR) = 13
	GaitLegNr(cLF) = 9
	GaitLegNr(cRM) = 17
	  
	NrLiftedPos = 3
	HalfLiftHeigth = 3	
	TLDivFactor = 20	  
	StepsInGait = 24	    
    NomGaitSpeed = 70
  return    

return ;should never come here
;--------------------------------------------------------------------
;[GAIT Sequence]
GaitSeq

  ;Check IF the Gait is in motion
  TravelRequest = ((ABS(TravelLengthX)>cTravelDeadZone) | (ABS(TravelLengthZ)>cTravelDeadZone) | (ABS(TravelRotationY)>cTravelDeadZone) )
  IF NrLiftedPos = 5 THEN
  	LiftDivFactor = 4
  ELSE
  	LiftDivFactor = 2
  ENDIF

  ;Calculate Gait sequence
  LastLeg = 0
  for LegIndex = 0 to 5 ; for all legs
  
    if LegIndex = 5 then ; last leg
      LastLeg = 1 
    endif 
    
    GOSUB Gait [LegIndex] 
  next	; next leg
return
;--------------------------------------------------------------------
;[GAIT]
GaitCurrentLegNr var nib
Gait [GaitCurrentLegNr]

  ;Clear values under the cTravelDeadZone
  IF (TravelRequest=0) THEN
    TravelLengthX=0
    TravelLengthZ=0
    TravelRotationY=0
  ENDIF

  ;Leg middle up position
  	 ;Gait in motion														  									Gait NOT in motion, return to home position
  IF (TravelRequest & (NrLiftedPos=1 | NrLiftedPos=3 | NrLiftedPos=5) & GaitStep=GaitLegNr(GaitCurrentLegNr)) | (NOT TravelRequest & GaitStep=GaitLegNr(GaitCurrentLegNr) & ((ABS(GaitPosX(GaitCurrentLegNr))>2) | (ABS(GaitPosZ(GaitCurrentLegNr))>2) | (ABS(GaitRotY(GaitCurrentLegNr))>2))) THEN	;Up
    GaitPosX(GaitCurrentLegNr) = 0
    GaitPosY(GaitCurrentLegNr) = -LegLiftHeight
    GaitPosZ(GaitCurrentLegNr) = 0
    GaitRotY(GaitCurrentLegNr) = 0

  ;Optional Half heigth Rear (2, 3, 5 lifted positions)
  ELSEIF ((NrLiftedPos=2 & GaitStep=GaitLegNr(GaitCurrentLegNr)) | (NrLiftedPos>=3 & (GaitStep=GaitLegNr(GaitCurrentLegNr)-1 | GaitStep=GaitLegNr(GaitCurrentLegNr)+(StepsInGait-1)))) & TravelRequest
	GaitPosX(GaitCurrentLegNr) = -TravelLengthX/LiftDivFactor
    GaitPosY(GaitCurrentLegNr) = -3*LegLiftHeight/(3+HalfLiftHeigth) ; Easier to shift between div factor: /1 (3/3), /2 (3/6) and 3/4
    GaitPosZ(GaitCurrentLegNr) = -TravelLengthZ/LiftDivFactor
    GaitRotY(GaitCurrentLegNr) = -TravelRotationY/LiftDivFactor
  	  
  ;Optional Half heigth front (2, 3, 5 lifted positions)
  ELSEIF (NrLiftedPos>=2) & (GaitStep=GaitLegNr(GaitCurrentLegNr)+1 | GaitStep=GaitLegNr(GaitCurrentLegNr)-(StepsInGait-1)) & TravelRequest
    GaitPosX(GaitCurrentLegNr) = TravelLengthX/LiftDivFactor
    GaitPosY(GaitCurrentLegNr) = -3*LegLiftHeight/(3+HalfLiftHeigth) ; Easier to shift between div factor: /1 (3/3), /2 (3/6) and 3/4
    GaitPosZ(GaitCurrentLegNr) = TravelLengthZ/LiftDivFactor
    GaitRotY(GaitCurrentLegNr) = TravelRotationY/LiftDivFactor

  ;Optional Half heigth Rear 5 LiftedPos (5 lifted positions)
  ELSEIF ((NrLiftedPos=5 & (GaitStep=GaitLegNr(GaitCurrentLegNr)-2 ))) & TravelRequest
	GaitPosX(GaitCurrentLegNr) = -TravelLengthX/2
    GaitPosY(GaitCurrentLegNr) = -LegLiftHeight/2
    GaitPosZ(GaitCurrentLegNr) = -TravelLengthZ/2
    GaitRotY(GaitCurrentLegNr) = -TravelRotationY/2
  	  		
  ;Optional Half heigth Front 5 LiftedPos (5 lifted positions)
  ELSEIF (NrLiftedPos=5) & (GaitStep=GaitLegNr(GaitCurrentLegNr)+2 | GaitStep=GaitLegNr(GaitCurrentLegNr)-(StepsInGait-2)) & TravelRequest
    GaitPosX(GaitCurrentLegNr) = TravelLengthX/2
    GaitPosY(GaitCurrentLegNr) = -LegLiftHeight/2
    GaitPosZ(GaitCurrentLegNr) = TravelLengthZ/2
    GaitRotY(GaitCurrentLegNr) = TravelRotationY/2

  ;Leg front down position
  ELSEIF (GaitStep=GaitLegNr(GaitCurrentLegNr)+NrLiftedPos | GaitStep=GaitLegNr(GaitCurrentLegNr)-(StepsInGait-NrLiftedPos)) & GaitPosY(GaitCurrentLegNr)<0
    GaitPosX(GaitCurrentLegNr) = TravelLengthX/2
    GaitPosZ(GaitCurrentLegNr) = TravelLengthZ/2
    GaitRotY(GaitCurrentLegNr) = TravelRotationY/2      	
    GaitPosY(GaitCurrentLegNr) = 0	;Only move leg down at once if terrain adaption is turned off

  ;Move body forward      
  ELSE
    GaitPosX(GaitCurrentLegNr) = GaitPosX(GaitCurrentLegNr) - (TravelLengthX/TLDivFactor)     
    GaitPosY(GaitCurrentLegNr) = 0  
    GaitPosZ(GaitCurrentLegNr) = GaitPosZ(GaitCurrentLegNr) - (TravelLengthZ/TLDivFactor)
    GaitRotY(GaitCurrentLegNr) = GaitRotY(GaitCurrentLegNr) - (TravelRotationY/TLDivFactor)
  ENDIF
   
  ;Advance to the next step
  IF LastLeg THEN	;The last leg in this step
    GaitStep = GaitStep+1
    IF GaitStep>StepsInGait THEN
      GaitStep = 1
    ENDIF
  ENDIF
  
return
;--------------------------------------------------------------------
;[BalCalcOneLeg]
BalLegNr var nib
BalCalcOneLeg [PosX, PosZ, PosY, BalLegNr]
  ;Calculating centerpoint (of rotation) of the body to the feet
  CPR_Z = cOffsetZ(BalLegNr)+PosZ
  CPR_X = cOffsetX(BalLegNr)+PosX
  CPR_Y = 150 + PosY' using the value 150 to lower the centerpoint of rotation 'BodyPosY +
  TotalTransY = TotalTransY + PosY
  TotalTransZ = TotalTransZ + CPR_Z
  TotalTransX = TotalTransX + CPR_X
  
  gosub GetATan2 [CPR_X, CPR_Z]
  TotalYbal1 =  TotalYbal1 + (ATan4*1800) / 31415

    
  gosub GetATan2 [CPR_X, CPR_Y]
  TotalZbal1 = TotalZbal1 + ((ATan4*1800) / 31415) -900 'Rotate balance circle 90 deg
  
  gosub GetATan2 [CPR_Z, CPR_Y]
  TotalXbal1 = TotalXbal1 + ((ATan4*1800) / 31415) - 900 'Rotate balance circle 90 deg
  
return
;--------------------------------------------------------------------
;[BalanceBody]
BalanceBody:
	TotalTransZ = TotalTransZ/6 
	TotalTransX = TotalTransX/6
	TotalTransY = TotalTransY/6

	if TotalYbal1 > 0 then		'Rotate balance circle by +/- 180 deg
		TotalYbal1 = TotalYbal1 - 1800
	else
		TotalYbal1 = TotalYbal1 + 1800
	endif
	if TotalZbal1 < -1800 then	'Compensate for extreme balance positions that causes owerflow
		TotalZbal1 = TotalZbal1 + 3600
	endif
	
	if TotalXbal1 < -1800 then	'Compensate for extreme balance positions that causes owerflow
		TotalXbal1 = TotalXbal1 + 3600
	endif
	
	;Balance rotation
	TotalYBal1 = -TotalYbal1/6
	TotalXBal1 = -TotalXbal1/6
	TotalZBal1 = TotalZbal1/6

return
;--------------------------------------------------------------------
;[GETSINCOS] Get the sinus and cosinus from the angle +/- multiple circles
;AngleDeg1 	- Input Angle in degrees
;Sin4    	- Output Sinus of AngleDeg
;Cos4  		- Output Cosinus of AngleDeg
GetSinCos[AngleDeg1]
	;Get the absolute value of AngleDeg
	IF AngleDeg1 < 0 THEN
	  ABSAngleDeg1 = AngleDeg1 *-1
	ELSE
	  ABSAngleDeg1 = AngleDeg1
	ENDIF
	
	;Shift rotation to a full circle of 360 deg -> AngleDeg // 360
	IF AngleDeg1 < 0 THEN	;Negative values
		AngleDeg1 = 3600-(ABSAngleDeg1-(3600*(ABSAngleDeg1/3600)))
	ELSE				;Positive values
		AngleDeg1 = ABSAngleDeg1-(3600*(ABSAngleDeg1/3600))
	ENDIF	
	
	IF (AngleDeg1>=0 AND AngleDeg1<=900) THEN	; 0 to 90 deg
		Sin4 = GetSin(AngleDeg1/5) 			; 5 is the presision (0.5) of the table
		Cos4 = GetSin((900-(AngleDeg1))/5) 	
		
	ELSEIF (AngleDeg1>900 AND AngleDeg1<=1800) 	; 90 to 180 deg
		Sin4 = GetSin((900-(AngleDeg1-900))/5) ; 5 is the presision (0.5) of the table	
		Cos4 = -GetSin((AngleDeg1-900)/5)			
		
	ELSEIF (AngleDeg1>1800 AND AngleDeg1<=2700) ; 180 to 270 deg
		Sin4 = -GetSin((AngleDeg1-1800)/5) 	; 5 is the presision (0.5) of the table
		Cos4 = -GetSin((2700-AngleDeg1)/5)
		
	ELSEIF (AngleDeg1>2700 AND AngleDeg1<=3600) ; 270 to 360 deg
		Sin4 = -GetSin((3600-AngleDeg1)/5) ; 5 is the presision (0.5) of the table	
		Cos4 = GetSin((AngleDeg1-2700)/5)			
	ENDIF
	
return
;--------------------------------------------------------------------
;[GETARCCOS] Get the sinus and cosinus from the angle +/- multiple circles
;Cos4    	- Input Cosinus
;AngleRad4 	- Output Angle in AngleRad4
GetArcCos[Cos4]
  ;Check for negative value
  IF (Cos4<0) THEN
    Cos4 = -Cos4
    NegativeValue = 1
  ELSE
    NegativeValue = 0
  ENDIF

  ;Limit Cos4 to his maximal value
  Cos4 = (Cos4 max c4DEC)
  
  IF (Cos4>=0 AND Cos4<9000) THEN
    AngleRad4 = GetACos(Cos4/79) ;79=table resolution (1/127)
    AngleRad4 = AngleRad4*616/c1DEC ;616=acos resolution (pi/2/255) 
    
  ELSEIF (Cos4>=9000 AND Cos4<9900)
    AngleRad4 = GetACos((Cos4-9000)/8+114) ;8=table resolution (0.1/127), 114 start address 2nd bytetable range 
    AngleRad4 = AngleRad4*616/c1DEC ;616=acos resolution (pi/2/255) 
    
  ELSEIF (Cos4>=9900 AND Cos4<=10000)
    AngleRad4 = GetACos((Cos4-9900)/2+227) ;2=table resolution (0.01/64), 227 start address 3rd bytetable range 
    AngleRad4 = AngleRad4*616/c1DEC ;616=acos resolution (pi/2/255) 
  ENDIF  
       
  ;Add negative sign
  IF NegativeValue THEN
    AngleRad4 = 31416 - AngleRad4
  ENDIF

return AngleRad4
;--------------------------------------------------------------------
;[GETATAN2] Simplyfied ArcTan2 function based on fixed point ArcCos
;ArcTanX 		- Input X
;ArcTanY 		- Input Y
;ArcTan4  		- Output ARCTAN2(X/Y)
;XYhyp2			- Output presenting Hypotenuse of X and Y
GetAtan2 [AtanX, AtanY]
  XYhyp2 = SQR ((AtanX*AtanX*c4DEC) + (AtanY*AtanY*c4DEC))
  GOSUB GetArcCos [AtanX*c6DEC / XYHyp2]
 
  Atan4 = AngleRad4 * (AtanY/ABS(AtanY)) ;Add sign 
return Atan4
;--------------------------------------------------------------------
;[BODY INVERSE KINEMATICS] 
;BodyRotX         - Global Input pitch of the body 
;BodyRotY         - Global Input rotation of the body 
;BodyRotZ         - Global Input roll of the body 
;RotationY         - Input Rotation for the gait 
;PosX            - Input position of the feet X 
;PosZ            - Input position of the feet Z 
;SinB          		- Sin buffer for BodyRotX
;CosB           	- Cos buffer for BodyRotX
;SinG          		- Sin buffer for BodyRotZ
;CosG           	- Cos buffer for BodyRotZ
;BodyFKPosX         - Output Position X of feet with Rotation 
;BodyFKPosY         - Output Position Y of feet with Rotation 
;BodyFKPosZ         - Output Position Z of feet with Rotation
BodyFKLeg var nib
BodyFK [PosX, PosZ, PosY, RotationY, BodyFKLeg] 

  ;Calculating totals from center of the body to the feet 
  CPR_X = cOffsetX(BodyFKLeg)+PosX + BodyRotOffsetX
  CPR_Y = PosY + BodyRotOffsetY ; Define centerpoint for rotation along the Y-axis
  CPR_Z = cOffsetZ(BodyFKLeg) + PosZ + BodyRotOffsetZ
  
  ;Successive global rotation matrix: 
  ;Math shorts for rotation: Alfa (A) = Xrotate, Beta (B) = Zrotate, Gamma (G) = Yrotate 
  ;Sinus Alfa = sinA, cosinus Alfa = cosA. and so on... 
  
  ;First calculate sinus and cosinus for each rotation: 
  GOSUB GetSinCos [BodyRotX1+TotalXBal1] 
  SinG4 = Sin4
  CosG4 = Cos4
  
  GOSUB GetSinCos [BodyRotZ1+TotalZBal1] 
  SinB4 = Sin4
  CosB4 = Cos4
  
  GOSUB GetSinCos [BodyRotY1+(RotationY*c1DEC)+TotalYBal1] 
  SinA4 = Sin4
  CosA4 = Cos4

  ;Calcualtion of rotation matrix: 
  BodyFKPosX = (CPR_X*c2DEC - ( CPR_X*c2DEC*CosA4/c4DEC*CosB4/c4DEC - CPR_Z*c2DEC*CosB4/c4DEC*SinA4/c4DEC + CPR_Y*c2DEC*SinB4/c4DEC ))/c2DEC
  BodyFKPosZ = (CPR_Z*c2DEC - ( CPR_X*c2DEC*CosG4/c4DEC*SinA4/c4DEC + CPR_X*c2DEC*CosA4/c4DEC*SinB4/c4DEC*SinG4/c4DEC + CPR_Z*c2DEC*CosA4/c4DEC*CosG4/c4DEC - CPR_Z*c2DEC*SinA4/c4DEC*SinB4/c4DEC*SinG4/c4DEC - CPR_Y*c2DEC*CosB4/c4DEC*SinG4/c4DEC ))/c2DEC
  BodyFKPosY = (CPR_Y  *c2DEC - ( CPR_X*c2DEC*SinA4/c4DEC*SinG4/c4DEC - CPR_X*c2DEC*CosA4/c4DEC*CosG4/c4DEC*SinB4/c4DEC + CPR_Z*c2DEC*CosA4/c4DEC*SinG4/c4DEC + CPR_Z*c2DEC*CosG4/c4DEC*SinA4/c4DEC*SinB4/c4DEC + CPR_Y*c2DEC*CosB4/c4DEC*CosG4/c4DEC ))/c2DEC
return 
;--------------------------------------------------------------------
;[LEG INVERSE KINEMATICS] Calculates the angles of the coxa, femur and tibia for the given position of the feet
;IKFeetPosX			- Input position of the Feet X
;IKFeetPosY			- Input position of the Feet Y
;IKFeetPosZ			- Input Position of the Feet Z
;IKSolution			- Output true IF the solution is possible
;IKSolutionWarning 	- Output true IF the solution is NEARLY possible
;IKSolutionError	- Output true IF the solution is NOT possible
;FemurAngle1	   	- Output Angle of Femur in degrees
;TibiaAngle1  	 	- Output Angle of Tibia in degrees
;CoxaAngle1			- Output Angle of Coxa in degrees
LegIKLegNr var nib
LegIK [IKFeetPosX, IKFeetPosY, IKFeetPosZ, LegIKLegNr]

	;Calculate IKCoxaAngle and IKFeetPosXZ
	GOSUB GetATan2 [IKFeetPosX, IKFeetPosZ]
	CoxaAngle1(LegIKLegNr) = ((ATan4*180) / 3141) + cCoxaAngle1(LegIKLegNr)
	
	;Length between the Coxa and tars (foot)
	IKFeetPosXZ = XYhyp2/c2DEC
	
	; Some legs may have the 4th DOF and some may not, so handle this here...
#ifdef c4DOF
	IF cTarsLength(LegIKLegNr) THEN		; This leg has the 4th degree?
	  ;Calc the TarsToGroundAngle1:
	  TarsToGroundAngle1 = -cTarsConst + cTarsMulti*IKFeetPosY + (IKFeetPosXZ*cTarsFactorA)/c1DEC - ((IKFeetPosXZ*IKFeetPosY)/(cTarsFactorB))
	  IF IKFeetPosY < 0 THEN ;Always compensate TarsToGroundAngle1 when IKFeetPosY it goes below zero
	    TarsToGroundAngle1 = TarsToGroundAngle1 - ((IKFeetPosY*cTarsFactorC)/c1DEC); TGA base, overall rule
	  ENDIF
	  IF TarsToGroundAngle1 > 400 THEN ;
	    TGA_B_H3 = 200 + (TarsToGroundAngle1/2)
	  ELSE
	    TGA_B_H3 = TarsToGroundAngle1
	  ENDIF
	  IF TarsToGroundAngle1 > 300 THEN ;
	    TGA_A_H4 = 240 + (TarsToGroundAngle1/5)
	  ELSE
	    TGA_A_H4 = TarsToGroundAngle1
	  ENDIF
	  IF IKFeetPosY > 0 THEN ;Only compensate the TarsToGroundAngle1 when it exceed 30 deg (A, H4 PEP note)
	    TarsToGroundAngle1 = TGA_A_H4
	  ELSEIF ((IKFeetPosY <= 0) & (IKFeetPosY > -10)); linear transition between case H3 and H4 (from PEP: H4-K5*(H3-H4))
	    TarsToGroundAngle1 = (TGA_A_H4 -((IKFeetPosY*(TGA_B_H3-TGA_A_H4))/c1DEC))
	  ELSE ;IKFeetPosY <= -10, Only compensate TGA1 when it exceed 40 deg
	    TarsToGroundAngle1 = TGA_B_H3
	  ENDIF
	  ;Calc Tars Offsets:
	  GOSUB GetSinCos [TarsToGroundAngle1] 
	  TarsOffsetXZ = (Sin4*cTarsLength(LegIKLegNr))/c4DEC
	  TarsOffsetY = (Cos4*cTarsLength(LegIKLegNr))/c4DEC	
	ELSE
	  TarsOffsetXZ = 0		; If the leg has no tar zero this off
	  TarsOffsetY = 0		;Vector value / The 2 DOF IK calcs (femur and tibia) are based upon these vectors
    ENDIF		
#endif
	
	;Using GetAtan2 for solving IKA1 and IKSW
	;IKA14 - Angle between SW line and the ground in radians
	GOSUB GetATan2 [IKFeetPosY-TarsOffsetY, IKFeetPosXZ-cCoxaLength(LegIKLegNr)-TarsOffsetXZ], IKA14

	;IKSW2 - Length between femur axis and tars
	IKSW2 = XYhyp2
	
	;IKA2 - Angle of the line S>W with respect to the femur in radians
	Temp1 = (((cFemurLength(LegIKLegNr)*cFemurLength(LegIKLegNr)) - (cTibiaLength(LegIKLegNr)*cTibiaLength(LegIKLegNr)))*c4DEC + (IKSW2*IKSW2))
	Temp2 = ((2*cFemurLength(LegIKLegNr))*c2DEC * IKSW2)
	GOSUB GetArcCos [Temp1 / (Temp2/c4DEC) ], IKA24	
	
	;IKFemurAngle
	FemurAngle1(LegIKLegNr) = -(IKA14 + IKA24) * 180 / 3141 + 900 + cFemurHornOffset1(LegIKLegNr)

	;IKTibiaAngle
	Temp1 = (((cFemurLength(LegIKLegNr)*cFemurLength(LegIKLegNr)) + (cTibiaLength(LegIKLegNr)*cTibiaLength(LegIKLegNr)))*c4DEC - (IKSW2*IKSW2))
	Temp2 = (2*cFemurLength(LegIKLegNr)*cTibiaLength(LegIKLegNr))
	GOSUB GetArcCos [Temp1 / Temp2]
	TibiaAngle1(LegIKLegNr) = -(900-AngleRad4*180/3141)

#ifdef c4DOF
	IF cTarsLength(LegIKLegNr) THEN		; This leg has the 4th degree?
  	  ;Tars angle
	  TarsAngle1(LegIKLegNr) = (TarsToGroundAngle1 + FemurAngle1(LegIKLegNr) - TibiaAngle1(LegIKLegNr)) + cTarsHornOffset1(LegIKLegNr)
	ENDIF
#endif

	;Set the Solution quality	
	IF(IKSW2 < (cFemurLength(LegIKLegNr)+cTibiaLength(LegIKLegNr)-30)*c2DEC) THEN
		IKSolution = 1
	ELSE
		IF(IKSW2 < (cFemurLength(LegIKLegNr)+cTibiaLength(LegIKLegNr))*c2DEC) THEN
			IKSolutionWarning = 1
		ELSE
			IKSolutionError = 1	
		ENDIF
	ENDIF	
return
;--------------------------------------------------------------------
;[CHECK ANGLES] Checks the mechanical limits of the servos
CheckAngles:

  for LegIndex = 0 to 5
    CoxaAngle1(LegIndex)  = (CoxaAngle1(LegIndex)  min cCoxaMin1(LegIndex))  max cCoxaMax1(LegIndex)
    FemurAngle1(LegIndex) = (FemurAngle1(LegIndex) min cFemurMin1(LegIndex)) max cFemurMax1(LegIndex)
    TibiaAngle1(LegIndex) = (TibiaAngle1(LegIndex) min cTibiaMin1(LegIndex)) max cTibiaMax1(LegIndex)
#ifdef c4DOF
	IF cTarsLength(LegIndex) THEN		; This leg has the 4th degree?
	  TarsAngle1(LegIndex) =  (TarsAngle1(LegIndex)  min cTarsMin1(LegIndex))  max cTarsMax1(LegIndex)
	ENDIF
#endif
  next

return
;--------------------------------------------------------------------
;[GET PWM VALUES]
; Calculates the PWM values for the given Leg
cPwmDiv      con 991 ;old 1059;
cPFConst     con 592 ;old 650 ; 900*(1000/cPwmDiv)+cPFConst must always be 1500
               ;A PWM/deg factor of 10,09 give cPwmDiv = 991 and cPFConst = 592
               ;For a modified 5645 (to 180 deg travel): cPwmDiv = 1500 and cPFConst = 900.
CoxaPWM var word
FemurPWM var word
TibiaPWM var word
#ifdef c4DOF
TarsPWM var word
#endif

GetPWMValues [LegIndex]

   ;Update Right Legs
    if LegIndex <= 2 then
      CoxaPWM =  (-CoxaAngle1(LegIndex) +900)*1000/cPwmDiv+cPFConst
      FemurPWM = (-FemurAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
      TibiaPWM = (-TibiaAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
#ifdef c4DOF
	IF cTarsLength(LegIndex) THEN		; This leg has the 4th degree?
      TarsPWM = (-TarsAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
    ENDIF
#endif
    else
      ;Update Left Legs
      CoxaPWM =  (CoxaAngle1(LegIndex) +900)*1000/cPwmDiv+cPFConst
      FemurPWM = (FemurAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
      TibiaPWM = (TibiaAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
#ifdef c4DOF
	IF cTarsLength(LegIndex) THEN		; This leg has the 4th degree?
      TarsPWM = (TarsAngle1(LegIndex)+900)*1000/cPwmDiv+cPFConst
	ENDIF
#endif
    endif
return
;--------------------------------------------------------------------
