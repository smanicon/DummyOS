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
 * ES:DI 	=> Output block information (wrote if AX=0x0000)
 *
 * AX		<= 0x0000 if OK
 *		<= 0xFF00 if wrong magic code
 *		<= 0xFF0F if bad block size (>4kb)
 *
 */
E2Block:
	pushw %bp		# Save the BP in the Stack
	movw %sp, %bp		# And Set the BP to the current stack pointer

	xorw %ax, %ax		# Clear %AX 

	pushw %ax		# 8b : LBA	
	pushw %ax
	pushw %ax
	pushw %ax
	pushw %es		# 2b : segment	
	pushw %di		# 2b : offset	
	pushw %ax		# 2b : number of sector	
	pushw $0x0010		# 2b : DAP size

	subw $0x08, %sp		# Allow space for load DS:SI data	
	pushw %si		# Save SI registry
	pushw %di		# Save DI registry
	pushw %ds		# Save DS Segment
	pushw %es		# Save ES Segment
	pushw %cx		# Save CX registry
	
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
	movw 0x38(%si), %ax
	cmpw $0xEF53, %ax	# Test magic number
	jz 1f			# if wrong
	movw $0xFF00, %ax	# Set Bad magic code return
	jmp 9f			# Go to the end
1:	

//Load block size
	movw 0x18(%si), %ax	# Set high log block size to ax
	test %ax, %ax 		# must be set to 0
	jz 2f			# else
1:	movw $0xFF0F, %ax	# Set bad block size code return
	jmp 9f			# Go to the end
	
2:	movw 0x19(%si), %ax	# Set low log block size to ax
	cmpw $0x04, %ax		# Must be less than 4
	jge 1b			# Go to the bad block size return

//Set the DAP
	movw %ax, %cx		# Set block size to CX
	movw $0x0002, %ax	# Set AX = 2 (for 2 sectors)
	shlw %cl, %ax		# AX = Log(AX, CX)
	movw %ax, -0x0e(%bp)	# Save AX to DAP, count sector

	movw %dx, %cx		# Save DX into CX
	mulw -0x16(%bp)		# DX:AX = Block Size * Block to Read (octet 1)
	addw $0x04, %ax		# AX += 4 (4 for MBR + Super Block)
	adcw $0x00, %dx		# DX += Carry
	movw %ax, -0x08(%bp)	# Save AX to DAP LBA (octet 1)
	movw %dx, -0x06(%bp)	# Save DX to DAP LBA (octet 2)

	movw -0x0e(%bp), %ax	# Load AX = DAP Sector Count (= Block Size)
	mulw -0x18(%bp)		# DX:AX = Block Size * Block to Read (octet 2)
	addw -0x04(%bp), %ax	# AX += DAP LBA (octet 2)
	adcw $0x00, %dx		# DX += Carry
	movw %ax, -0x06(%bp)	# Save AX to DAP LBA (octet 2)
	movw %dx, -0x04(%bp)	# Save DX to DAP LBA (octet 3)
	movw %cx, %dx		# Restor DX from CX

	
	movw %ss, %ax
	movw %ax, %ds
	leaw -0x10(%bp), %si
	movw $0x4200, %ax
	
	int $0x13
9:
	pop %cx			# Get back CX registry
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




