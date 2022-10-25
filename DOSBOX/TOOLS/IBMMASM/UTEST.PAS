{ $linesize:93 }
{ $debug- }
(**************************************************************************)
(*									  *)
(*   ***  THIS PROGRAM CAN BE COMPILED ON PASCAL VERSION 2.0 ONLY!  ***   *)
(*									  *)
(*   THIS PROGRAM PROVIDES AN EXAMPLE OF HOW TO INTERFACE WITH THE DATA   *)
(*   CONVERSION ROUTINES WRITTEN IN ASSEMBLY THAT CONVERT NUMBERS FROM	  *)
(*   BINARY REAL FORMAT TO 8087 FORMAT AND BACK AGAIN. THE ASSEMBLY	  *)
(*   ROUTINES REFERENCED ARE IN THE LIBRARY IBMUTIL.LIB. THE FILE CALLED  *)
(*   IBMASM.ASM SHOULD BE ASSEMBLED AND LINKED WITH THE OBJECT MODULE	  *)
(*   PRODUCED FROM COMPILING THIS PROGRAM AND THE ABOVE LIBRARY SHOULD	  *)
(*   BE SPECIFIED.							  *)
(*									  *)
(**************************************************************************)

program reader (input,output);

(**************************************************************************)
(*   THE FOLLOWING ARE DECLARATIONS OF THE EXTERNAL ASSEMBLY SUBROUTINES  *)
(*   THAT PROVIDE THE INTERFACE TO THE CONVERSION ROUTINES IN THE LIBRARY.*)
(**************************************************************************)

procedure i8tom8 (vars x,y:real8); extern;
procedure m8toi8 (vars x,y:real8); extern;
procedure i4tom4 (vars x,y:real4); extern;
procedure m4toi4 (vars x,y:real4); extern;
procedure i8toi4 (vars x:real8; vars y:real4); extern;
procedure i4toi8 (vars x:real4; vars y:real8); extern;

(**************************************************************************)
(* DECLARE VARIABLES NEEDED IN PASCAL TO HANDLE DATA CONVERSION ROUTINES  *)
(**************************************************************************)

var
	x4,y4,z4    : real4;		    (* SINGLE PRECISION VARIABLES *)
	x,x8,y8,z8  : real8;		    (* DOUBLE PRECISION VARIABLES *)
	ax4, ax8    : adrmem;		    (* ADDRESS POINTERS TO VARS   *)
	i	    : integer;		    (* LOOP COUNTER TO PRINT VARS *)

begin
	ax4 := adr x4;
	ax8 := adr x8;
	while 1=1 do
	begin
		write ('*** Please enter number to be converted: ');
		readln(x);
		x8 := x; x4 := x;
		writeln(x4);
		write('8087 SINGLE PRECISION        = ');
		for i:=0 to 3 do
			write(ax4^[wrd(i)]:2:16,' ');
		writeln(' ');
		write('BINARY REAL SINGLE PRECISION = ');
		i4tom4(x4,x4);
		for i:=0 to 3 do
			write(ax4^[wrd(i)]:2:16,' ');
		writeln(' ');
		write('8087 SINGLE PRECISION        = ');
		m4toi4(x4,x4);
		for i:=0 to 3 do
			write(ax4^[wrd(i)]:2:16,' ');
		writeln(' ');
		writeln(' ');

		writeln(x8);
		write('8087 DOUBLE PRECISION        = ');
		for i:=0 to 7 do
			write(ax8^[wrd(i)]:2:16,' ');
		writeln(' ');
		write('BINARY REAL DOUBLE PRECISION = ');
		i8tom8(x8,x8);
		for i:=0 to 7 do
			write(ax8^[wrd(i)]:2:16,' ');
		writeln(' ');
		write('8087 DOUBLE PRECISION        = ');
		m8toi8(x8,x8);
		for i:=0 to 7 do
			write(ax8^[wrd(i)]:2:16,' ');
		writeln(' ');
		writeln(' ');

		x8 := x;
		x4 := x;
		i4toi8(x4,y8);
		i8toi4(x8,y4);
		writeln('8087 SINGLE --> 8087 DOUBLE:');
		writeln(x4,' --> ',y8);
		writeln('8087 DOUBLE --> 8087 SINGLE:');
		writeln(x8,' --> ',y4);

	end;

end.
