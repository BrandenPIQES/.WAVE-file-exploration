# NETSHITANGANI PHATHUTSHEDZO, NTSPHA021
# QUESTION 3

.data
    path_prompt: .asciiz ""
    output_prompt: .asciiz ""
    size_prompt: .asciiz ""
    
    input_filename: .space 300   
    output_filename: .space 300  
    
    buffer: .space 2000         
    header: .space 44            # Buffer for the header (44 bytes)

.text
.globl main

main:
    # 1. Prompt the user for the input file name
    li $v0, 4               
    la $a0, path_prompt      
    syscall
    
    li $v0, 8               
    la $a0, input_filename
    li $a1, 300             
    syscall
    
    # Remove the newline character from the input file name
    jal remove_newline_input_file
    
    # 2. Prompt the user for the output file name
    li $v0, 4               
    la $a0, output_prompt    
    syscall
    
    li $v0, 8               
    la $a0, output_filename
    li $a1, 300            
    syscall
    
    # Remove the newline character from the output file name
    jal remove_newline_output_file
    
    # 3. Prompt for the file size
    li $v0, 4               
    la $a0, size_prompt     
    syscall
    
    li $v0, 5               
    syscall
    move $s1, $v0           # Store file size in $s1
    
    # 4. Open input file
    li $v0, 13              
    la $a0, input_filename   
    li $a1, 0               
    li $a2, 0               
    syscall
    move $s0, $v0           # Store input file descriptor in $s0
    
    
    # 5. Open output file
    li $v0, 13              
    la $a0, output_filename  # Load the output filename
    li $a1, 577               # Open to overwrite if exits or create if not there
    li $a2, 511               # permissions, read and execute
    syscall
    move $s2, $v0           # Store output file descriptor in $s2
    
    # 6. Read and copy the header (first 44 bytes)
    li $v0, 14              
    move $a0, $s0   # Input file descriptor
    la $a1, header     # Buffer for header
    li $a2, 44    # Read 44 bytes (header size)
    syscall
    
    # 7. Write the header to the output file
    li $v0, 15    # Syscall to write file
    move $a0, $s2    # Output file descriptor
    la $a1, header     # Buffer with the header
    li $a2, 44     # Write 44 bytes (header size)
    syscall
    
    # Calculate the number of audio samples
    sub $t0, $s1, 44  # Subtract header size from the total file size
    divu $t0, $t0, 2      # Divide by 2 to get the number of 2-byte samples
    move $t1, $t0       # Store the number of samples
    
    # 8. Read the entire audio data into the buffer
    li $v0, 14       # Syscall to read file
    move $a0, $s0  # Input file descriptor
    la $a1, buffer  # Buffer to hold audio data
    sub $a2, $s1, 44  # Size of audio data (file size - header size)
    syscall
    
    # 9. Write the audio data in reverse order
reverse_loop:
    blez $t1, end_reverse   # If no more samples, end loop
    
    # Calculate position of the last sample
    subu $t2, $t1, 1        # $t2 = index of the last sample
    mul $t2, $t2, 2         # Multiply by 2 (each sample is 2 bytes)
    
    # Write the sample from the buffer to the output file
    li $v0, 15        # Syscall to write file
    move $a0, $s2        # Output file descriptor
    la $a1, buffer($t2)    # Address of the last sample
    li $a2, 2    # Write 2 bytes (16 bits)
    syscall
    
    # Move to the previous sample
    subu $t1, $t1, 1  # Decrement the sample count
    j reverse_loop   # Repeat for the next sample
    
end_reverse:
    # 10. Close the files
    li $v0, 16    # Close input file syscall
    move $a0, $s0   # Input file descriptor
    syscall
    
    li $v0, 16  # Close output file syscall
    move $a0, $s2  # Output file descriptor
    syscall
    
    # 11. Exit the program
    li $v0, 10
    syscall

# Remove the newline character from the input filename
remove_newline_input_file:
    la $t0, input_filename  # Load the address of the input filename
    
remove_newline_input_loop:
    lb $t1, ($t0)      # Load byte at address in $t0
    beqz $t1, end_remove_newline_input  # If null terminator, end loop
    beq $t1, 10, remove_newline_input_char  # If newline, remove
    addi $t0, $t0, 1  # Increment address
    j remove_newline_input_loop  # Repeat loop
    
remove_newline_input_char:
    sb $zero, ($t0)    # Replace newline with null terminator
    j end_remove_newline_input  # Jump to end
    
end_remove_newline_input:
    jr $ra     # Return from subroutine


# Remove the newline character from the output filename
remove_newline_output_file:
    la $t0, output_filename  # Load the address of the output filename
    
remove_newline_output_loop:
    lb $t1, ($t0)    # Load byte at address in $t0
    beqz $t1, end_remove_newline_output  # If null terminator, end loop
    beq $t1, 10, remove_newline_output_char  # If newline, remove
    addi $t0, $t0, 1 # Increment address
    j remove_newline_output_loop  # Repeat loop
    
remove_newline_output_char:
    sb $zero, ($t0)  # Replace newline with null terminator
    j end_remove_newline_output     # Jump to end
    
end_remove_newline_output:
    jr $ra                  # Return from subroutine
