#######################################################################################
# Anh Vu L nguyen
# CS318
# Project 2: Design a linked list of nodes whose data are string 
#######################################################################################
	
	.data
	
options:	.asciiz	"Please type in one of the number below and press enter: \n 1 - exit program \n 2 - next node \n 3 - previous node \n 4 - insert after current node \n 5 - delete current node \n 6 - reset \n 7 - debug \n"
insertMessage:	.asciiz	"Please type a string up to 10 characters and press enter\n"
character:	.asciiz	""
empty:		.asciiz	"There is no node yet\n"
doneAdding:	.asciiz	"\nAdding is done\n"
currentIs:	.asciiz	"The current node: "
emptyLine:	.asciiz	"\n"
array:		.asciiz 	"All elements in the string: \n"
sep: 		.asciiz		"\t"
	
	.text	
main:
#----------------------------------------------------
#Set up globals that can be accessed from any part of the program
#----------------------------------------------------
	# set the head pointer to be $s7
	# set the current pointer to be $a3
	
start:	
	#check is linked list head is zero, if it is, then show that there's no element
	beqz	$s7, noEle	
	#if not zero, do 3 prints: 1) the current node is: 2) the string to the curr  3) a new line
	la	$a0, currentIs # 1)
	jal	consolePrint
	move	$a0, $a3	# 2)
	jal	consolePrint
	la	$a0, emptyLine #3)
	jal	consolePrint
	
#----------------------------------------------------
# Start with showing the options to the users and let users choose what to do next
#----------------------------------------------------
optionMenu:
	# use print string syscall (to console) to show menu and prompt for input
	la	$a0, options
	jal	consolePrint
	
	# use read character syscall (from console) to get response.
	li	$v0, 5
	syscall
	
	# move response to the temporary register	$t0
	move	$t0, $v0

#----------------------------------------------------
# Choose what to do based on user choice 
#----------------------------------------------------
	beq		$t0, 1, exit
	beq		$t0, 2, next
	beq		$t0, 3, previous
	beq  		$t0, 4, insert  
	beq		$t0, 5, del
	beq		$t0, 6, reset
	beq		$t0, 7, debug
	
	
#----------------------------------------------------
# Syscall to exit the program 
#----------------------------------------------------	
exit:
	li	$v0, 17
	syscall
	
#----------------------------------------------------
# Insert a new node
#----------------------------------------------------		
insert:	
	j	addnode	# call the addnode procedure, no condition needed
#----------------------------------------------------
# Delete a new node
#----------------------------------------------------	
del: 	
	jal	delnode	# call the delnode procedure
	j	start
#----------------------------------------------------
# Traverse the list
#----------------------------------------------------
next:
	beqz	$s7, start	#if the list is empty, just run the menu again
	lw	$t5, 12($a3)	
	bnez	$t5, nextNode	#if we're not at the end of the list, we can get next node
	j	start	#if list not empty + we're at the end of list, just run the menu again

#----------------------------------------------------
# Go to previous node
#----------------------------------------------------
previous:
	beqz	$s7, start	#if list is empty, just run the menu again
	beq	$s7, $a3, start #if we're already at head then there's nothing else to do
	jal	goBack	#if we have things before the current node, we can get the previous node
	j 	start	#if list not empty + we're at the start, just run the menu again
#----------------------------------------------------
# Reset current to be the first node 
#----------------------------------------------------
reset:
	move	$a3, $s7	# Just need to set current to be what head pointer is pointing to
	j	start
#----------------------------------------------------
# Print out the whole linked list
#----------------------------------------------------
debug:
	jal	printEverything
	j	start
#----------------------------------------------------
# PROCEDURES
#----------------------------------------------------
#indicate that there is no element in the list
noEle:
	la	$a0, empty
	jal	consolePrint
	j 	optionMenu
	
