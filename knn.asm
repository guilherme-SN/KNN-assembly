
.data
	xtrainFile: 	.asciiz "xtrain.txt"
	linhaXtrain:	.word 0
	
	xtestFile:	.asciiz "xtest.txt"
	linhaXtest:	.word 0
	
	ytrainFile:	.asciiz "ytrain.txt"
	linhaYtrain:	.word 0
	
	ytestFile:	.asciiz "ytest.txt"
	
	separador: 	.asciiz ","
	quebra_linha: 	.asciiz "\n"
	
	num_str:	.space 10
	decimal:	.float 0.0
	
	k:		.word 1
	
	.align 2
	buffer: 	.space 20480	# Espaço de 20480 bytes para armazenar até 20480 caracteres
	
  	xtrain: 	.space 32000	# Espaço de 32000 bytes para armazenar até 1000 linhas com 8 números de 4 bytes
	
  	xtest: 		.space 32000	# Espaço de 32000 bytes para armazenar até 1000 linhas com 8 números de 4 bytes
  	
  	ytrain: 	.space 4000	# Espaço de 32000 bytes para armazenar até 1000 linhas com 1 números de 4 bytes
  	
  	ytest: 		.space 4000	# Espaço de 32000 bytes para armazenar até 1000 linhas com 1 números de 4 bytes
  
  	tamanho: 	.word 4		# Definição do tamanho de cada campo dos arrays de saída (float = 4 bytes)
  
.text
.globl main
	
main:
	
	###### XTRAIN ######
	
	jal reseta_buffer
	
	la $a0, xtrainFile
	jal leitor
	
	
	la $a0, xtrain
	li $a1, 32		# $a1 representa o tamanho da linha para cada arquivo lido
				# Nesse arquivo, cada linha possui 8 números de 4 bytes, ou seja, cada linha possui 32 bytes
	jal separa_linha
	
	
	move $a1, $v0	# $a1 = linhas lidas
	subi $a1, $a1, 1
	
	la $t0, linhaXtrain
	sw $a1, 0($t0)
	
	#la $a0, xtrain
	#jal printa_dados
	
	
	###### XTEST ######
	
	jal reseta_buffer
	
	la $a0, xtestFile
	jal leitor
	
	
	la $a0, xtest
	li $a1, 32		# $a1 representa o tamanho da linha para cada arquivo lido
				# Nesse arquivo, cada linha possui 8 números de 4 bytes, ou seja, cada linha possui 32 bytes
	jal separa_linha
	
	
	move $a1, $v0	# $a1 = linhas lidas
	subi $a1, $a1, 1
	
	la $t0, linhaXtest
	sw $a1, 0($t0)

	
	#la $a0, xtest
	#jal printa_dados
	
	###### YTRAIN ######
	
	jal reseta_buffer
	
	la $a0, ytrainFile
	jal leitor
	
	
	la $a0, ytrain
	li $a1, 4		# $a1 representa o tamanho da linha para cada arquivo lido
				# Nesse arquivo, cada linha possui 1 número de 4 bytes, ou seja, cada linha possui 4 bytes
	jal separa_linha
	
	
	move $a1, $v0	# $a1 = linhas lidas
	subi $a1, $a1, 1
	
	la $t0, linhaYtrain
	sw $a1, 0($t0)
	
	
	#la $a0, ytrain
	#jal printa_dados
	
	jal knn
	
	jal printa_array
	
	jal escritor
	
	j saida_programa
	
	
