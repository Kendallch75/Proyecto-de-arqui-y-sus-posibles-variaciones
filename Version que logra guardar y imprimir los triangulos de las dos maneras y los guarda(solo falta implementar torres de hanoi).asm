.data
prompt:     .asciiz "Ingrese el número de filas: "
menu_prompt:.asciiz "\nMenu:\n1. Generar (Combinatorio)\n2. Generar (Iterativo)\n3. Imprimir\n4. Salir\nSeleccione opcion: "
space:      .asciiz " "
newline:    .asciiz "\n"
no_rows:    .asciiz "Primero debe generar el triangulo!\n"

.align 2
row_ptrs:   .space 400
num_rows:   .word 0

.text
.globl main

main:
    j menu  # Salto inicial explícito

menu:
    # Mostrar menú
    li $v0, 4
    la $a0, menu_prompt
    syscall

    # Leer opción
    li $v0, 5
    syscall
    move $s0, $v0

    # Manejar opción
    beq $s0, 1, generar_combinatorio
    beq $s0, 2, generar_iterativo
    beq $s0, 3, imprimir
    beq $s0, 4, salir
    j menu

generar_combinatorio:
    # Pedir filas
    li $v0, 4
    la $a0, prompt
    syscall
    li $v0, 5
    syscall
    sw $v0, num_rows

    # Inicializar
    li $t0, 0
    lw $t1, num_rows

loop_i_comb:
    bge $t0, $t1, volver_menu
    
    # Reservar memoria
    addi $a0, $t0, 1
    sll $a0, $a0, 2
    li $v0, 9
    syscall
    
    # Guardar puntero
    la $t2, row_ptrs
    sll $t3, $t0, 2
    addu $t2, $t2, $t3
    sw $v0, 0($t2)
    
    # Calcular valores
    li $t2, 1
    sw $t2, 0($v0)
    li $t3, 1

loop_k_comb:
    bgt $t3, $t0, next_i_comb
    
    sub $t4, $t0, $t3
    addiu $t4, $t4, 1
    mul $t2, $t2, $t4
    div $t2, $t3
    mflo $t2
    
    sll $t4, $t3, 2
    addu $t4, $v0, $t4
    sw $t2, 0($t4)
    
    addiu $t3, $t3, 1
    j loop_k_comb

next_i_comb:
    addiu $t0, $t0, 1
    j loop_i_comb

generar_iterativo:
    # Pedir filas
    li $v0, 4
    la $a0, prompt
    syscall
    li $v0, 5
    syscall
    sw $v0, num_rows

    # Inicializar
    li $t0, 0
    lw $t1, num_rows

loop_i_iter:
    bge $t0, $t1, volver_menu
    
    # Reservar memoria
    addi $a0, $t0, 1
    sll $a0, $a0, 2
    li $v0, 9
    syscall
    
    # Guardar puntero
    la $t2, row_ptrs
    sll $t3, $t0, 2
    addu $t2, $t2, $t3
    sw $v0, 0($t2)
    
    # Generar fila
    beqz $t0, primera_fila
    
    # Obtener fila anterior
    addi $t3, $t0, -1
    sll $t3, $t3, 2
    la $t4, row_ptrs
    addu $t4, $t4, $t3
    lw $t4, 0($t4)
    
    # Llenar fila
    li $t5, 0
    li $t6, 1

loop_j_iter:
    bgt $t5, $t0, next_i_iter
    
    beqz $t5, set_one
    beq $t5, $t0, set_one
    
    # Calcular valor
    addi $t7, $t5, -1
    sll $t7, $t7, 2
    addu $t7, $t4, $t7
    lw $t7, 0($t7)
    
    sll $t8, $t5, 2
    addu $t8, $t4, $t8
    lw $t8, 0($t8)
    
    addu $t6, $t7, $t8
    j guardar_valor

set_one:
    li $t6, 1

guardar_valor:
    sll $t7, $t5, 2
    addu $t7, $v0, $t7
    sw $t6, 0($t7)
    
    addiu $t5, $t5, 1
    j loop_j_iter

primera_fila:
    li $t3, 1
    sw $t3, 0($v0)

next_i_iter:
    addiu $t0, $t0, 1
    j loop_i_iter

imprimir:
    lw $t0, num_rows
    beqz $t0, error_sin_filas
    
    li $t1, 0

print_loop:
    bge $t1, $t0, volver_menu
    
    la $t2, row_ptrs
    sll $t3, $t1, 2
    addu $t2, $t2, $t3
    lw $t4, 0($t2)
    
    li $t5, 0

print_fila:
    bgt $t5, $t1, nueva_linea
    
    sll $t6, $t5, 2
    addu $t6, $t4, $t6
    lw $a0, 0($t6)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addiu $t5, $t5, 1
    j print_fila

nueva_linea:
    li $v0, 4
    la $a0, newline
    syscall
    
    addiu $t1, $t1, 1
    j print_loop

error_sin_filas:
    li $v0, 4
    la $a0, no_rows
    syscall

volver_menu:
    j menu  # Salto explícito de retorno

salir:
    li $v0, 10
    
