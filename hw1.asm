;;; Jake Herrmann
;;; CS 321 HW 1
;;; https://www.cs.uaf.edu/2019/spring/cs321/hw/hw1/

;;; For each segment to be tested:
;;; 
;;; 1. Set SEGMENT to the segment.
;;; 2. Set TEST to testStack and run the program.
;;; 3. Set TEST to testReadWrite and run the program.

;;; To run the program:
;;; 
;;; nasm hw1.asm -o hw1.bin
;;; qemu-system-x86_64 hw1.bin

	%define SEGMENT 0x0000
	%define TEST testStack

BITS 16

	jmp TEST

testStack:
	;; Set the stack segment to SEGMENT and see if we can call functions.
	;; We should print "Hi!" if it works.

	mov ax, SEGMENT
	mov ss, ax
	mov sp, 0x100

	mov cl, 'H'
	mov di, 0x0000
	call printChar

	mov cl, 'i'
	mov di, 0x0002
	call printChar

	mov cl, '!'
	mov di, 0x0004
	call printChar

	jmp hang

testReadWrite:
	;; Overwrite the first row of characters with spaces.
	mov cl, ' '
	mov di, 0x0000
	.loop:

	call printChar
	add di, 0x0002

	.test:
	cmp di, 0x0040
	jne .loop

	;; Overwrite cl with 'Y' and print it for visual confirmation. We do
	;; this so that we can be sure that the next step successfully
	;; overwrites cl with the contents of [es:0x0000].
	mov BYTE cl, 'Y'
	mov di, 0x0000
	call printChar

	;; Set es to SEGMENT.
	mov ax, SEGMENT
	mov es, ax

	;; Test if we can read memory at [es:0x0000].
	;; 
	;; Overwrite cl with [es:0x0000] and print it for visual confirmation.
	;; If we print another 'Y', then it probably means we failed to move
	;; [es:0x0000] into cl and just printed the 'Y' that we put in cl
	;; during the previous step. In this case, we should set cl to some other
	;; character in the previous step and re-run the program, to make sure
	;; that [es:0x0000] does not just happen to contain a 'Y'. If we change
	;; cl to another character and still see it printed twice, then it seems
	;; likely that we can't move [es:0x0000] into cl.
	mov BYTE cl, [es:0x0000]
	mov di, 0x0002
	call printChar

	;; Test if we can write memory at [es:0x0000].
	;;
	;; Overwrite [es:0x0000] with 'Z' and print it for visual confirmation.
	;; If we print the same character as was printed by the previous step,
	;; then it probably means we cannot write [es:0x0000].
	;;
	;; I don't know how we would test the ability to write to [es:0x0000]
	;; if we cannot read from [es:0x0000] in order to print its contents.
	;; Hopefully there are no segments that can be written but not read.
	mov BYTE [es:0x0000], 'Z'
	mov BYTE cl, [es:0x0000]
	mov di, 0x0004
	call printChar

	;; Note: this test works a bit differently for segment 0xB800. First we
	;; print 'Y' to the first column of the first row, which is done by
	;; writing 'Y' to 0xB800:0x0000. Then we print the contents of
	;; 0xB800:0x0000 to the second column, so we print 'Y' again. Then we
	;; write 'Z' to 0xB800:0x0000, which overwrites the 'Y' in the first
	;; column with a 'Z'. Finally, we print the contents of 0xB800:0x0000
	;; to the third column. So if 0xB800 is readable and writable we should
	;; see ZYZ printed in the upper left corner of the screen.

	jmp hang

printChar:
;;; Print the byte in cl to 0xB800:di.
	push ax
	push es
	
	mov ax, 0xB800
	mov es, ax
	mov BYTE [es:di], cl

	pop es
	pop ax

	ret

hang:
	jmp hang

times 510-($-$$) db 0  
	db 0x55
	db 0xaa