printa_dados:
	
	move $t0, $a0	# Carrega matriz[] para $t0
	#la $t0, ytrain	# Carrega matriz[] para $t0
	
	move $t3, $t0	# Faz uma cópia desse endereço para $t3
	
	li $t1, 0	# Contador j (percorre linha)
	li $t2, 0	# Contador i (percorre coluna)
	
	li $t4, 8
	
	loop_print:
		
		beq $t1, $t4, muda_linha		# Se coluna == 
		beq $t2, $a1, saida_print	# Se linha == 
	
		lwc1 $f0, 0($t0)	# Carrega a palavra (número) para $f0
		
		li $v0, 2        	# Código de serviço para imprimir float
    		mov.s $f12, $f0     	# Carrega o número para impressão
    		syscall
    		
    		li $v0, 11		# Código de serviço para imprimir caractere
    		lb $a0, separador	# Carrega "," para impressão
    		syscall
    		
    		addi $t0, $t0, 4	# Vai para o próximo número (4 bytes a frente)
    		addi $t1, $t1, 1	# Adiciona 1 em j
    		
    		j loop_print
    		
    	muda_linha:
    	
    		addi $t3, $t3, 32	# Vai para a próxima linha
    		move $t0, $t3		# Copia esse endereço para o registrador que percorre a linha
    		
    		li $t1, 0		# Reseta j
    		addi $t2, $t2, 1	# Adiciona 1 em i
    		
    		li $v0, 11		# Código de serviço para imprimir caractere
    		lb $a0, quebra_linha	# Carrega "\n" para impressão
    		syscall
    		
    		j loop_print
    	
	saida_print:
	
		jr $ra		# Retorna ao chamador
		
		
printa_array:

	# Salva o contexto
	subi $sp, $sp, 40
	sw $t9, 36($sp)
	sw $t4, 32($sp)
	sw $a0, 28($sp)
	sw $t1, 24($sp)
	sw $t2, 20($sp)
	sw $t3, 16($sp)
	sw $v0, 12($sp)
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	li $t1, 0	# Índice do arrayTeste
	#lw $t2, k
	li $t2, 192
	
	#la $t9, ytrain
	la $t9, ytest
	
	a_loop_print:
		
		beq $t2, $t1, a_fim_loop_print
		
		
		sll $t3, $t1, 2
		#add $t4, $t3, $s3
		
		#add $t5, $t3, $s2
		
		add $t4, $t3, $t9
		
		li $v0, 1
		lw $a0, 0($t4)
		syscall
		
		#li $v0, 11
		#lb $a0, separador
		#syscall
		
		#li $v0, 2
		#l.s $f12, 0($t4)
		#syscall
		
		li $v0, 11		# Código de serviço para imprimir caractere
    		lb $a0, quebra_linha	# Carrega "\n" para impressão
    		syscall
		
		addi $t1, $t1, 1
		
		j a_loop_print
		
	a_fim_loop_print:
	
		li $v0, 11
		lb $a0, quebra_linha
		syscall
		li $v0, 11
		lb $a0, quebra_linha
		syscall
		
		# Recupera contexto
		lw $t9, 36($sp)
		lw $t4, 32($sp)
		lw $a0, 28($sp)
		lw $t1, 24($sp)
		lw $t2, 20($sp)
		lw $t3, 16($sp)
		lw $v0, 12($sp)
		lw $a0, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 40
	
		jr $ra
		

printa_array_class:

	# Salva o contexto
	subi $sp, $sp, 40
	sw $t9, 36($sp)
	sw $t4, 32($sp)
	sw $a0, 28($sp)
	sw $t1, 24($sp)
	sw $t2, 20($sp)
	sw $t3, 16($sp)
	sw $v0, 12($sp)
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	li $t1, 0	# Índice do arrayTeste
	lw $t2, k
	
	a_loop_print_class:
		
		beq $t2, $t1, a_fim_loop_print_class
		
		
		sll $t3, $t1, 2
		add $t4, $t3, $s3
		
		add $t5, $t3, $s2
		
		#add $t4, $t3, $t9
		
		li $v0, 2
		l.s $f12, 0($t5)
		syscall
		
		li $v0, 11
		lb $a0, separador
		syscall
		
		li $v0, 2
		l.s $f12, 0($t4)
		syscall
		
		li $v0, 11		# Código de serviço para imprimir caractere
    		lb $a0, quebra_linha	# Carrega "\n" para impressão
    		syscall
		
		addi $t1, $t1, 1
		
		j a_loop_print_class
		
	a_fim_loop_print_class:
	
		li $v0, 11
		lb $a0, quebra_linha
		syscall
		li $v0, 11
		lb $a0, quebra_linha
		syscall
		
		# Recupera contexto
		lw $t9, 36($sp)
		lw $t4, 32($sp)
		lw $a0, 28($sp)
		lw $t1, 24($sp)
		lw $t2, 20($sp)
		lw $t3, 16($sp)
		lw $v0, 12($sp)
		lw $a0, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 40
	
		jr $ra		
		

		
	
