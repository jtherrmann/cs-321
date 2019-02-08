;;; source: http://lawlor.cs.uaf.edu/~olawlor/2019/dsl_examples/diskIO.asm
	
	;  Tiny boot block disk linear addressing example
	;  Dr. Orion Lawlor, lawlor@alaska.edu, 2019-01-31 (Public Domain)

	BITS 16 ; awful segmented memory
	ORG 0x07C00 ; bios loads this boot block to linear address 0x07C00 

	start:
	  cli ; disable interrupts until we're set up
	; Zero out all the segment registers
	xor ax, ax ; ax=0
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0xfff0 ; put stack pointer at end of our 64K area

	;; source: https://docs.google.com/document/d/1u4YbtQYCg26b5Ap6GzNQlAkED_pvNbg78rrwqI_A6Nc/edit
	mov WORD [4*0x32], printchar ; offset to handler code
	mov WORD [4*0x32+2], 0 ; segment number of handler


	sti ; allow interrupts now that everything's set up

	  mov al,'O'
	  call printchar
	  
	  ; Do disk read using linear block addressing: BIOS INT 13,42: 
	  ;    https://en.wikipedia.org/wiki/INT_13H  
	  mov ah,0x42             ;function number for LBA disk read
	  mov si,read_DAP         ;memory location of Disk Address Packet (DAP)
	  
	  ; The boot drive is actually loaded to register dl on startup
	  ; mov dl,0x80             ;drive (0x80 is hard drive, 0 is A:, 1 is B:)
	  int 0x13                ;read the disk
	  
	  ; If that read worked, we just read disk data to this memory
	  mov al,[0x9000]
	  call printchar

	call 0xC0DE
	  
	hang: jmp hang  ; wait here (forever)


	; Disk Address Packet (DAP) identifies the data to read.
	read_DAP:
	  db 0x10 ; Size of this DAP in bytes
	  db 0 ; unused
	  dw 1 ; sector read count
	  dw 0xC0DE ; memory target: offset
	  dw 0 ; memory target: segment
	  dq 1 ; 0-based disk sector number to read


	;***** Utility: Text output functions **********
	; Print one character, passed in al.
	;   Trashes: bx
	printchar:
	; See http://stanislavs.org/helppc/int_10-e.html
	mov bx, 0x0007  ; 'output character' selector
	mov ah, 0x0e; Output a character
	int 0x10  ; "output character" INT 10,E
	ret

	; pad to make this boot sector exactly 512 bytes long total
	times 512-2-($-start) db 0x90  

	; A boot sector's last two bytes must contain this magic flag.
	dw 0xAA55 ; Magic value needed by BIOS

	; End of boot sector 0
	; -----------------------------------------------------
	; Start of sector 1 (immediately follows boot sector on disk)
	sector1_start:

	;; source: https://lawlor.cs.uaf.edu/netrun/run?hw=2019_CS321/HW2/0
	
	db 0xbe, 0x00, 0x00, 0x8a, 0x84, 0xf3, 0xc0, 0x3c, 0x00, 0x74, 0x09, 0x34, 0xa5, 0xcd, 0x32, 0x83
	db 0xc6, 0x01, 0xeb, 0xef, 0xc3, 0xe7, 0xc0, 0x85, 0xd6, 0xd0, 0xd7, 0xc0, 0x85, 0xd1, 0xca, 0x85
	db 0xc1, 0xd7, 0xcc, 0xcb, 0xce, 0x85, 0xdc, 0xca, 0xd0, 0xd7, 0x85, 0xea, 0xd3, 0xc4, 0xc9, 0xd1
	db 0xcc, 0xcb, 0xc0, 0x89, 0x85, 0xf7, 0xc4, 0xc9, 0xd5, 0xcd, 0xcc, 0xc0, 0x84, 0x85, 0x85, 0x85
	db 0xe6, 0xf6, 0x85, 0x96, 0x97, 0x94, 0x85, 0xcd, 0xd2, 0x97, 0x8b, 0x95, 0x85, 0xc4, 0xcb, 0xd6
	db 0xd2, 0xc0, 0xd7, 0x9f, 0x85, 0x95, 0xdd, 0xc3, 0x95, 0x95, 0xc1, 0x93, 0x95, 0x95, 0xc1, 0x00
	times (512 - 6*16) db 0
