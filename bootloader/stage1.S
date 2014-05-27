.equ BOOT_ADDRESS, 0x07c0
.equ COPY_ADDRESS, 0x0050
.equ STACK_ADDRESS, 0x0070
.equ SBLOCK_ADDRESS, 0x00A0
	
.equ SECTOR_SIZE, 0x200
.equ STACK_SIZE, 0x200


.code16
.text

/*
 * Start entry point.
 * Copy bootloader from BOOT_ADDRESS to COPY_ADDRESS
 */
_start:
	movw $BOOT_ADDRESS, %ax 	#put the start bootloader address
	movw %ax, %ds			#on DS registry
	
	movw $COPY_ADDRESS, %ax		#put the new location of the bootloader
	movw %ax, %es			#on ES registry
	
	xorw %si, %si			#set SI and DI registry
	xorw %di, %di			#to 0 value
	
	movw $SECTOR_SIZE / 2, %cx	#set CX registry to copy the bootloader
	rep movsw			#copy the bootloader
	
	ljmp $COPY_ADDRESS, $_init	#Jump to the new address
	
/*
 * init memory.
 * init all segments registries, and the stack.
 */
_init:
	movw %cs, %ax			#get the CS value registry to init
	movw %ax, %ds			#DS registry and
	movw %ax, %es			#ES regitry
	
	movw $STACK_ADDRESS, %ax	#set the new stack segment address
	movw %ax, %ss			#
	
	movw $STACK_SIZE, %ax		#set the stack size
	movw %ax, %bp			#
	movw %ax, %sp			#

/*
 * to work well, the bootloader need the int 13h
 * extension
 */
_checkExt:
	movw $0x4100, %ax
	movw $0x55aa, %bx
	int $0x13
	
	jc _loop

/*
 * Load the superblock
 */
_loadSP:
	movw $SBLOCK_ADDRESS, %ax
	movw %ax, %es
	xorw %di, %di

	call E2SBlock
	
_loop:
	jmp .				#loop