leitor:

	# Salva contexto
	subi $sp, $sp, 28
	sw $v0, 24($sp)
	sw $a0, 20($sp)
	sw $a1, 16($sp)
	sw $a2, 12($sp)
	sw $s0, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	
	# Abertura do arquivo
	li $v0, 13           	# Código de serviço para abrir o arquivo
    			   	# Nome do arquivo já está em $a0
    	#la $a0, ytrainFile     	# Pega o nome do arquivo
    	li $a1, 0           	# file_flag = read (0)
    	syscall
    	
    	move $s0,$v0        	# Salva o descritor do arquivo. $s0 = file
	
	
	# Leitura do arquivo
	li $v0, 14		# Código de serviço para ler o arquivo
	move $a0, $s0		# Descritor do arquivo
	la $a1, buffer  	# Buffer que armazenará TODO o arquivo
	la $a2, 20480		# hardcoded buffer length
	syscall
	

	# Fechamento do arquivo
    	li $v0, 16         	# Código de serviço para fechar o arquivo
    	move $a0,$s0      	# Descritor do arquivo
    	syscall
    	
    	
    	# Recupera contexto
	lw $v0, 24($sp)
	lw $a0, 20($sp)
	lw $a1, 16($sp)
	lw $a2, 12($sp)
	lw $s0, 8($sp)
	lw $ra, 4($sp)
	lw $fp, 0($sp)
    	addi $sp, $sp, 28
    	
	jr $ra


printa_buffer:
	
	#s contexto
	
	la $t0, buffer
	li $t1, 0
	
	loop_printa_buffer:
	
		beq $t1, 400, fim_loop_printa_buffer
		
		lb $t5, 0($t0)
		
		addi $t5, $t5, 1
		addi $t1, $t1, 1
		
		
	
	fim_loop_printa_buffer:
	
	#r contexto
	
		jr $ra


escritor:

	# Salva contexto
	subi $sp, $sp, 8
	#sw $v0, 24($sp)
	#sw $a0, 20($sp)
	#sw $a1, 16($sp)
	#sw $a2, 12($sp)
	#sw $s0, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	# Abertura do arquivo
	li $v0, 13           	# Código de serviço para abrir o arquivo
    			   	# Nome do arquivo já está em $a0
 	la $a0, ytestFile
    	li $a1, 1           	# file_flag = write (1)
    	syscall
    	
    	#move $a0, $v0
	move $t9, $v0
	
	jal reseta_buffer
	
	lw $t0, linhaXtest
	li $t1, 0
	
	la $t2, ytest
	la $t5, buffer
	
	lb $t6, quebra_linha
	
	li $t7, 0x2E	# Código ASCII para "."
	li $t8, 0x30	# Código ASCII para "0"
	
	
	loop_escritor:
		
		beq $t1, $t0, fim_loop_escritor
		
		sll $t3, $t1, 2
		add $t3, $t3, $t2
		
		lw $t4, 0($t3)
		
		addi $t4, $t4, 0x30
		
		sb $t4, 0($t5)
		
		#li $v0, 15
		#move $a1, $t5
		#li $a2, 1
		#syscall

		
		addi $t5, $t5, 1
		sb $t7, 0($t5)		# Adiciona .
		
		addi $t5, $t5, 1
		sb $t8, 0($t5)		# Adiciona 0
				
		addi $t5, $t5, 1
		sb $t6, 0($t5)		# Adiciona \n
		
		#li $v0, 15
		#move $a1, $t5
		#li $a2, 1
		#syscall
		
		addi $t5, $t5, 1
		addi $t1, $t1, 1
		
		j loop_escritor
		
	fim_loop_escritor:
	
		li $t7, 0
		sb $t7, 0($t5)
		
		la $t5, buffer
		
		mul $t0, $t0, 4		# Multiplica o número de linhas pela quantidade de caractere por linha
					# dessa forma, resultando no número total de caracteres do ytest
		
		li $v0, 15
		# a0 ja contem end
		move $a0, $t9
		move $a1, $t5
		#li $a2, 1000		# ALTERTAR PARA O NÚMERO EXATO DE CARACTERES DO YTEST
		move $a2, $t0
		syscall
		
		# Fechamento do arquivo
    		li $v0, 16         	# Código de serviço para fechar o arquivo
    		#move $a0,$s0      	# Descritor do arquivo
    		move $a0, $t9
    		syscall
		
	
		# Recupera contexto
		
		#sw $v0, 24($sp)
		#sw $a0, 20($sp)
		#sw $a1, 16($sp)
		#sw $a2, 12($sp)
		#sw $s0, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 8
		
		jr $ra

	
