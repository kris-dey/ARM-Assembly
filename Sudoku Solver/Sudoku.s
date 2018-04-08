	AREA	Sudoku, CODE, READONLY
	IMPORT	main
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start
	LDR	R0, =testGridOne
	LDR	R1, =1
 	LDR	R2, =1
 	LDR	R6, =1

testStageOne
 	CMP	R6, #9
	LDR	R1, =1
 	LDR	R2, =1
	LDR R3, =0
 	BGT	testStageTwo
	STRB	R6, [R0]
	BL	isValid
	ADD	R6, R6, #1	; put a break point here - only 1 should be valid
	B	testStageOne

testStageTwo
	
	LDR R1, =Sudoku1String
	BL printString

	LDR	R0, =testGridTwo
	LDR	R1, =1
	LDR	R2, =1
	BL	sudoku
	BL printSudoku
	LDR	R0, =testGridTwo
	LDR	R1, =testSolutionTwo
	BL	compareGrids

	MOV R0, #10
	BL sendchar
	
testStageThree
	
	LDR R1, =Sudoku2String
	BL printString
	
	LDR	R0, =testGridThree
	LDR	R1, =1
	LDR	R2, =1
	BL	sudoku
	BL printSudoku
	LDR	R0, =testGridThree
	LDR	R1, =testSolutionThree
	BL	compareGrids

stop	B	stop

compareGrids
	STMFD	sp!, {R4-R6, LR}
	LDR	R4, =0
forCompareGrids
	CMP	R4, #(9*9)
	BGE	endForCompareGrids
	LDRB	R5, [R0, R4]
	LDRB	R6, [R1, R4]
	CMP	R5, R6
	BNE	endForCompareGrids
	ADD	R4, R4, #1
	B	forCompareGrids
endForCompareGrids

	CMP	R4,#(9*9)
	BNE	elseCompareGridsFalse
	MOV	R0, #1
	B	endIfCompareGridsTrue
elseCompareGridsFalse
	MOV	R0, #0
endIfCompareGridsTrue
	LDMFD	sp!, {R4-R6, PC}

; getSquare subroutine
; Gets the number stored in the specific box
; Parameters
;	r0: addressGrid - address of the grid
;	r1: row - row number
;	r2: column - column number
; Returns
;	r3: number - the number in the particular spot
getSquare
	STMFD sp!, {R4, R5, lr}
	SUB R1, R1, #1
	SUB R2, R2, #1
	LDR R5, =9
	MUL R4, R1, R5
	ADD R4, R4, R2
	LDRB R3, [R0, R4]
	LDMFD sp!, {R4, R5, pc}

; setSquare subroutine
; Sets the number in the specific box
; Parameters
;	r0: addressGrid - address of the grid
;	r1: row - row number
;	r2: column - column number
;	r3: number - Number to be stored
setSquare
	STMFD sp!, {R4, R5, lr}
	SUB R1, R1, #1
	SUB R2, R2, #1
 	LDR R5, =9
	MUL R4, R1, R5
	ADD R4, R4, R2
	STRB R3, [R0, R4]
	LDMFD sp!, {R4, R5, pc}

; isValid subroutine
; Checks if the value is valid or not
; Parameters
;	R0: addressGrid - address of the grid
;   R1: row - row number
;   R2: column - column number
; Returns
;   R3: valid - boolean which checks if it is valid or not
isValid
	STMFD sp!, {R4-R12, lr}
	MOV R6, R0
	MOV R9, R1									;Backing up rows and column in R9 & R10 resp.
	MOV R10, R2
	BL getSquare
	MOV R12, R3

; Is it already used in row.
	LDR R4, =1;         						;int jj=1
for                   							;for (; jj <= 9; ) {
	CMP R4, #9
	BHI endFor
	CMP R4, R10          						;   if(jj == Column)
	BNE noIf1           						;   {
	ADD R4, R4, #1      						;       jj++
	CMP R4, #9
	BHI endFor2
noIf1                 							;   }
	MOV R0, R6									;	number = getSquare(i, jj)
	MOV R1, R9								
	MOV R2, R4
	BL getSquare						
	CMP R3, R12         						;   if (sudoku[i][jj] == x)
	BNE noIf2           						;   {
	LDR R0, =0          						;       valid = false;
	B endIsValid								;		return valid
noIf2                 							;   }
	ADD R4, R4, #1      						;   jj++
	B for               						;}
endFor
    ;// Is 'x' used in column
	MOV R2, R10
	LDR R4, = 1;         						;int ii = 1
for2                     						;for (; ii <= 9; ) {
	CMP R4, #9
	BHI endFor2
	CMP R4, R9          						;   if(ii == Row)
	BNE noIf3          							;   {
	ADD R4, R4, #1      						;       ii++
	CMP R4, #9
	BHI endFor2
noIf3                 							;   }
	MOV R0, R6									;	number = getSquare(i, jj)
	MOV R1, R4
	MOV R2, R10
	BL getSquare
	CMP R3, R12         						;   if (sudoku[ii][j] == x)
	BNE noIf4        							;   {
	LDR R0, =0       							;       return false
	B endIsValid
noIf4                   						;   }
	ADD R4, R4, #1      						;   ii++
	B for2              						;}
