.code16
.text

.global E2SBlock

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
	