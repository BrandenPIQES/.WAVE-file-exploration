# NETSHITANGANI PHATHUTSHEDZO, NTSPHA021
# QUESTION 4

.data
    prompt_output_file: .asciiz ""
    prompt_tone_freq:   .asciiz ""
    prompt_sample_freq: .asciiz ""
    prompt_tone_length: .asciiz ""
    
    output_filename:    .space 300  

    header: .space 44             
    sample_high: .half 32767        # High value for square wave
    sample_low:  .half -32768       # Low value for square wave

.text
.globl main

main:
    # 1: Get output file path
    li $v0, 4                
    la $a0, prompt_output_file 
    syscall
    
    li $v0, 8                
    la $a0, output_filename   
    li $a1, 300            
    syscall
    
   
    jal remove_newline_output_file

    # 2: Get tone frequency
    li $v0, 4                 
    la $a0, prompt_tone_freq   
    syscall
    
    li $v0, 5                 
    syscall
    move $t0, $v0             # Store tone frequency in $t0
    
    # 3: Get sample frequency
    li $v0, 4                
    la $a0, prompt_sample_freq 
    syscall
    
    li $v0, 5                 
    syscall
    move $t1, $v0             # Store sample frequency in $t1
    
    # 4: Get tone length
    li $v0, 4                 
    la $a0, prompt_tone_length 
    syscall
    
    li $v0, 5                 
    syscall
    move $t2, $v0             # Store tone length in $t2

    # 5: Open output file
    li $v0, 13                
    la $a0, output_filename   
    li $a1, 577        # can write, create if not there
    li $a2, 511       # Permissions, all
    syscall
    move $s0, $v0             

    # 6: Write zeroed WAV header (44 bytes)
    li $v0, 15           # Syscall for writing to file
    move $a0, $s0             
    la $a1, header      # Buffer with zeros
    li $a2, 44        # Write 44 bytes
    syscall

    # 7: Calculate samples per wave period and total samples
    divu $t3, $t1, $t0   # t3 = sample_frequency / tone_frequency (samples per wave period)
    mflo $t3          # Store in $t3
    
    mul $t4, $t1, $t2    # t4 = sample_frequency * tone_length (total number of samples)

    # 8: Generate square wave (start with high state)
    li $t7, 0         # State flag (0 = high, 1 = low)
    li $t5, 0         # Sample counter

generate_square_wave:
    blez $t4, end_square_wave # If no more samples, end loop
    
    # Write high state
    beq $t7, 0, write_high   # If state flag is 0, write high
    j write_low          # Otherwise, write low
    
write_high:
    li $v0, 15               
    move $a0, $s0         # File descriptor
    la $a1, sample_high    # High state sample
    li $a2, 2        # Write 2 bytes
    syscall
    j next_sample

write_low:
    li $v0, 15               
    move $a0, $s0             
    la $a1, sample_low     # Low state sample
    li $a2, 2            # Write 2 bytes 
    syscall

next_sample:
    subu $t4, $t4, 1        # Decrement total samples
    addiu $t5, $t5, 1         # Increment sample counter

    # Switch state every half period
    divu $t6, $t3, 2      # Calculate half-period
    mflo $t6
    
    rem $t8, $t5, $t6         # Check if half-period is completed
    beq $t8, $zero, toggle_state # If half-period completed, toggle state
    
    j generate_square_wave

toggle_state:
    xori $t7, $t7, 1        # Toggle between 0 and 1
    j generate_square_wave

end_square_wave:
    # 9: Close file
    li $v0, 16          # Syscall to close file
    move $a0, $s0        # File descriptor
    syscall

    # 10: Exit program
    li $v0, 10
    syscall


remove_newline_output_file:
    la $t0, output_filename    # Load the output filename
remove_newline_loop:
    lb $t1, ($t0)              # Load byte
    beqz $t1, end_remove_newline # If null terminator, end
    beq $t1, 10, remove_char   
    addi $t0, $t0, 1           # Otherwise, move to next byte
    j remove_newline_loop      # Repeat loop

remove_char:
    sb $zero, ($t0)            # Replace newline with null terminator
    j end_remove_newline

end_remove_newline:
    jr $ra                     # Return from subroutine