reseta_buffer:
	
	# Salva o contexto
	subi $sp, $sp, 24
	sw $t0, 20($sp)
	sw $t1, 16($sp)
	sw $t2, 12($sp)
	sw $t3, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	la $t0, buffer
	li $t1, 0	# Contador
	li $t2, 20480	# Tamanho do buffer
	li $t3, 0x0	# Carrega caractere nulo 
	
	loop_buffer:
		
		beq $t1, $t2, fim_loop_buffer	# Verifica se é o fim do buffer
		
		sb $t3, 0($t0)		# Armazena o caractere nulo na posição atual do buffer
		
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		
		j loop_buffer
		
	fim_loop_buffer:
	
		# Recupera o contexto
		lw $t0, 20($sp)
		lw $t1, 16($sp)
		lw $t2, 12($sp)
		lw $t3, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 24
		
		jr $ra
	
	
separa_linha:

	# Salva contexto
	subi $sp, $sp, 40
	sw $t0, 36($sp)
	sw $t1, 32($sp)
	sw $t2, 28($sp)
	sw $t3, 24($sp)
	sw $t4, 20($sp)
	sw $t5, 16($sp)
	sw $t6, 12($sp)
	sw $s1, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	# Configuração inicial
	lb $t0, quebra_linha		# Carrega "\n" para $t0
	lb $t4, separador		# Carrega "," para $t4	
	
	li $t6, 0			# Contador de linhas

	la $t1, buffer			# Ponteiro para buffer[]
	move $t2, $a0			# Ponteiro para matriz[]
	#la $t2, ytrain
	la $t5, num_str			# Carrega o registrador que vai armazenar a string do número atual
	
	move $s1, $t2			# Faz uma copia do ponteiro para matriz[]
	
	loop_linha:
	
		lb $t3, 0($t1)		# Carrega caractere atual
		
		beqz $t3, saida_funcao		# Verifica se é o fim do arquivo
		beq $t3, $t4, fim_numero	# Verifica se é o final do número
		beq $t3, $t0, fim_linha		# Verifica se é o final da linha
		
		sb $t3, 0($t5)		# Armazena o caractere atual em num_str
		
		addi $t1, $t1, 1	# Vai para o próximo caractere em buffer[]
		addi $t5, $t5, 1	# Aponta para a próxima posição vazia em num_str
		
		j loop_linha
		
	fim_numero:
		
		sb $t3, 0($t5)		# Armazena "," no final para saber até onde o número vai
		addi $t1, $t1, 1	# Vai para o próximo caractere em buffer[]
		
		jal string_to_float
		
		s.s $f0, 0($t2)		# Salva $f0 ("retorno" da função) no array matriz[]
		addi $t2, $t2, 4	# Pula para próxima posição em matriz[]
		
		la $t5, num_str		# Volta para a posição inicial de num_str
		
		j loop_linha
		
		
	fim_linha:
		
		# Salva o último número da linha
		sb $t3, 0($t5)		# Armazena "\n" no final para saber até onde o número vai
		addi $t1, $t1, 1	# Vai para o próximo caractere em buffer[]
		
		jal string_to_float
		
		s.s $f0, 0($t2)		# Salva $f0 ("retorno" da função") no array matriz[]
		addi $t2, $t2, 4	# Pula para próxima posição em matriz[]
		
		la $t5, num_str		# Volta para a posição inicial de num_str
		
		addi $t6, $t6, 1	# Adiciona 1 na quantidade de linhas
		
		# Avança para a posição da próxima linha
		add $s1, $s1, $a1	# Vai para a posição de memória que fica a próxima linha
					
		move $t2, $s1		# Atualiza o registrador de matriz[] para apontar para a nova linha
		
		j loop_linha
		
	saida_funcao:
	
		move $v0, $t6		# Retorna a quantidade de linhas convertidas
	
		# Recupera contexto
		lw $t0, 36($sp)
		lw $t1, 32($sp)
		lw $t2, 28($sp)
		lw $t3, 24($sp)
		lw $t4, 20($sp)
		lw $t5, 16($sp)
		lw $t6, 12($sp)
		lw $s1, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 40
		
		jr $ra		# Retorna ao chamador


