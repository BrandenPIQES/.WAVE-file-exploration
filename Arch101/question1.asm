# NETSHITANGANI PHATHUTSHEDZO, NTSPHA021
# QUESTION 1

.data
    path: .asciiz "Enter a wave file name:\n"
    size: .asciiz "Enter the file size (in bytes):\n"
    infobar: .asciiz "Information about the wave file:\n================================\n"
    channels: .asciiz "Number of channels: "
    samplerate: .asciiz "\nSample rate: "  
    byterate: .asciiz "\nByte rate: "      
    bitspersample: .asciiz "\nBits per sample: "
    
    spaceforfilename: .space 300  # space for filename 
    
    .align 2  # Align the buffer to a word boundary
    buffer: .space 44  # Reserve 44 bytes for the wave file header

.text    
.globl main

main:
    # 1. PROMPT FOR THE FILENAME
    li $v0, 4
    la $a0, path
    syscall
    
    # 2. READ THE FILENAME
    li $v0, 8
    la $a0, spaceforfilename
    li $a1, 300  # Limit to 300 bytes
    syscall
    
    # 3. REMOVE '\n' FROM THE FILENAME
    jal remove_newline_
    
    # 4. PROMPT FOR FILE SIZE
    li $v0, 4
    la $a0, size
    syscall
    
    # 5. READ THE FILE SIZE 
    li $v0, 5
    syscall  
    
    # 6. OPEN THE WAVE FILE IN READ-ONLY MODE
    li $v0, 13
    la $a0, spaceforfilename  
    li $a1, 0  # Read-only
    li $a2, 0  # default mode
    syscall
    move $s0, $v0  # Store file descriptor in $s0
    
    # 7. READ THE WAVE FILE HEADER INTO BUFFER
    li $v0, 14
    move $a0, $s0  # File descriptor in $a0
    la $a1, buffer # This is where the data from the header is stored!!!!!!!!!!!
    li $a2, 44     # Read 44 bytes (header size)
    syscall
    
    # 8. CLOSE THE FILE AFTER READING HEADER
    li $v0, 16
    move $a0, $s0  # File descriptor in $a0
    syscall
    
    # 9. PRINT INFO BAR
    li $v0, 4
    la $a0, infobar
    syscall
    
    # 10. PRINT NUM CHANNELS LABEL
    li $v0, 4
    la $a0, channels
    syscall
    
    # 11. LOAD AND PRINT THE NUMBER OF CHANNELS
    lh $t0, 22($a1)  # Load from buffer offset 22, 2 bytes
    li $v0, 1
    move $a0, $t0
    syscall
    
    # 12. PRINT SAMPLE RATE LABEL
    li $v0, 4
    la $a0, samplerate
    syscall
    
    # 13. LOAD AND PRINT THE SAMPLE RATE 
    lw $t0, 24($a1)  # Load from buffer offset 24, 4 bytes
    li $v0, 1
    move $a0, $t0
    syscall
    
    # 15. PRINT BYTE RATE LABEL
    li $v0, 4
    la $a0, byterate
    syscall
    
    # 15. LOAD AND PRINT THE BYTE RATE
    lw $t0, 28($a1)  # Load from buffer offset 28, 4 bytes
    li $v0, 1
    move $a0, $t0
    syscall
    
    # 16. PRINT BITS PER SAMPLE LABEL
    li $v0, 4
    la $a0, bitspersample
    syscall
    
    # 17. LOAD AND PRINT THE BITS PER SAMPLE
    lh $t0, 34($a1)  # Load from buffer offset 34, 2 bytes
    li $v0, 1
    move $a0, $t0
    syscall
    
    # 18. EXIT PROGRAM
    li $v0, 10
    syscall

# This function removes newline character
remove_newline_:
    la $t0, spaceforfilename  # Load the address of the filename
    
remove_newline_loop:
    lb $t1, ($t0)        # Load byte at address in $t0
    beqz $t1, end_remove_newline  # If null terminator, end loop
    beq $t1, 10, remove_newline_char  # If newline, remove
    addi $t0, $t0, 1    # Increment address
    j remove_newline_loop  # Repeat loop
    
remove_newline_char:
    sb $zero, ($t0)  # Replace newline with null terminator
    j end_remove_newline  # Jump to end
    
end_remove_newline:
    jr $ra  # Return 