endFor2
    ;// Is 'x' used in sudoku 3x3 box.
    ;int boxRow = i - i % 3;
	MOV R4, R9        							;tmp = i
	SUB R4, R4, #1
for4                  							;for(;tmp>=3;)
	CMP R4, #3         							;{
	BLT endFor4
	SUB R4, R4, #3     							;   tmp = tmp - 3
	B for4
endFor4                 						;}
	SUB R4, R9, R4    							;boxRow = i - i % 3
      ;int boxColumn = j - j % 3;
	MOV R5, R10          						;tmp = j
	SUB R5, R5, #1
for5                  							;for(;tmp>=3;)
	CMP R5, #3         							;{
	BLT endFor5
	SUB R5, R5, #3      						;   tmp = tmp - 3
	B for5
endFor5               							;}
	SUB R5, R10, R5      						;boxColumn = j - j % 3
	LDR R7, =0         							;ii=0
for6                  							;for (; ii < 3; )
	CMP R7, #3         							;{
	BEQ endFor6
	LDR R8, =0          						;   jj=0
for7                  							;   for (; jj < 3;)
	CMP R8, #3          						;     {
	BEQ endFor7
	ADD R1, R4, R7     							;       tmp1 = boxRow + ii
	ADD R2, R5, R8     							;       tmp2 = boxColumn + jj
	CMP R1, R9									;		if(tmp1 == row && tmp2 == column)
	BNE notTheSameBox
	CMP R2, R10
	BNE notTheSameBox
	ADD R2, R2, #1								;			column++
	ADD R8, R8, #1
	CMP R8, #3          						;     
	BEQ endFor7	
notTheSameBox	
	MOV R0, R6
	BL getSquare								;       number = sudoku[boxRow + ii][boxColumn + jj]	//;  load the number 
	CMP R3, R12     							;       if (number == x)
	BNE noIf5         							;       {
	LDR R0, =0	        						;                 valid = false
	B endIsValid
noIf5                 							;       }
	ADD R8, R8, #1     							;       jj++
	B for7
endFor7                 						;   }
	ADD R7, R7, #1      						;   ii++
	B for6
endFor6                 						;}
	LDR R0, =1   								;valid = true;
endIsValid
	MOV R3, R0
	MOV R0, R6
	LDMFD sp!, {R4-R12, pc}
  
; sudoku subroutine
;  solves the sudoku
; Parameters
;   R0: Address of the Grid
;   R1: Starting Row Index
;   R2: Starting Column Index
; Returns
;   R3: Result
sudoku                   						;bool sudoku(addressgrid, wordrow,wordcol){
	STMFD sp!, {R4-R12, lr}
	LDR R11, =0              					;bool result = false;
  ;Backing up Row and Column
	MOV R9, R1
	MOV R10, R2
  ;//Precompute next row and col
	MOV R4, R2              					;word nxtcol = col + 1;
	ADD R4, R4, #1
	MOV R5, R1   					           	;word nxtrow = row;
	
	CMP R4, #9             						;if(nxtcol>9)
	BLS noIf6             						;{
	LDR R4, = 1              					;  nxtcol = 1
	ADD R5, R5, #1         						;  nxtrow++;
noIf6	                    					;}

	BL getSquare
	CMP R3, #0              					;if (getSquare(grid,row,col)!=0)
	BEQ noIf8               					;{
	CMP R9, #9              					;	if( row==9 && col==9 ){
	BNE noIf7
	CMP R10, #9
	BNE noIf7
	LDR R11, =1              					;		result = true ; return true
	B endSudoku
noIf7                     						;	}else{        ;//nothing to do here - just move on to the next square
	MOV R2, R4
	MOV R1, R5
	BL sudoku               					;		result = sudoku(grid,nxtrow,nxtcol);
	MOV R11, R3
												;	}
else2
	B noElse
noIf8											;} else{													
  ;//a blank square - try filling it with 1...9
	LDR R6, =1
for10
	CMP R6, #9              					;	for(byte try = 1;try <= 9 && !result ; try++){
	BHI noFor10
	CMP R11, #0
	BNE noFor10
	
	MOV R1, R9
	MOV R2, R10
	MOV R3, R6
	BL setSquare           						;   	setSquare(grid,row,col,try);
	
	MOV R1, R9
	MOV R2, R10
	BL isValid              					;		if(isValid(grid,row,col)){
	CMP R3, #1             						;     							//putting the value here works so far...
	BNE noIf9
	CMP R9, #9              					;			if(row==9&&col==9){
	BNE noIf10
	CMP R10, #9
	BNE noIf10
	LDR R11, =1 							;     			result = true				//...last square--success!!
	B endSudoku            						;       		return result
	
noIf10                     						;			}else{
												;     							//...move on to the next square
	MOV R2, R4
	MOV R1, R5
	BL sudoku              						;       		result = sudoku(grid, nxtrow, nxtcol);
	MOV R11, R3									;     
noElse2											;			}								
noIf9                     						;		}	
	ADD R6, R6, #1
	B for10