# Função para converter string para float
string_to_float:

	# Salva o contexto
	subi $sp, $sp, 36
	sw $t0, 32($sp)
	sw $t1, 28($sp)
	sw $t2, 24($sp)
	sw $t4, 20($sp)
	sw $t5, 16($sp)
	sw $t6, 12($sp)
	sw $t0, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

    	# Configuração inicial
    	la $t0, num_str				# Carrega string do número atual
    	lb $t1, separador			# Carrega ","
    	lb $t5, quebra_linha			# Carrega "\n"
    	
    	# Reseta a variável decimal e o registrador $f0
    	mtc1 $zero, $f0
    	s.s $f0, decimal
    	
    	li $t2, 0  				# $t2 armazenará o número inteiro antes do ponto
    	l.s $f2, decimal  			# $f2 armazenará o número decimal após o ponto
    	
    	li $t4, 10  				# Fator de ajuste para os dígitos decimais
   
    	# Processa a parte inteira antes do ponto decimal
    	loop_int:
        	lb $t6, 0($t0)  		# Carrega caractere
        	
        	beq $t6, $t1, done		# Se encontrar "," termina
        	beq $t6, $t5, done		# Se encontrar "\n", termina
        	beqz $t6, done  		# Se encontrar o final da string, termina
        	
        	beq $t6, 0x2E, processa_decimal # 0x2E é o código ASCII para '.'
        	
       		sub $t6, $t6, 0x30  		# Converte o caractere ASCII para o valor numérico
        	mul $t2, $t2, $t4  		# Multiplica o valor atual por 10
        	add $t2, $t2, $t6  		# Adiciona o novo dígito
        	
        	addi $t0, $t0, 1  		# Avança para o próximo caractere
        	
        	j loop_int

    	processa_decimal:
        	addi $t0, $t0, 1 		# Avança para o próximo caractere (após o ponto)

    		# Processa a parte decimal após o ponto
    		loop_dec:
        		lb $t6, 0($t0)  	# Carrega o próximo caractere
        	
        	        beq $t6, $t1, done	# Se encontrar "," termina
        		beq $t6, $t5, done	# Se encontrar "\n", termina
        		beqz $t6, done  	# Se encontrar o final da string, termina
        	
        		sub $t6, $t6, 0x30  	# Converte o caractere ASCII para o valor numérico
        	
        		mtc1 $t6, $f3		# Move o valor do dígito convertido para um registrador de ponto flutuante
        		mtc1 $t4, $f4		# Move o valor do fator de ajuste para um registrador de ponto flutuante
        	
        		div.s $f3, $f3, $f4	# Divide o dígito pelo fator de ajuste
        	
        		add.s $f2, $f2, $f3	# Adiciona o dígito decimal
        	
        		mul $t4, $t4, 10  	# Atualiza o fator de ajuste
        		addi $t0, $t0, 1  	# Avança para o próximo caractere
        	
        		j loop_dec

    		done:
        		mtc1 $t2, $f0  		# Move o valor inteiro para um registrador de ponto flutuante
        		cvt.s.w $f0, $f0  	# Converte o valor inteiro em ponto flutuante

       	 		add.s $f0, $f0, $f2	# Adiciona a parte decimal ao valor inteiro
       	 	
       	 		# Resultado fica armazenado em $f0

			# Recupera o contexto
			lw $t0, 32($sp)
			lw $t1, 28($sp)
			lw $t2, 24($sp)
			lw $t4, 20($sp)
			lw $t5, 16($sp)
			lw $t6, 12($sp)
			lw $t0, 8($sp)
			lw $ra, 4($sp)
			lw $fp, 0($sp)
			addi $sp, $sp, 36

        		jr $ra  		# Retorna ao chamador


