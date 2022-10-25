/* Program to remove a JRC Header from a ROM */
#include <stdio.h>
#include <string.h>

unsigned char *rom; /* Buffer to hold the ROM data */

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
	
	unsigned int start_pos = 0;
	
	/* CODE */
	fprintf(stderr,"PCJr Remove JRC Header\n");
	if ( argc != 3 ){
		fprintf(stderr,"Arg $1: PCJr ROM file input w/ JRC (ROM.JRC)\n");
		fprintf(stderr,"Arg $2: PCJr ROM file output w/o JRC (ROM.JRB)\n");
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
		
	/* Allocate memory and read the file */
	rom = (unsigned char *)malloc(rom_size);
	for (i = 0; i < rom_size; i++){
		c = getc(file);
		rom[i]=c;
	}
	fclose(file);
	
	/* Checking to see if the file meets the minimum size requirement */
	if ( rom_size < 512 ){
		fprintf(stderr,"ERROR, file size less than 512b, exiting.\n");
		return 3;
	}
	
	/* Determine length of the JRC String and allocate a string to check if the file actually is JRC */
	for (ptr = jrc_str; *ptr != '\0';ptr++){
		size_of_jrc_str++;
	}
	size_of_jrc_str++; /* Add spot for null terminator */
	
	fprintf(stderr,"Size of JRC Str: %d\n",size_of_jrc_str);
	str = (char *)malloc(size_of_jrc_str);
	
	/* Read in the JRC header from the ROM */
	for (i = 0; i < size_of_jrc_str-1; i++){
		str[i] = rom[i];
	}
	str[size_of_jrc_str-1] = '\0'; /* Add null terminator */
	terminator1 = rom[size_of_jrc_str-1];
	terminator2 = rom[size_of_jrc_str];

	if (strcmp(jrc_str,str) == 0 && terminator1 == 0x0D && terminator2 == 0x0A){
		fprintf(stderr,"Found JRC header: %s,%02Xh,%02Xh\n",str,terminator1,terminator2);
		start_pos=512;
	}
	else {
		fprintf(stderr,"ERROR, did not find JRC Header, exiting\n");
		free(str);
		free(rom);
		return 4;
	}
	fprintf(stderr,"Start Position: %d\n",start_pos);
	free(str); /* Free the JRC String memory */
	
	/* Output from end of JRC to end of file */
	ofile = fopen(output_file_name,"wb"); 
	for (i = start_pos; i < rom_size; i++){
		fprintf(ofile,"%c",rom[i]);
	}
	close(ofile);
	free(rom); /* Free memory */
	return 0;
}
