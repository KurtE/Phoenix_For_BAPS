; Added new file to allow build both ways...
; Currently testing with Arc32 connected to SSC-32.  Comment out if you wish for the SSC-32 to directly control the servos
USE_SSC32		 con 1
BACKGROUND_CHECK_INPUT con 10	; if we wait for more than 10ms than call our input in the background