;;; Jake Herrmann
;;; CS 321 HW 1
;;; https://www.cs.uaf.edu/2019/spring/cs321/hw/hw1/

BITS 16

	mov ax, 0x0000
	mov es, ax
	mov BYTE [es:0x0000],'Z'
	mov BYTE cl, [es:0x0000]
	call printChar

printChar:
;;; Print the byte in cl to the upper left corner of the screen.
	push ax
	push es
	
	mov ax, 0xB800
	mov es, ax
	mov BYTE [es:0x0000], cl

	pop es
	pop ax

	ret

hang:
	jmp hang

times 510-($-$$) db 0  
	db 0x55
	db 0xaa
