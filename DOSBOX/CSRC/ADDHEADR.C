/* Program to PCJr Cartride Header/Footer from a ROM */
#include <stdio.h>
#include <string.h>

unsigned char *rom; /* Buffer to hold the ROM data */
unsigned char *jrc_header; /* Buffer to hold the header */
/* Main Function */
main(argc, argv, envp)
	int argc;
	char **argv;
	char **envp;
	{
	
	/* VARIABLES */
	
	int i;
	char c;
	
	char *file_name;
	FILE *file;
	unsigned int rom_size = 0;
	char *output_file_name;
	FILE *ofile;
		
	int size_of_jrc_str = 0;
	char *jrc_str = "PCjr Cartridge image file"; /* Zero terminated string */
	char *ptr;
	unsigned char terminator1;
	unsigned char terminator2;
	
	unsigned char *str;
	
	unsigned int minimum_rom_size = 512;
	unsigned int pcjr_cart_header_size = 256; 
	
	unsigned int start_pos = 0;
	unsigned int jrc_header_size = 512;
	
	
	char *creator = "012345678901234567890123456789";
	int size_of_creator = 30; /* Must be 30 bytes */
	
	/* CODE */
	fprintf(stderr,"PCJr Add JRC Header\n");
	if ( argc != 3 ){
		fprintf(stderr,"Arg $1: PCJr ROM file input w/o JRC (ROM.JRB)\n");
		fprintf(stderr,"Arg $2: PCJr ROM file output w/o JRC (ROM.JRC)\n");
		return 1;
	}
	
	file_name = argv[1];
	fprintf(stderr,"PCJr JRC Input ROM: %s\n",file_name);
	output_file_name = argv[2];
	fprintf(stderr,"PCJr Output Binary ROM: %s\n",output_file_name);
	
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
	
	/* Adding 512 to the ROM size to make room for the JRC header */
	rom_size+=pcjr_cart_header_size; 
	fprintf(stderr,"ROM Size w/ PCJr/COM header: %d bytes\n",rom_size);
	
	/* Allocate memory + 512bytes at the beginning for the header and read the file */
	rom = (unsigned char *)malloc(rom_size);
	for (i = 0; i < rom_size; i++){
		c = getc(file);
		rom[i+pcjr_cart_header_size]=c; /* Write starting at offset 512 */
	}
	fclose(file);
	
	/* Checking to see if the file meets the minimum size requirement */
	if ( rom_size < minimum_rom_size ){
		fprintf(stderr,"ERROR, file size less than 512b, exiting.\n");
		return 3;
	}
		
	/* Zero out header */
	for (i = 0; i < pcjr_cart_header_size; i++){
		rom[i] = 0;
	}
	
	rom[0] = 0x55;
	rom[1] = 0xAA;
	rom[2] = rom_size / 512;
	rom[3] = 0xE9 ; /* JMP instruction EB FA 00 - JMP 0100, the ROM_CHECK entry point*/
	rom[4] = 0xFA ; 
	rom[5] = 0x00 ; 
	rom[6] = 0x00 ;
	
	
	
	/* Output ROM file */
	ofile = fopen(output_file_name,"wb"); 
		
	/* Output ROM Data */
	for (i = 0; i < rom_size; i++){
		fprintf(ofile,"%c",rom[i]);
	}
	close(ofile);
	free(rom); /* Free memory */
	return 0;
}