cria_array:

	# Salva o contexto
	subi $sp, $sp, 24
	sw $t2, 20($sp)
	sw $a0, 16($sp)
	sw $t0, 12($sp)
	sw $t1, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
  	lw $t0, k		# Carrega k
  	lw $t1, tamanho		# Carrega tamanho

  	mul $t2, $t0, $t1	# Calcula o total de bytes a ser alocado

 	li $v0, 9	# Código para alocação de memória (sbrk)
  	move $a0, $t2	# Carrega o número de bytes a ser alocado
 	syscall
 	
  	# Endereço de memória alocado estará em $v0
  	
  	
  	# Recupera o contexto
	lw $t2, 20($sp)
	lw $a0, 16($sp)
	lw $t0, 12($sp)
	lw $t1, 8($sp)
	lw $ra, 4($sp)
	lw $fp, 0($sp)
  	addi $sp, $sp, 24
  	
  	jr $ra


# Função para calcular distância euclidiana entre xtrain e xtest e selecionar as K menores distâncias
knn:
	# Salva o contexto
	addi $sp, $sp, 8
	sw $ra, 4($sp)
	sw $fp, 0($sp)
  	move $fp, $sp
  	
	
	# Criação dos arrays
	jal cria_array
	move $s2, $v0		# Salva o endereço do array de menores distâncias em $s2
	
	
	jal cria_array
	move $s3, $v0		# Salva o endereço do array das classificações das menores distâncias em $s3
	
	# Carrega dados
	la $t0, xtrain
	la $t1, xtest
	la $t2, ytrain
	la $s6, ytest
	lw $t3, linhaXtest
	lw $t5, linhaXtrain
	
	
	
	
	li $s0, 0		# Índice para percorrer as linhas em xtest
	loop_linhas_xtest:
		
		beq $s0, $t3, fim_loop_linhas_xtest
	
		li $a0, 0	# Parâmetro contendo a quantidade de elementos no array de menores distâncias
		
		li $s1, 0	# Índice para percorrer as linhas em xtrain
		loop_linhas_xtrain:
		
			beq $s1, $t5, fim_loop_linhas_xtrain
		
			li $t4, 0	# Índice para percorrer os atributos dos arquivos
			mtc1 $zero, $f1	# Registrador para armazenar a diferença ao quadrado entre os atributos
	
			mtc1 $zero, $f0		# Distância
	
			loop_valores:
				
				beq $t4, 8, fim_loop_valores
				
				# Carrega xtest[$s0][$t5]
				mul $t6, $s0, 32	# linha * 32 = end_linha 
				sll $t7, $t4, 2		# coluna * 4 = end_coluna
				add $t6, $t6, $t7	# end = end_linha + end_coluna
				add $t6, $t6, $t1	# end_final = end + base_array
				
				l.s $f2, 0($t6)
			
				# Carrega xtrain[$s1][$t5]
				mul $t6, $s1, 32	# linha * 32 = end_linha 
				sll $t7, $t4, 2		# coluna * 4 = end_coluna
				add $t6, $t6, $t7	# end = end_linha + end_coluna
				add $t6, $t6, $t0	# end_final = end + base_array
				
				l.s $f1, 0($t6)
				
				# Imprime
				#li $v0, 2
				#mov.s $f12, $f2
				#syscall
				
				#li $v0, 11
				#lb $a0, separador
				#syscall
				
				#li $v0, 2
				#mov.s $f12, $f1
				#syscall
				
				#li $v0, 11
				#lb $a0, quebra_linha
				#syscall
				
				# Faz subtração e eleva ao quadrado
				sub.s $f1, $f2, $f1
				mul.s $f1, $f1, $f1
				
				# Soma resultado intermediário na distância
				add.s $f0, $f0, $f1
				
				
				
				# Atualiza índice
				addi $t4, $t4, 1
				
				j loop_valores
			
			fim_loop_valores:
			
				
				# Impressão
				#li $v0, 11
				#lb $a0, quebra_linha
				#syscall
				
				#li $v0, 2
				#mov.s $f12, $f0
				#syscall
				
				#li $v0, 11
				#lb $a0, quebra_linha
				#syscall
				
				
				# Usa o valor em $f0 como parâmetro da distância
				# Usa o valor em $a0 como parâmetro da quantidade de elementos no array de menores distâncias
				move $a1, $s1		# Parâmetro que contém a linha de xtrain
				move $a2, $t2		# Parâmetro que contém o endereço do array ytrain
				move $a3, $s3		# Parâmetro que contém o endereço do array de classificações das menores distâncias
				jal seleciona_menores
			
				addi $s1, $s1, 1
			
				j loop_linhas_xtrain
		
		fim_loop_linhas_xtrain:
			
			# Avaliação da classificação dos K menores valores
			lw $t7, k
			
			li $s4, 0		# Armazena a quantidade de 0's
			li $s5, 0		# Armazena a quantidade de 1's
			
			mtc1 $zero, $f1		# Valor da classificação 0 para comparação
			
			
			li $t9, 0
			loop_classifica:
			
				beq $t9, $t7, fim_loop_classifica
				
				l.s $f0, 0($s3)
				
				c.eq.s $f0, $f1
				bc1f adiciona_1
				
				adiciona_0:
				
					addi $s4, $s4, 1
					
					j fim_adiciona
				
				adiciona_1:
					
					addi $s5, $s5, 1
					
				fim_adiciona:
					
					addi $s3, $s3, 4
					addi $t9, $t9, 1
					
					j loop_classifica
			
			fim_loop_classifica:
			
				slt $t9, $s4, $s5
				bne $t9, $zero, retorna_1
				
				retorna_0:
				
					addi $v0, $zero, 0
					
					j fim_retorno
				
				retorna_1:
					
					addi $v0, $zero, 1
				
				fim_retorno:
				
					# Adiciona classificação no ytest
					sll $t9, $s0, 2
					add $t9, $t9, $s6
					sw $v0, 0($t9)
			
					addi $s0, $s0, 1
			
					j loop_linhas_xtest
		
	fim_loop_linhas_xtest:
	
		# Recupera o contexto
		lw $ra, 4($sp)
		lw $fp, 0($sp)
  		subi $sp, $sp, 8
	
		jr $ra		# Retorna ao chamador


