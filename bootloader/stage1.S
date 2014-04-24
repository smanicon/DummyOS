.code16
.text

/*
 * Start entry point.
 * Move the code loaded by the bios from address 0x7c00
 * to 0x0500. it's the lower free address ram.
 */
_start:
	movw $0x07c0, %ax 	#put the 0x07c0 address segment
	movw %ax, %ds		#on DS registry
	
	movw $0x0050, %ax	#put the 0x0050 address segment
	movw %ax, %es		#on ES registry
	
	xorw %si, %si		#set SI and DI registry
	xorw %di, %di		#to 0 value
	
	movw $0x0200, %cx	#set CX registry 0x200(=512 octet (boot size))
	rep movsw			#will call 512 times movw to move memory DS:SI to ES:DI
	
	ljmp $0x0050, $_init	#Jump to the new address
	
/*
 * init memory.
 * init all segments registries, and the stack.
 */
_init:
	movw %cs, %ax		#get the CS value registry to init
	movw %ax, %ds		#DS registry and
	movw %ax, %es		#ES regitry
	
	movw $0x0070, %ax	#set the stack segment above the code for no colision
	movw %ax, %ss		#0x700 = 0x500 + 0x200
	
	movw $0x0100, %ax	#init stack pointer and base stack pointer, with
	movw %ax, %bp		#a value of 0x100 (enough for this loader)
	movw %ax, %sp		#

_loop:
	jmp .
	
