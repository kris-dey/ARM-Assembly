	AREA	DisplayResult, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start
										;//Initialising the variables(i.e. the registors)
	LDR R7, =0 							; placeValue = 0		//Place value
	LDR R4, =0 							; numberInput = 0
	LDR R9, =10 						; multiple = 10
	LDR R11, =0x254						; previousReult= dummy value
	LDR R5, =0							; result=0
	LDR R12, =0							; negative= 'false'		//initialising the boolean
	LDR R8, =0							; previousinput=0

read

	MOV R8, R0							; temp=previousinput
	
	BL getkey 							; read key from console
	CMP R0, #0x0D  						; while (key != CR)
	BEQ endRead 						; {
	BL sendchar 						; echo key back to console

	CMP R0, #0x2B						; if(key='+')
	BEQ sign							; 	sign()	

	CMP R0, #0x2D						; if(key='-')
	BEQ sign							;	sign()

	CMP R0, #0x2A						; if(key='*')
	BEQ sign 							; 	sign()

	CMP R0, #0x2F						; if(key='/')
	BEQ sign 							; 	sign()

	CMP R0, #0x30						; //Checking if it is a number
	BLO stop							; //program stops if user inputs anything else other than numbers or signs
	CMP R0, #0x39
	BHI stop

	LDR R6, =48							; tmp1 = 0x30
	SUB R0, R0, R6 						; input = input - tmp1   		//converting asci to int equivalent
	
	ADD R7, R7, #1						; placeValue++
	CMP R7, #1 							; if(placeValue>1)				//putting numbers in their appropriate positions
	BEQ ifend							; {
	MUL R4, R9, R4 						;	numberInput = numberInput * 10
ifend 									; }
	ADD R4, R0, R4 						; numberInput = numberInput + input

	B read

sign

	CMP R8, #0x2B						; if(previousInput!='+')
	BEQ secondSign						; 	notNegative	

	CMP R8, #0x2D						; if(previousInput!='-')
	BEQ secondSign						;	notNegative	

	CMP R8, #0x2A						; if(previousInput!='*')
	BEQ secondSign						; 	notNegative	

	CMP R8, #0x2F						; if(previousInput!='/')
	BEQ secondSign						; 	notNegative	
	B notSign
	
secondSign
	CMP R0, #0x2D						; if(newInput!='-')
	BNE stop							;	stop()	
	LDR R12, =1							;				//if R12 is 1, that means the next number is going to be negative
	B read
	
notSign

	CMP R11, #0x254						;				//checking if R11 stores any previous value or not
	BNE eval							;				

evalBack

	CMP R0, #0x2B						; if(key='+')
	BEQ plus							; 	plus()	

	CMP R0, #0x2D						; if(key='-')
	BEQ minus							;	minus()

	CMP R0, #0x2A						; if(key='*')
	BEQ star 							; 	star()

	CMP R0, #0x2F						; if(key='/')
	BEQ divide 							; 	divide()
	
	CMP R0, #0x0D 						; if(key= 'CR')
	BEQ Stage3 							; 	Stage3()

plus									; plus(){
	LDR R10, =0x2B						; 	int sign='+'
	MOV R11, R4							; 	previousNumber=result 
	LDR R4, =0							;	result=0					//resetting initial values
	LDR R7 , =0							; 	i=0
	B read                              ; }

minus									; minus(){
	LDR R10, =0x2D						; 	int sign='-'
	MOV R11, R4							; 	previousNumber=result 
	LDR R4, =0							;	result=0					//resetting initial values
	LDR R7 , =0							; 	i=0
	B read                              ; }

star 									; star(){
	LDR R10, =0x2A						; 	int sign='*'
	MOV R11, R4							; 	previousNumber=result 	
	LDR R4, =0                          ;	result=0					//resetting initial values
	LDR R7 , =0                         ;	i=0
	B read                              ; }

divide									; divide(){
	LDR R10, =0x2F						; 	int sign='/'
	MOV R11, R4							; 	previousNumber=result 	
	LDR R4, =0                          ;	result=0					//resetting initial values
	LDR R7 , =0                         ;	i=0
	B read                              ; }

endRead

eval

	CMP R12, #1
	BNE noNegate
	MVN R4, R4
	ADD R4, R4, #1
	LDR R12, =0
noNegate

	CMP R10, #0x2B						;if(sign=='+')
	BNE elseif1							;{
	ADDS R5, R4, R11					;result = newNumber + previousNumber
	MOV R4, R5
	B evalBack							;}

elseif1									
	CMP R10, #0x2D						;else if(sign=='-')
	BNE elseif2 						;{
	SUBS R5, R11, R4						;result = previousNumber - newNumber
	MOV R4, R5
	B evalBack							;}

elseif2
	CMP R10, #0x2A						;else if(sign=='*')
	BNE elseif3
	MULS R5, R11, R4 					;result = newNumber * previousNumber
	MOV R4, R5
	B evalBack

elseif3
	LDR R5, =0			;quotient=0
	MOV R13, R11			;remainder = a
	CMP R4, #0			;if b=0 the program would be in an infinite loop
	BEQ stop			;so stoping the program whenever b=0
whilediv
	CMP R13, R4			;while(remainder >= b)
	BLO evalBack			;{
	ADDS R5,R5,#1		;quotient= quotient+1
	SUB R13, R13, R4		;remainder= remainder-b
	B whilediv 				;}


Stage3

;//From here, only R5(which has the evaluated value) is needed

;STAGE 3 - Displaying the result present in R5(Registor 5)

	LDR R0, =0x3D						;//to print '='
	BL sendchar

	CMP R5, #0
	BGE positive
	LDR R0, =0x2D						;//to print '-'
	BL sendchar
	MVN R5, R5
	ADD R5, R5, #1

positive

;//With the code below, we get the appropriate power of 10 to start with. The required value is stored in R8
	LDR R12, =1							;int tmp=1
	LDR R8, =1							;int multiple10=1
	LDR R6, =10							;int mult10=10
while 									;							//from this I would get the starting multiple of 10 in R8
	MUL R12, R6, R12 					;{	tmp = tmp * 10 
	CMP R5, R12							;	if(result<tmp)
	BLO number							;	{
	MUL R8, R6, R8						;		multiple10 = multiple10 * 10
	B while 							; 	}

;From here I only need R5(evaluated value) and R8(appropriate power of 10 to start with)

;//to get the MSD in R0 and Remainder in R6

number
	LDR R0, =0							;quotient=0
	MOV R6, R5 							;remainder = a
while2 									
	CMP R6, R8 							;while(remainder >= b)
	BLO display 						;{
	ADD R0,R0,#1 						;	quotient= quotient+1
	SUB R6, R6, R8 						;	remainder= remainder-b
	B while2 							;}

display
	LDR R4, =48							; tmp1 = 0x30
	ADD R0, R0, R4 						; input = input + tmp1   	//converting int to ASCII equivalent
	BL sendchar 						;							//display the MSD
	MOV R5, R6 							;							//making the remainder as quotient to remove the MSD

;//Reducing R8 by a multiple of 10
	CMP R8, #1
	BEQ stop1

	LDR R9, =10							;int b  = 10
	LDR R10, =0 						;quotient = 0
	MOV R11, R8 						;remainder = a
while3
	CMP R11, R9 						;while(remainder >= b)
	BLO enddiv 							;{
	ADD R10, R10, #1					;	quotient = quotient+1
	SUB R11, R11, R9 					;	remainder = remainder-b
	B while3 							;}

enddiv
	MOV R8, R10

	B number
	
stop1

	LDR R0, =0x10						;//Printing tab space before the program restarts. 
	BL sendchar
	B start								;//Program is restarted

stop B stop

	END