noFor10											;	}
	CMP R11, #0            						;	if(!result){
	BNE noIf11
; //made an earlier mistake - back track by setting	; 								//the current square back to zero/blank
	MOV R1, R9
	MOV R2, R10
	;MOV R0, R6
	MOV R3, #0
	BL setSquare						        ;		setSquare(grid,row,col,0);
noIf11                    						; 	}												
noElse									        ; }
endSudoku
	MOV R3, R11             					;return result;
	LDMFD sp!, {R4-R12, pc}          			;}

; printSudoku subroutine
;	Prints the sudoku
; Parameters:
;   R0: Address of the Grid
;   R1: Starting Row Index
;   R2: Starting Column Index
printSudoku
	STMFD sp!, {lr}
	LDR R4, = 1         						;int i = 1
	MOV R6, R0
for8                     						;for (; i <= 9; ) {
	CMP R4, #9
	BHI endFor8	
	LDR R5, = 1									;	j = 1
for9                     						;	for (; j <= 9; ) {
	MOV R0, R6
	CMP R5, #9
	BHI endFor9	
	
	MOV R1, R4
	MOV R2, R5
	BL getSquare	
	MOV R0, R3
	ADD R0, R0, #'0'
	BL sendchar	
	MOV R0, #' '
	BL sendchar
	
	ADD R5, R5, #1								;		j++
	B for9
endFor9											;	}
	LDR R0, =10
	BL sendchar
	ADD R4, R4, #1								;	i++
	B for8
endFor8											;}
	LDMFD sp!, {pc}

; printString subroutine
;	Prints a string
; Parameters:
;   R1: Address of the String
printString
	STMFD sp!, {lr}
	LDR R5, =0
	MOV R4, R1
whilePrint
	LDRB R0, [R4, R5]
	CMP R0, #0
	BEQ endWhilePrint
	BL sendchar
	ADD R5, R5, #1
	B whilePrint
endWhilePrint
	LDR R0, =10
	BL sendchar
	LDMFD sp!, {pc}

	AREA	Grids, DATA, READWRITE

testGridOne
	DCB	0,0,0,0,0,5,6,7,0
	DCB	0,2,3,0,0,0,0,0,0
	DCB	0,4,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	8,0,0,0,0,0,0,0,0
	DCB	9,0,0,0,0,0,0,0,0

testGridTwo
	DCB	0,2,7,6,0,0,0,0,3
	DCB	3,0,0,0,0,9,0,0,0
	DCB	8,0,0,0,4,0,5,0,0
	DCB	6,0,0,0,0,2,0,4,0
	DCB	0,0,2,0,0,0,8,0,0
	DCB	0,4,0,7,0,0,0,0,1
	DCB	0,0,3,0,1,0,0,0,7
	DCB	0,0,0,8,0,0,0,0,9
	DCB	9,0,0,0,0,6,2,8,0

testSolutionTwo
	DCB	1,2,7,6,5,8,4,9,3
	DCB	3,5,4,2,7,9,1,6,8
	DCB	8,9,6,3,4,1,5,7,2
	DCB	6,3,9,1,8,2,7,4,5
	DCB	7,1,2,4,9,5,8,3,6
	DCB	5,4,8,7,6,3,9,2,1
	DCB	2,8,3,9,1,4,6,5,7
	DCB	4,6,5,8,2,7,3,1,9
	DCB	9,7,1,5,3,6,2,8,4

testGridThree
	DCB	0,0,0,9,0,0,0,5,0
	DCB	0,0,3,0,4,0,1,0,6
	DCB	0,4,0,2,0,0,0,8,0
	DCB	7,0,8,0,0,0,0,0,0
	DCB	0,3,0,0,0,0,0,6,0
	DCB	0,0,0,0,0,0,5,0,4
	DCB	0,6,0,0,0,1,0,7,0
	DCB	4,0,2,0,5,0,3,0,0
	DCB	0,9,0,0,0,8,0,0,0

testSolutionThree
	DCB	1,2,7,9,8,6,4,5,3
	DCB	9,8,3,5,4,7,1,2,6
	DCB	5,4,6,2,1,3,7,8,9
	DCB	7,5,8,3,6,4,2,9,1
	DCB	2,3,4,1,9,5,8,6,7
	DCB	6,1,9,8,7,2,5,3,4
	DCB	8,6,5,4,3,1,9,7,2
	DCB	4,7,2,6,5,9,3,1,8
	DCB	3,9,1,7,2,8,6,4,5

Sudoku1String
    DCB  83, 117, 100, 111, 107, 117, 32, 49, 0 
	
Sudoku2String
    DCB  83, 117, 100, 111, 107, 117, 32, 50, 0 

	END
