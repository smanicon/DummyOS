.code16
.text

.global E2SBlock
.global E2Block

/**
 * Read the Super block EXT2 sector.
 *
 * DL 		=> BIOS disk drive
 * ES:DI 	=> Output super block
 *
 * AH 		<= return code
 */
E2SBlock:
	pushw %bp		# Save BP register
	movw %sp, %bp		# And set BP to the current SP

				# DAP Bios interupt 0x13 (0x42)
	pushw $0x0000		# 8b : LBA
	pushw $0x0000		#
	pushw $0x0000		#
	pushw $0x0002		#
	pushw %es		# 2b : segment
	pushw %di		# 2b : offset
	pushw $0x0001		# 2b : number of sector
	pushw $0x0010		# 1b : Size of the DAP
				# 1b : reserved

	pushw %si		# Save SI registry
	pushw %ds		# Save DS segment

				# DS:SI should point on SS:BP-10h
	movw %ss, %ax		#
	movw %ax, %ds		# Set DS = SS

	movw %bp, %si		# Set SI = BP-10h
	subw $0x0010, %si	#

	movw $0x4200, %ax	# Set AH=42
	int $0x13		#Call 13h interupt

	popw %ds		# Get back DS
	popw %si		# Get back SI

	addw $0x0010, %sp	# Clear the Stack
	pop %bp			# Get back BP registry
	ret
	
/**
 * Used to read a block
 *
 * DL 		=> BIOS disk drive
 * DS:SI	=> Pointer to memory where :
 *				-32bit : SEGMENT:OFFSET of the superblock
 *				-32bit : select the block to read
 * ES:DI 	=> Output block information
 *
 */
E2Block:
	pushw %bp		# Save the BP in the Stack
	movw %sp, %bp		# And Set the BP to the current stack pointer

	pushw $0x0000		# 8b : LBA	
	pushw $0x0000
	pushw $0x0000
	pushw $0x0000
	pushw %es		# 2b : segment	
	pushw %di		# 2b : offset	
	pushw $0x0000		# 2b : number of sector	
	pushw $0x0010		# 2b : DAP size

	subw $0x08, %sp		# Allow space for load DS:SI data	
	pushw %si		# Save SI registry
	pushw %di		# Save DI registry
	pushw %ds		# Save DS Segment
	pushw %es		# Save ES Segment
	
// Copy data DS:SI in the stack :
	movw %ss, %ax		# Get the code segment
	movw %ax, %es		# To set it to ES Segment
	leaw -0x18(%bp), %di	# set DI registry to the stack address
	movw $0x04, %cx		# Set the size of the copy
	rep movsw;		# Copy the data
	
	movw -0x12(%bp), %ax 	# Set the Superblock Segment
	movw %ax, %ds		# to DS
	movw -0x14(%bp), %si	# Set the Superblock Offset to SI

//Test Magic Number	
	pushw %si		# Save SI
	addw $0x38, %si		# Go to the magic code
	lodsw			# Set it to AX
	pop %si			# Get back SI
	cmpw %ax, 0xEF53	# Test magic number
	jnz 9f			# End if wrong

//Load block size
	pushw %si		# Save SI
	addw $0x18, %si		# Go to log block size	
	lodsw			# Set high log block size to ax
	test %ax, %ax 		# must be set to 0
	jnz 9f			# else end call
	
	lodsw			# Set low log block size to ax
	cmpw $0x04, %ax		# Must be less than 4
	jle 9f			# Else end call
	
	movw %ax, %cx		# Set it to CX
	movb $0x02, %al		# Set AX to 2 (for 2 sectors)
	shlw %cl, %ax		# AX = Log(AX, CX)
	movw %ax, 0x0c(%bp)	# Save AX to DAP, count sector
	
//TODO: Block to sector
	//jcxz
	//clc
	
	

//TODO: END

	xorw %ax, %ax		# Clear AX
	jmp 9f			# Jump end call
	
	movw $0x0001, %ax
9:	
	pop %es			# Get back ES segment
	pop %ds			# Get back DS segment
	pop %di			# Get back DI registry
	pop %si			# Get back SI registry
	
	addw $0x16, %bp		# Free memory on the stack
	pop %bp			# Get back BP Registry
	ret

/**
 * Used to read block data.
 *
 * DL 		=> BIOS disk drive
 * DS:SI	=> Input block information
 * ES:DI 	=> Output block data
 */
readExt2BlockData:

/**
 * Used to search the block from a directory block
 * with it's name.
 *
 * DL		=> BIOS disk drive
 * DS:SI	=> Pointer to memory where :
 *				- 16bit : SEGMENT:OFFSET information directory block
 *				- 16bit : SEGMENT:OFFSET data directory block buffer
 *				- 16bit : SEGMENT:OFFSET name of the block name, end with 0x00 or '/'
 */
getBlockFromName:




