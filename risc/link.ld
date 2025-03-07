ENTRY(_start)

SECTIONS
{
  . = 0x0000;
  
  .init :
  {
        *(.init)
  }
  
  .text :
  {
	*(.text)
  }
  
  .data :
  {
	*(.data)
  }

  .rodata : {
	*(.rodata)
  	*(.rodata.*)
    	*(.rodata.str*)
	*(.rodata.cst*)
  }
  
  .bss :
  {
	*(.bss)
  }	
}