# Função para selecionar os menores
# Vai comparar $f0 (distância a ser comparada) com o maior valor do array
# Se o array ainda não tiver K números, então o $f0 é apenas inserido
# Se $f0 for menor que o maior valor do array, então $f0 entra no lugar dele
# Se não, $f0 é descartado
seleciona_menores:
	
	# Salva o contexto
	subi $sp, $sp, 36
	sw $t5, 32($sp)
	sw $v0, 28($sp)
	sw $t0, 24($sp)
	sw $t1, 20($sp)
	s.s $f2, 16($sp)
	sw $t3, 12($sp)
	sw $t4, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	lw $t1, k	# $t1 armazenará o K, ou seja, quantos espaços tem o array final
	
	beq $a0, $t1, array_cheio	# Verifica se já usou todas as posições do array
		
	sll $t3, $a0, 2			# Multiplica o índice por 4
	add $t3, $t3, $s2		# Soma à base do array (para dar a posição livre)
	s.s $f0, 0($t3)			# Salva $f0 na posição livre calculada
	
	# Adiciona valor da classificação no arrayClassificação
	sll $a1, $a1, 2			# Multiplica o índice por 4
	add $a1, $a1, $a2		# Soma à base do array
	l.s $f1, 0($a1)			# Carrega a classificação 
	
	sll $t3, $a0, 2			# Multiplica o índice por 4
	add $t3, $t3, $a3		# Soma à base do array
	s.s $f1, 0($t3)			# Salva a classificação 
	
	#jal printa_array_class
	
	addi $a0, $a0, 1		# Adiciona 1 na quantidade de números inseridos no array
	
	j fim_selecao
		
	array_cheio:
	
		jal retorna_endereco_maior
		
		l.s $f2, 0($v0)
		
		c.le.s $f0, $f2
		bc1t troca_menor
		
		j fim_selecao
		
		troca_menor:
			
			s.s $f0, 0($v0)
			
			# Trocar array de classificação
			sll $a1, $a1, 2			# Multiplica o índice por 4
			add $a1, $a1, $a2		# Soma à base do array
			l.s $f1, 0($a1)			# Carrega a classificação 
			
			sll $t3, $v1, 2
			add $t3, $t3, $a3
			s.s $f1, 0($t3)
			
			#jal printa_array_class
			
			# Impressão
			#move $t5, $a0
			
			#li $v0, 1
			#move $a0, $v1
			#syscall
			
			#li $v0, 11		# Código de serviço para imprimir caractere
    			#lb $a0, separador	# Carrega "\n" para impressão
    			#syscall
			
			#li $v0, 2
			#mov.s $f12, $f1
			#syscall
			
			
			#li $v0, 11		# Código de serviço para imprimir caractere
    			#lb $a0, quebra_linha	# Carrega "\n" para impressão
    			#syscall
    			
			
			#move $a0, $t5
		
	fim_selecao:
		
		# Recupera o contexto
		lw $t5, 32($sp)
		lw $v0, 28($sp)
		lw $t0, 24($sp)
		lw $t1, 20($sp)
		l.s $f2, 16($sp)
		lw $t3, 12($sp)
		lw $t4, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 36
				
		jr $ra		# Retorna ao chamador


