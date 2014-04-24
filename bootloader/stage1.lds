OUTPUT_FORMAT(binary)
SECTIONS{
	.output 0x00 :
	{
		*(.text);
		. = 0x1FE;
		SHORT(0x55AA);
	}
}