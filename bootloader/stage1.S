.equ BOOT_ADDRESS, 0x07c0
.equ COPY_ADDRESS, 0x0050
.equ STACK_ADDRESS, 0x0700
	
.equ SECTOR_SIZE, 0x200
.equ STACK_SIZE, 0x200

.code16
.text

/*
 * Start entry point.
 * Move the code loaded by the bios from address 0x7c00
 * to 0x0500. it's the lower free address ram.
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

_loop:
	jmp .				#loop