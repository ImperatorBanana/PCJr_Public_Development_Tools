/* Program to Load a ROM File on the RAM CART */

#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <memory.h>

struct SREGS *dos_regs;
char dummy_read; /* Declare on the heap I think so it'll be relatve to DS */
unsigned char *rom;  

/* Main Function */
main(argc, argv, envp)
	int argc;
	char **argv;
	char **envp;
	{
	
	/* VARIABLES */
	unsigned int i;
	char c;
	
	char *file_name;
	FILE *file;
	unsigned int rom_size = 0;
	
	/* Cart writing stuff */
	unsigned int cart_segment = 0;
	unsigned int cart_address = 0;
		
	/* CODE */
	fprintf(stderr,"PCJr Load ROM File onto RAM CART\n");
	if ( argc != 2 ){
		fprintf(stderr,"Arg $1: PCJr ROM file input w/o JRC (ROM.JRB)\n");
		return 1;
	}
	
	file_name = argv[1];
	fprintf(stderr,"PCJr JRC Input ROM: %s\n",file_name);
		
	/* Open input file */
	file = fopen(file_name,"rb");
	
	/* Determine ROM file size and then reset the file ptr*/
	while(1){
		fgetc(file);
		if(feof(file)){
			break;
		}
		rom_size++;
	}
	rewind(file); 
	
	/* Error out if file is zero */
	if ( rom_size == 0 ){
		fprintf(stderr,"Error reading file, got 0 byte size, exiting.\n");
		fclose(file);
		return 2;
	}
	else {
		fprintf(stderr,"ROM Size: %d bytes\n",rom_size);
	}
	
	/* Allocate memory and read the file */
	rom = (unsigned char *)malloc(rom_size);
	for (i = 0; i < rom_size; i++){
		c = getc(file);
		rom[i]=c;
	}
	fclose(file);
	
	segread(dos_regs); /* Read in the current segment registers */
		
	/* Output ROM Data */
	for (i = 0; i < rom_size; i++){
		/* Methodology for writing to cartridge ram */
		/* 1.) Read E0000 + data - Cache 8 bits of data with dummy read where lower address byte is data*/
		cart_segment = 0xE000; /* Cache */
		cart_address = 0 + rom[i]; 
		movedata(cart_segment,cart_address,dos_regs->ds,&dummy_read,1); /* Source is cart "read", dest is dummy
		/* 2.) Read E8000 + address (0 - 8000h) - 32k, to write the cached data to the address*/
		cart_segment = 0xE800; /* "Write" */
		cart_address = i; 
		movedata(cart_segment,cart_address,dos_regs->ds,&dummy_read,1); /* Source is cart "read", dest is dummy */
	}
	fprintf(stderr,"\n");
	free(rom); /* Free memory */
	return 0;
}