# Função para retornar o endereço do maior número no array
retorna_endereco_maior:
	
	# Salva o contexto
	subi $sp, $sp, 40
	sw $t7, 36($sp)
	sw $t0, 32($sp)
	sw $t1, 28($sp)
	s.s $f2, 24($sp)
	sw $t3, 20($sp)
	sw $t4, 16($sp)
	s.s $f5, 12($sp)
	sw $t6, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	lw $t0, k	# $t0 armazenará o K, ou seja, quantos espaços tem o array final
	li $t1, 0	# $t1 será o indíce do array (i)
	li $t7, 0	# $t7 será o índice do maior valor no array
	
	#l.s $f2, 0($s0)	# Carrega a primeira posição do array. $f2 armazenará o maior valor
	l.s $f2, 0($s2)		# Carrega a primeira posição do array. $f2 armazenará o maior valor
	
	
	move $t3, $s0	# $t3 armazenará o endereço do maior valor
	
	loop_maior:
		
		beq $t0, $t1, fim_loop_maior	# Verifica se já percorreu todas as posições
	
	
		sll $t4, $t1, 2		# Multiplica o índice por 4
		
		#add $t4, $t4, $s0	# Adiciona à base do array
		add $t4, $t4, $s2	# Adiciona à base do array
		
		l.s $f5, 0($t4)		# Carrega o valor do índice
		
		c.le.s $f2, $f5
		bc1t troca_maior
		
		addi $t1, $t1, 1	# Avança para a próxima posição
		
		j loop_maior
	
		troca_maior:
			
			move $t7, $t1	# Armazena o maior índice
			move $t3, $t4	# Armazena $t4 em $t3
			mov.s $f2, $f5	# Carrega o maior valor
			
			addi $t1, $t1, 1	# Avança para a próxima posição
			
			j loop_maior
	
	fim_loop_maior:
	
			move $v0, $t3	# Retorna o endereço do maior valor
			move $v1, $t7	# Retorna o indice do maior valor
	
			# Recupera o contexto
			lw $t7, 36($sp)
			lw $t0, 32($sp)
			lw $t1, 28($sp)
			l.s $f2, 24($sp)
			lw $t3, 20($sp)
			lw $t4, 16($sp)
			l.s $f5, 12($sp)
			lw $t6, 8($sp)
			lw $ra, 4($sp)
			lw $fp, 0($sp)
			addi $sp, $sp, 40
			
			jr $ra		# Retorna ao chamador


saida_programa:

	li $v0, 10         # Código de serviço para sair
    	syscall