#to add node
addnode:
	la	$a0, insertMessage	#instruction for adding node
	jal	consolePrint
	
	# allocate space
	jal alloSpace
	move	$t1, $v0	# register t1 now has the address to the allocated space (12 bytes)
	
	sw	$zero, ($t1)	# initialized previous to zero
	sw	$zero, 16($t1)	# initialized next to zero
	
	#read input string for node
	li	$v0, 8
	la	$a0, 4($t1)
	li	$a1, 10
	syscall	

	#if list is empty, this is the first node
	beqz	$s7, declareFirstNode
	
	# Assumptions:
	#   $a3: ptr to current node (a global variable)
	#   $t1: ptr to new node (a parameter to the procedure)
	#
	
	lw	$t2, 16($a3)	# check for next node of current node
	beqz	$t2, noNextNode
	
	#if there' next node, adding starts here
	move	$t0, $t2	# moving pointers into a temporary pointer
	la	$t2, 16($t1)	# load the address of new node string
	la	$t0, -4($t0)	# load the address of previous field of curent node
	sw	$t2, ($t0)	# store new string's address into previous field
	
noNextNode:
	#if there's no next node, adding can just start from here
	lw	$t2, 12($a3)	# get address of next field of current node
	sw	$t2, 16($t1)	# store that adress in new node's next field 
	
	la	$t0, 4($t1)	# get address of current string
	sw	$t0, 12($a3)	# store that address into current node's next field
	
	la	$t2, ($a3)	#load address of current node's string
	sw	$t2, ($t1)	#store that address into the current node's previous field
	
	la	$a3, 4($t1) # reset curr to be the new node
	
	#done adding new node, declare that adding is done & jump back to main	
	la	$a0, doneAdding
	jal	consolePrint	
	j	start
	
# To delete node
delnode:
	beqz	$s7, start	#if list is empty, go to menu
	
	lw	$t2, -4($a3)	#load address of previous node
	beqz	$t2, delHead	#if no previous node, this is a head node
	
	lw	$t3, 12($a3)	#load address of next node
	beqz	$t3, delTail	#if no previous node, this is a tail node
	
	lw	$t3, 12($a3)	#load address of next node
	sw	$t2, -4($t3)	#store address of previous node in next node's previous field
	
	lw	$t2, 12($a3)	# load address of next node
	lw	$t3, -4($a3)	# load address of previous node 
	sw	$t2, 12($t3)	#store address of next node in previous node's next field
	
	la	$a3, ($t2)	#the new curr is the next node
	
doneDel:			
	jr	$ra

delHead:
	lw	$t2, 12($a3)
	sw	$zero, -4($t2)
	la	$s7, ($t2)
	la	$a3, ($t2)
	j	doneDel
	
delTail:
	lw	$t2, -4($a3)
	sw	$zero, 12($t2)
	la	$a3, ($t2)
	j	doneDel
	
# To go to the next node
nextNode:
	la	$t5, 12($a3)
	lw	$a3, ($t5)
	j	start
	
# To go back to previous node
goBack:
	la	$t5, -4($a3)
	lw	$a3, ($t5)
	jr	$ra

# To print everything from the list
printEverything:
	la	$a0, array
	jal	consolePrint
	la	$t1, ($s7)
	beqz	$t1, start
	
printEle:
	move 	$a0, $t1
	jal 	consolePrint
	
	la	$a0, sep
	jal	consolePrint
	
	lw	$t2, 12($t1)
	beqz	$t2, start
	la	$t1, ($t2)
	j	printEle
	

#allocate space in the heap
alloSpace:
	li	$v0, 9
	li	$a0, 20 # allocates 12 bytes, 4 to point to previous, 12 for string and 4 for next
	syscall
	jr	$ra

#delcare first node for insert into empty string (this works)
declareFirstNode:
	la	$s7, 4($t1)	#set head pointer to point to string in the new node
	la	$a3, 4($t1)	#set curr pointer to point to string in the new node
	la	$a0, doneAdding
	jal	consolePrint
	j	start
			
#syscall to print something
consolePrint:
	li	$v0, 4
	syscall
	jr	$ra
	
