# NETSHITANGANI PHATHUTSHEDZO, NTSPHA021
# QUESTION 2

.data
    path_prompt: .asciiz "Enter a wave file name:\n"
    size_prompt: .asciiz "Enter the file size (in bytes):\n"
    infobar: .asciiz "Information about the wave file:\n================================\n"
    max_label: .asciiz "Maximum amplitude: "
    min_label: .asciiz "\nMinimum amplitude: "
    
    spaceforfilename: .space 300   # Allocate space for filename (max 300 bytes)
    
    .align 2  # Align the buffer 
    buffer: .space 2               # Reserve space for a 2-byte sample

.text
.globl main

main:
    # 1. Prompt the user for the wave file name
    li $v0, 4              
    la $a0, path_prompt      
    syscall
    
    # 2. Read the wave file name
    li $v0, 8               
    la $a0, spaceforfilename
    li $a1, 300             
    syscall
    
    # 3. Remove the newline character from the file name
    jal remove_newline_     
    
    # 4. Prompt the user for the file size
    li $v0, 4               
    la $a0, size_prompt      
    syscall
    
    # 5. Read the file size
    li $v0, 5              
    syscall
    move $s1, $v0           
    
    # 6. Open the wave file
    li $v0, 13              
    la $a0, spaceforfilename
    li $a1, 0               
    li $a2, 0               
    syscall
    move $s0, $v0          
    
    # 7. Skip the first 44 bytes (header)
    li $v0, 14              
    move $a0, $s0           
    la $a1, buffer          
    li $a2, 44              
    syscall
    
    # Initialize min and max values 
    li $t3, 32767           # Start min at the highest possible 16-bit value
    li $t4, -32768          # Start max at the lowest possible 16-bit value

audio_loop:
    # 8. Read 2 bytes (16 bits) for the next sample
    li $v0, 14              
    move $a0, $s0           
    la $a1, buffer          # Buffer to store the sample
    li $a2, 2               # Read 2 bytes (16 bits)
    syscall
    
    # Check for end of file
    beq $v0, 0, end_loop    # If no more bytes read, exit loop
    
    # 9. Load the 16-bit signed sample from the buffer
    lh $t5, 0($a1)          # Load the sample into $t5
    
    # 10. Compare and update minimum amplitude
    blt $t5, $t3, update_min
    j check_max
    
update_min:
    move $t3, $t5           # Update min amplitude
    
check_max:
    # 11. Compare and update maximum amplitude
    bgt $t5, $t4, update_max
    j audio_loop
    
update_max:
    move $t4, $t5  # Update max amplitude
    j audio_loop
    
end_loop:
    # 12. Close the file
    li $v0, 16     # Syscall to close file
    move $a0, $s0
    syscall
    
    # 13. Print the information about the wave file
    li $v0, 4               # Print infobar
    la $a0, infobar
    syscall
    
    # 14. Print max amplitude
    li $v0, 4  # Print label
    la $a0, max_label
    syscall
    
    li $v0, 1  # Print integer syscall
    move $a0, $t4 # Maximum amplitude
    syscall
    
    # 15. Print min amplitude
    li $v0, 4    # Print label
    la $a0, min_label
    syscall
    
    li $v0, 1      # Print integer syscall
    move $a0, $t3   # Minimum amplitude
    syscall
    
    # 16. Exit the program
    li $v0, 10
    syscall


# This function removes the newline character
remove_newline_:
    la $t0, spaceforfilename  # Load the address of the filename
    
remove_newline_loop:
    lb $t1, ($t0)             # Load byte at address in $t0
    beqz $t1, end_remove_newline  # If null terminator, end loop
    beq $t1, 10, remove_newline_char  # If newline, remove
    addi $t0, $t0, 1         # Increment address
    j remove_newline_loop     # Repeat loop
    
remove_newline_char:
    sb $zero, ($t0)           # Replace newline with null terminator
    j end_remove_newline       # Jump to end
    
end_remove_newline:
    jr $ra                    # Return from subroutine
