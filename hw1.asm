;;; Jake Herrmann
;;; CS 321 HW 1
;;; https://www.cs.uaf.edu/2019/spring/cs321/hw/hw1/

BITS 16

	;; TODO: update comments to reflect that it seems the program does not
	;; crash where I'd hoped

	;; TODO: read comments/code again to make sure the tests make sense

main:	
	;; Overwrite the first row with spaces.
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

	;; Segment to be tested.
	mov ax, 0xF000
	mov es, ax

	;; Test if we can read memory at [es:0x0000].
	;; 
	;; Overwrite cl with [es:0x0000] and print it for visual confirmation.
	;; If we print a 'Y', then perhaps [es:0x0000] happened to contain a
	;; 'Y', in which case we should set cl to some other character in the
	;; above step and run the program again to make sure that we are not
	;; just failing to overwrite cl here and re-printing its contents from
	;; the above step. (Though I hope the program would actually crash
	;; if [es:0x0000] cannot be read, rather than just silently fail to
	;; overwrite cl.)
	mov BYTE cl, [es:0x0000]
	mov di, 0x0002
	call printChar

	;; Test if we can write memory at [es:0x0000].
	;;
	;; Overwrite [es:0x0000] with 'Z' and print it for visual confirmation.
	;; If we print the same character as was printed by the above step,
	;; then it probably means we failed to overwrite [es:0x0000]; though,
	;; again, I hope the program would crash in this case.
	;;
	;; I don't know how we would test the ability to write to [es:0x0000]
	;; if we cannot read from [es:0x0000] in order to print its contents.
	;; Hopefully there are no segments that can be written but not read.
	mov BYTE [es:0x0000],'Z'
	mov BYTE cl, [es:0x0000]
	mov di, 0x0004
	call printChar

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
