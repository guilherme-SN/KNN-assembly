
.data
	xtrainFile: 	.asciiz "xtrain.txt"	# Nome do arquivo xtrain
	linhaXtrain:	.word 0			# Variável para armazenar a quantidade de linhas do arquivo xtrain
	colunasX:	.word 0			# Espaço de memória para armazenar o número de elementos por coluna nos arquivos xtrain/xtest
	
	xtestFile:	.asciiz "xtest.txt"	# Nome do arquivo xtest
	linhaXtest:	.word 0			# Variável para armazenar a quantidade de linhas do arquivo xtest
	
	ytrainFile:	.asciiz "ytrain.txt"	# Nome do arquivo ytrain
	linhaYtrain:	.word 0			# Variável para armazenar a quantidade de linhas do arquivo ytrain
	
	ytestFile:	.asciiz "ytest.txt"	# Nome do arquivo ytest
	
	separador: 	.asciiz ","		# Variável que armazena o caractere ","
	quebra_linha: 	.asciiz "\n"		# Variável que armazena o caractere "\n"
	
	num_str:	.space 10		# Variável para armazenar o número que será convertido em float (10 Bytes --> número pode ter no máximo 10 dígitos incluindo o ponto)
	decimal:	.float 0.0		# Variável para armazenar a parte decimal do número a ser convertido
	
	k:		.word 1			# Valor K
	
	tamanho_menores_distancias: .word 0	# Variável para armazenar a quantidade de elementos no vetor de menores distâncias
	
	.align 2
	buffer: 	.space 102400	# Espaço de 100 Kbytes para armazenar arquivo máximo informado pelo professor
	
  	xtrain: 	.space 102400	# Espaço de 100 Kbytes para armazenar arquivo máximo informado pelo professor
	
  	xtest: 		.space 102400	# Espaço de 100 Kbytes para armazenar arquivo máximo informado pelo professor
  	
  	ytrain: 	.space 102400	# Espaço de 100 Kbytes para armazenar arquivo máximo informado pelo professor
  	
  	ytest: 		.space 102400	# Espaço de 100 Kbytes para armazenar arquivo máximo informado pelo professor
  
  	tamanho: 	.word 4		# Definição do tamanho de cada campo dos arrays de saída (float = 4 bytes)
  	
  
.text
.globl main
	
main:
	
	###################### XTRAIN ######################
	
	jal reseta_buffer
	
	# Chama a função leitor para o xtrain
	la $a0, xtrainFile
	jal leitor
	
	# Conta a quantidade de colunas (números) por linha
	# Como a quantidade de colunas é igual para xtrain e xtest, então esse valor será utilizado para ambos arquivos
	jal conta_coluna
	
	
	# Faz o cálculo do tamanho da linha do arquivo xtrain
	lw $t0, tamanho
	lw $t1, colunasX
	mul $t2, $t0, $t1	# Multiplica a quantidade de números por linha por 4 bytes (float), resultando no tamanho em bytes de cada linha
	
	
	# Chama a função separa_linha para o xtrain
	la $a0, xtrain
	move $a1, $t2		# $a1 representa o tamanho da linha para cada arquivo lido
				# No xtrain, cada linha possui 8 números de 4 bytes, ou seja, cada linha possui 32 bytes
	jal separa_linha
	
	
	# Salva a quantidade de linhas
	move $t3, $v0		# $v0 = linhas lidas
	la $t0, linhaXtrain
	sw $t3, 0($t0)
	
	
	
	###################### XTEST ######################
	
	jal reseta_buffer
	
	# Chama a função leitor para o xtest
	la $a0, xtestFile
	jal leitor
	
	
	# Chama a função separa_linha para o xtest
	la $a0, xtest
	move $a1, $t2		# $a1 representa o tamanho da linha para cada arquivo lido
				# Nesse arquivo, cada linha possui 8 números de 4 bytes, ou seja, cada linha possui 32 bytes
	jal separa_linha
	
	
	# Salva a quantidade de linhas
	move $t3, $v0		# $v0 = linhas lidas
	la $t0, linhaXtest
	sw $t3, 0($t0)

	
	###################### YTRAIN ######################
	
	jal reseta_buffer
	
	# Chama a função leitor para o xtest
	la $a0, ytrainFile
	jal leitor
	
	
	# Chama a função separa_linha para o ytrain
	la $a0, ytrain
	li $a1, 4		# $a1 representa o tamanho da linha para cada arquivo lido
				# Nesse arquivo, cada linha possui 1 número de 4 bytes, ou seja, cada linha possui 4 bytes
	jal separa_linha
	
	
	# Salva a quantidade de linhas
	move $t3, $v0	# $a1 = linhas lidas
	la $t0, linhaYtrain
	sw $t3, 0($t0)
	
	
	####################################################
	
	# Chama a função chama_knn para realizar o algoritmo KNN 
	jal chama_knn
	
	# Chama a função escritor para escrever o resultado em ytest.txt
	jal escritor
	
	# Termina o programa
	j saida_programa
	
	
# Função para ler um arquivo inteiro
#
# Parâmetros:
#	$a0 - Nome do arquivo
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
    	li $a1, 0           	# file_flag = read (0)
    	syscall
    	
    	move $s0, $v0        	# Salva o descritor do arquivo. $s0 = file
	
	
	# Leitura do arquivo
	li $v0, 14		# Código de serviço para ler o arquivo
	move $a0, $s0		# Descritor do arquivo
	la $a1, buffer  	# Buffer que armazenará TODO o arquivo
	la $a2, 102400		# Tamanho do buffer
	syscall
	

	# Fechamento do arquivo
    	li $v0, 16         	# Código de serviço para fechar o arquivo
    	move $a0, $s0      	# Descritor do arquivo
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


# Função para escrever no arquivo ytest.txt a partir do vetor ytest que contém a classificação de cada linha do xtest.txt
escritor:

	# Salva contexto
	subi $sp, $sp, 48
	sw $t0, 44($sp)
	sw $t1, 40($sp)
	sw $t2, 36($sp)
	sw $t3, 32($sp)
	sw $t4, 28($sp)
	sw $t5, 24($sp)
	sw $t6, 20($sp)
	sw $t7, 16($sp)
	sw $t8, 12($sp)
	sw $t9, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	# Abertura do arquivo
	li $v0, 13           	# Código de serviço para abrir o arquivo
 	la $a0, ytestFile	# Nome do arquivo
    	li $a1, 1           	# file_flag = write (1)
    	syscall

	move $t9, $v0		# Salva o descritor do arquivo
	
	jal reseta_buffer
	
	lw $t0, linhaXtest	# Carrega a quantidade de linhas para $t0
	li $t1, 0		# $t1 será o iterador do loop_escritor
	
	la $t2, ytest		# Carrega o endereço base do vetor ytest
	la $t5, buffer		# Carrega o endereço base do buffer
	
	lb $t6, quebra_linha	# Carrega o caractere "\n"
	
	li $t7, 0x2E		# Código ASCII para "."
	li $t8, 0x30		# Código ASCII para "0"
	
	
	loop_escritor:
		
		# Verifica se é o final do vetor ytest
		beq $t1, $t0, fim_loop_escritor
		
		# Multiplica o iterador por 4 e adiciona à base do vetor ytest para obter a posição correta
		sll $t3, $t1, 2
		add $t3, $t3, $t2
		
		# Carrega o valor atual de ytest[] para $t4
		lw $t4, 0($t3)
		
		# Faz a conversão de int para "caractere"
		addi $t4, $t4, 0x30	# 0x30 é o código ASCII para "0"
		
		# Salva o caractere correspondente a classificação da linha i do xtest no buffer
		sb $t4, 0($t5)
		
		
		# Adiciona ".0" em cada uma das linhas após incluir a classificação e pula linha
		addi $t5, $t5, 1
		sb $t7, 0($t5)		# Adiciona .
		
		addi $t5, $t5, 1
		sb $t8, 0($t5)		# Adiciona 0
				
		addi $t5, $t5, 1
		sb $t6, 0($t5)		# Adiciona \n
		
		
		# Atualiza o endereço do buffer e do iterador para a próxima posição
		addi $t5, $t5, 1
		addi $t1, $t1, 1
		
		j loop_escritor
		
	fim_loop_escritor:
	
		la $t5, buffer		# Carrega o endereço base do buffer
		
		mul $t0, $t0, 4		# Multiplica o número de linhas pela quantidade de caractere por linha (há 4 caracteres por linha "1" ou "0", ".", "0" e "\n")
					# dessa forma, resultando no número total de caracteres do ytest
		
		# Escrita no arquivo
		li $v0, 15		# Código de serviço para escrever no arquivo
		move $a0, $t9		# Descritor do arquivo
		move $a1, $t5		# Buffer de escrita
		move $a2, $t0		# Quantidade de caracteres a serem escritos no arquivo
		syscall
		
		
		# Fechamento do arquivo
    		li $v0, 16         	# Código de serviço para fechar o arquivo
    		move $a0, $t9
    		syscall
		
	
		# Recupera contexto
		lw $t0, 44($sp)
		lw $t1, 40($sp)
		lw $t2, 36($sp)
		lw $t3, 32($sp)
		lw $t4, 28($sp)
		lw $t5, 24($sp)
		lw $t6, 20($sp)
		lw $t7, 16($sp)
		lw $t8, 12($sp)
		lw $t9, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 48
		
		jr $ra


# Função para resetar o buffer (adicionar caractere nulo em todas as posições dele)
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
	
	
	la $t0, buffer		# Carrega o endereço base do buffer
	li $t1, 0		# Contador
	li $t2, 102400		# Tamanho do buffer
	li $t3, 0x0		# Carrega caractere nulo 
	
	
	loop_buffer:
		
		beq $t1, $t2, fim_loop_buffer	# Verifica se é o fim do buffer
		
		sb $t3, 0($t0)			# Armazena o caractere nulo na posição atual do buffer
		
		# Atualiza o contador e o endereço do buffer para a próxima posição
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
	

# Função para contar a quantidade de colunas (números) por linha e salva na variável colunasX
conta_coluna:

	# Salva contexto
	subi $sp, $sp, 32
	sw $t0, 28($sp)
	sw $t1, 24($sp)
	sw $t2, 20($sp)
	sw $t3, 16($sp)
	sw $t4, 12($sp)
	sw $t5, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	la $t0, buffer			# Carrega o endereço base do buffer
	
	lb $t1, quebra_linha		# Carrega "\n" para $t1
	lb $t2, separador		# Carrega "," para $t2	
	
	li $t4, 1			# Contador de elementos numa linha
	
	loop_conta_coluna:
	
		lb $t3, 0($t0)		# Carrega caractere atual
		
		bne $t3, $t2, else_conta_coluna	# Verifica se é o final do número
		addi $t4, $t4, 1			# Se for, então adiciona 1 na quantidade de colunas
		
		else_conta_coluna:
		
			beq $t3, $t1, fim_conta_coluna		# Verifica se é o final da linha
		
			addi $t0, $t0, 1		# Vai para o próximo caractere do buffer[]
		
			j loop_conta_coluna
	
	fim_conta_coluna:
	
		# Salva a quantidade de elementos na variável colunasX
		la $t5, colunasX
		sw $t4, 0($t5)		
	
	
		# Recupera contexto
		lw $t0, 28($sp)
		lw $t1, 24($sp)
		lw $t2, 20($sp)
		lw $t3, 16($sp)
		lw $t4, 12($sp)
		lw $t5, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 32
	
		jr $ra		# Retorna para o chamador


# Função que separa os números por linhas e já converte para float e armazena o resultado da conversão no vetor referenciado por $a0
# Parâmetros
#	$a0 - endereço base do vetor que irá salvar os números de cada linha convertidos para float
#	$a1 - tamanho da linha em bytes
#
# Retorno: $v0 - Retorna a quantidade de linhas convertidas
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
	move $t2, $a0			# Ponteiro para vetor[]
	la $t5, num_str			# Carrega o registrador que vai armazenar a string do número atual
	
	move $s1, $t2			# Faz uma copia do ponteiro para vetor[]
	
	
	loop_linha:
	
		lb $t3, 0($t1)		# Carrega caractere atual
		
		beqz $t3, saida_funcao		# Verifica se é o fim do arquivo
		
		beq $t3, $t4, fim_numero	# Verifica se é o final do número
		beq $t3, $t0, fim_linha		# Verifica se é o final da linha
		
		sb $t3, 0($t5)		# Armazena o caractere atual em num_str
		
		addi $t1, $t1, 1	# Atualiza para o próximo caractere em buffer[]
		addi $t5, $t5, 1	# Aponta para a próxima posição vazia em num_str
		
		j loop_linha
		
	fim_numero:
		
		sb $t3, 0($t5)		# Armazena "," no final para saber até onde o número vai
		addi $t1, $t1, 1	# Atualiza para o próximo caractere em buffer[]
		
		
		# Chama a função para converter o número de string (em num_str) para float
		jal string_to_float
		
		
		s.s $f0, 0($t2)		# Salva $f0 ("retorno" da função) no vetor[]
		addi $t2, $t2, 4	# Pula para próxima posição em vetor[]
		
		la $t5, num_str		# Volta para a posição inicial de num_str
		
		j loop_linha
		
	fim_linha:
		
		# Salva o último número da linha
		
		sb $t3, 0($t5)		# Armazena "\n" no final para saber até onde o número vai
		addi $t1, $t1, 1	# Vai para o próximo caractere em buffer[]
		
		jal string_to_float
		
		s.s $f0, 0($t2)		# Salva $f0 ("retorno" da função") no vetor[]
		addi $t2, $t2, 4	# Pula para próxima posição em vetor[]
		
		la $t5, num_str		# Volta para a posição inicial de num_str
		
		addi $t6, $t6, 1	# Adiciona 1 na quantidade de linhas
		
		
		# Avança para a posição da próxima linha
		add $s1, $s1, $a1	# Vai para a posição de memória que fica a próxima linha
		move $t2, $s1		# Atualiza o registrador de vetor[] para apontar para a nova linha
		
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


# Função para converter uma string armazenada em num_str para float
# Retorno: $f0 - Retorna o valor convertido para float
string_to_float:

	# Salva o contexto
	subi $sp, $sp, 32
	sw $t0, 28($sp)
	sw $t1, 24($sp)
	sw $t2, 20($sp)
	sw $t4, 16($sp)
	sw $t5, 12($sp)
	sw $t6, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp


	# Reseta a variável decimal e o registrador $f0
    	mtc1 $zero, $f0
    	s.s $f0, decimal
    	
    	
    	# Configuração inicial
    	la $t0, num_str				# Carrega string do número atual
    	lb $t1, separador			# Carrega ","
    	lb $t5, quebra_linha			# Carrega "\n"    	
    	
    	li $t2, 0  				# $t2 armazenará o número inteiro antes do ponto
    	l.s $f2, decimal  			# $f2 armazenará o número decimal após o ponto
    	
    	li $t4, 10  				# Fator de ajuste para os dígitos decimais
   
    	# Processa a parte inteira antes do ponto decimal
    	loop_int:
    	
        	lb $t6, 0($t0)  		# Carrega caractere atual
        	
        	beq $t6, $t1, fim_conversao		# Se encontrar "," termina
        	beq $t6, $t5, fim_conversao		# Se encontrar "\n", termina
        	beqz $t6, fim_conversao  		# Se encontrar o final da string, termina
        	
        	beq $t6, 0x2E, processa_decimal 	# 0x2E é o código ASCII para '.'
        	
       		sub $t6, $t6, 0x30  		# Converte o caractere ASCII para o valor numérico
        	mul $t2, $t2, $t4  		# Multiplica o valor atual por 10
        	add $t2, $t2, $t6  		# Adiciona o novo dígito
        	
        	addi $t0, $t0, 1  		# Avança para o próximo caractere
        	
        	j loop_int

	# Processa a parte decimal após o ponto decimal
    	processa_decimal:
    	
        	addi $t0, $t0, 1 		# Avança para o próximo caractere (após o ponto)

    		# Processa a parte decimal após o ponto
    		loop_dec:
    		
        		lb $t6, 0($t0)  	# Carrega o próximo caractere
        	
        	        beq $t6, $t1, fim_conversao	# Se encontrar "," termina
        		beq $t6, $t5, fim_conversao	# Se encontrar "\n", termina
        		beqz $t6, fim_conversao  	# Se encontrar o final da string, termina
        	
        		sub $t6, $t6, 0x30  	# Converte o caractere ASCII para o valor numérico
        	
        		mtc1 $t6, $f3		# Move o valor do dígito convertido para um registrador de ponto flutuante
        		mtc1 $t4, $f4		# Move o valor do fator de ajuste para um registrador de ponto flutuante
        	
        		div.s $f3, $f3, $f4	# Divide o dígito pelo fator de ajuste
        	
        		add.s $f2, $f2, $f3	# Adiciona o dígito decimal
        	
        		mul $t4, $t4, 10  	# Atualiza o fator de ajuste
        		addi $t0, $t0, 1  	# Avança para o próximo caractere
        	
        		j loop_dec

    		fim_conversao:
    		
        		mtc1 $t2, $f0  		# Move o valor inteiro para um registrador de ponto flutuante
        		cvt.s.w $f0, $f0  	# Converte o valor inteiro em ponto flutuante

       	 		add.s $f0, $f0, $f2	# Adiciona a parte decimal ao valor inteiro
       	 	
       	 		# Resultado fica armazenado em $f0

			# Recupera o contexto
			lw $t0, 28($sp)
			lw $t1, 24($sp)
			lw $t2, 20($sp)
			lw $t4, 16($sp)
			lw $t5, 12($sp)
			lw $t6, 8($sp)
			lw $ra, 4($sp)
			lw $fp, 0($sp)
			addi $sp, $sp, 32

        		jr $ra  	# Retorna ao chamador


# Função para criar um array com tamanho definido a partir do K e do tamanho de cada campo (float = 4 bytes)
# Retorno: $v0 - Endereço base do array criado
cria_array:

	# Salva o contexto
	subi $sp, $sp, 24
	sw $t0, 20($sp)
	sw $t1, 16($sp)
	sw $t2, 12($sp)
	sw $a0, 8($sp)
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
	lw $t0, 20($sp)
	lw $t1, 16($sp)
	lw $t2, 12($sp)
	lw $a0, 8($sp)
	lw $ra, 4($sp)
	lw $fp, 0($sp)
  	addi $sp, $sp, 24
  	
  	jr $ra		# Retorna ao chamador


# Função para selecionar uma linha do xtest e mandar para a função KNN
chama_knn:

	# Salva contexto
	subi $sp, $sp, 48
	sw $t0, 44($sp)
	sw $t1, 40($sp)
	sw $t2, 36($sp)
	sw $t3, 32($sp)
	sw $t4, 28($sp)
	sw $t5, 24($sp)
	sw $t6, 20($sp)
	sw $s0, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	# Criação dos arrays
	jal cria_array
	move $s2, $v0		# Salva o endereço do array de menores distâncias em $s2
	
	jal cria_array
	move $s3, $v0		# Salva o endereço do array das classificações das menores distâncias em $s3
	
	
	# Carrega dados
	la $t0, xtest		# Carrega vetor xtest[]
	la $t3, ytest		# Carrega vetor ytest[]
	lw $t4, linhaXtest	# Carrega quantidade de linhas do arquivo xtest
	lw $t5, colunasX	# Carrega quantidade de colunas do arquivo xtest/xtrain
	
	li $s0, 0		# Índice para percorrer as linhas em xtest
	loop_linhas_xtest:
		
		beq $s0, $t4, fim_loop_linhas_xtest	# Verifica se é o final do vetor xtest[]
	
		li $a0, 0		# Parâmetro contendo a quantidade de elementos no array de menores distâncias
		
		sll $t6, $t5, 2		# Multiplica a quantidade de colunas por 4 para resultar no tamanho em byte de cada linha
		mul $t1, $s0, $t6	# Multiplia o índice pelo tamanho da linha para encontrar o deslocamento de linhas no xtest
		add $t1, $t1, $t0	# Adiciona o deslocamento à base do vetor xtest[] para encontrar o endereço base da LINHA do xtest
		
		
		# Chama a função KNN para a linha atual do xtest
		la $a0, xtrain		# Endereço base do vetor xtrain que será percorrido inteiramente
		move $a1, $t1		# Endereço base da linha de xtest que será comparada com os valores em xtrain
		la $a2, ytrain		# Endereço base do vetor de classificação do xtrain
		lw $a3, k		# Valor K 
		jal knn
		
		# Adiciona classificação no ytest
		sll $t2, $s0, 2
		add $t2, $t2, $t3
		sw $v0, 0($t2)
		
		addi $s0, $s0, 1
		
		j loop_linhas_xtest
		
	fim_loop_linhas_xtest:
	
		# Recupera contexto
		lw $t0, 44($sp)
		lw $t1, 40($sp)
		lw $t2, 36($sp)
		lw $t3, 32($sp)
		lw $t4, 28($sp)
		lw $t5, 24($sp)
		lw $t6, 20($sp)
		lw $s0, 16($sp)
		lw $s2, 12($sp)
		lw $s3, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 48
	
		jr $ra


# Função para calcular distância euclidiana entre xtrain e xtest e selecionar as K menores distâncias
# Parâmetros
#	$a0 - float* xtrain (Endereço base do vetor xtrain)
#	$a1 - float* xtest (Endereço base da linha em xtest)
#	$a2 - float* ytrain (Endereço base do vetor de classificação do xtrain)
#	$a3 - int k
#
# Retorno: $v0 - Classificação da linha xtest
knn:
	# Salva o contexto
	subi $sp, $sp, 80
	sw $t0, 76($sp)
	sw $t1, 72($sp)
	sw $t2, 68($sp)
	sw $t3, 64($sp)
	sw $t4, 60($sp)
	sw $t5, 56($sp)
	sw $t6, 52($sp)
	sw $t7, 48($sp)
	sw $t8, 44($sp)
	sw $t9, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
  	move $fp, $sp
  	
  	
	# Carrega dados
	move $t0, $a0		# Move float* xtrain para $t0
	move $t1, $a1		# Move float* xtest para $t1
	move $t2, $a2		# Move float* ytrain para $t2

	lw $t3, colunasX	# Carrega a quantidade de colunas dos arquivos xtrain/xtest
	lw $t5, linhaXtrain	# Carrega a quantidade de linhas do arquivo xtrain

		
	sll $s6, $t3, 2		# Multiplica a quantidade de colunas por 4 para resultar no tamanho em byte de cada linha
	
	sw $zero, tamanho_menores_distancias	# Inicializa a varíavel tamanho_menores_distancias com 0	
	
	li $s1, 0	# Índice para percorrer as linhas em xtrain
	loop_linhas_xtrain:
		
		beq $s1, $t5, fim_loop_linhas_xtrain		# Verifica se já percorreu todas as linhas em xtrain
		
		li $t4, 0		# Índice para percorrer os valores (colunas) de cada linha
		mtc1 $zero, $f1		# Registrador para armazenar a diferença ao quadrado entre os atributos
	
		mtc1 $zero, $f0		# Distância
	
		loop_valores:
				
			beq $t4, $t3, fim_loop_valores		# Verifica se já percorreu todas as colunas
				
			# Carrega valor de xtest
			sll $t7, $t4, 2		# Multiplica o índice das colunas por 4 para encontrar o deslocamento na linha
			add $t6, $t1, $t7	# Soma esse deslocamento à base da linha em xtest para obter o valor na coluna $t4
				
			l.s $f2, 0($t6)		# Carrega valor presente em xtest no endereço calculado
			
			
			# Carrega valor de xtrain
			mul $t6, $s1, $s6	# Multiplica o índice das linhas em xtrain pelo tamanho da linha para obter o deslocamento de linhas em xtrain
			sll $t7, $t4, 2		# Multiplica o índice das colunas por 4 para encontrar o deslocamento na linha
			add $t6, $t6, $t7	# Soma o deslocamento de linhas com o deslocamento na linha para obter o deslocamento final
			add $t6, $t6, $t0	# Soma o deslocamento final à base do vetor xtrain[] para obter o valor da linha $s1 e coluna $t4 
				
			l.s $f1, 0($t6)		# Carrega o valor presente em xtrain no endereço calculado
				
			
			# Faz subtração e eleva ao quadrado
			sub.s $f1, $f2, $f1
			mul.s $f1, $f1, $f1
				
			# Soma resultado intermediário na distância
			add.s $f0, $f0, $f1
			
				
			# Atualiza índice das colunas
			addi $t4, $t4, 1
				
			j loop_valores
			
		fim_loop_valores:
		
			# Chama a função seleciona_menores para verificar se a distância calculada (em $f0) deverá ser armazenada ou descartada
			# Usa o valor em $f0 como parâmetro da distância
			lw $a0, tamanho_menores_distancias 	# Parâmetro que contém a quantidade de elementos no array de menores distâncias
			move $a1, $s1		# Parâmetro que contém o índice da linha de xtrain
			move $a2, $t2		# Parâmetro que contém o endereço do vetor ytrain
			move $a3, $s3		# Parâmetro que contém o endereço do vetor de classificações das menores distâncias
			jal seleciona_menores
			
			addi $s1, $s1, 1	# Atualiza índice das linhas em xtrain
			
			j loop_linhas_xtrain
		
	fim_loop_linhas_xtrain:
			
		# Avaliação da classificação dos K menores valores encontrados
		lw $t8, k		# Carrega o K
			
		li $s4, 0		# Armazena a quantidade de 0's
		li $s5, 0		# Armazena a quantidade de 1's
			
		mtc1 $zero, $f1		# Valor da classificação 0 para comparação
			
			
		li $t9, 0		# Iterador do loop_classifica
		loop_classifica:
			
			beq $t9, $t8, fim_loop_classifica	# Verifica se já percorreu todos os elementos do vetor das menores distâncias
				
			l.s $f0, 0($s3)		# Carrega o valor da classificação das menores distâncias
			
			# Verifica se a classificação é igual a 0
			c.eq.s $f0, $f1
			bc1f adiciona_1		# Se não for, então vai para adiciona_1
			
			# Senão:
			adiciona_0:
				
				addi $s4, $s4, 1	# Adiciona 1 na quantidade de 0's
				
				j fim_adiciona
				
			adiciona_1:
					
				addi $s5, $s5, 1	# Adiciona 1 na quantidade de 1's
					
			fim_adiciona:
					
				# Atualiza o iterador do loop e o endereço do vetor de classificação para o próximo elemento
				addi $s3, $s3, 4
				addi $t9, $t9, 1
					
				j loop_classifica
			
		fim_loop_classifica:
			
			# Verifica se a quantidade de 0 é maior que a quantidade de 1
			slt $t9, $s4, $s5
			bne $t9, $zero, retorna_1	# Se não for, então a classificação da linha xtest é 1
			
			# Senão:
			retorna_0:
				
				addi $v0, $zero, 0	# Atribui 0 na variável de retorno
					
				j fim_retorno
				
			retorna_1:
					
				addi $v0, $zero, 1	# Atribui 1 na variável de retorno
				
			fim_retorno:
				
				# Recupera o contexto
				lw $t0, 76($sp)
				lw $t1, 72($sp)
				lw $t2, 68($sp)
				lw $t3, 64($sp)
				lw $t4, 60($sp)
				lw $t5, 56($sp)
				lw $t6, 52($sp)
				lw $t7, 48($sp)
				lw $t8, 44($sp)
				lw $t9, 40($sp)
				lw $s0, 36($sp)
				lw $s1, 32($sp)
				lw $s2, 28($sp)
				lw $s3, 24($sp)
				lw $s4, 20($sp)
				lw $s5, 16($sp)
				lw $s6, 12($sp)
				lw $s7, 8($sp)
				lw $ra, 4($sp)
				lw $fp, 0($sp)
				addi $sp, $sp, 80
	
				jr $ra		# Retorna ao chamador


# Função que mantem as menores distâncias salvas
# Compara $f0 (distância a ser comparada) com o maior valor do vetor que armazena as menores distâncias
# Se esse vetor ainda não tiver K números, então o $f0 é apenas inserido
# Senão, se $f0 for menor que o maior valor do vetor, então $f0 entra no lugar do maior elemento
# Se não, $f0 é descartado
#
#
# Parâmetros
#	$f0 - distância a ser comparada com as menores distâncias armazenadas
#	$a0 - quantidade de elementos no vetor de menores distâncias armazenadas.
#	      se o vetor não estiver cheio, então $a0 também será o índice do vetor
#
#	$a1 - índice da linha em xtrain
#	$a2 - endereço do vetor ytrain contendo as classificações do xtrain
#	$a3 - endereço do vetor de classificações das menores distâncias armazenadas
seleciona_menores:
	
	# Salva o contexto
        subi $sp, $sp, 24
	sw $t0, 20($sp)
	sw $t1, 16($sp)
	sw $v0, 12($sp)
	s.s $f2, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	lw $t0, k	# $t0 armazenará o K, ou seja, quantos espaços tem o array de menores distâncias
	
	beq $a0, $t0, array_cheio	# Verifica se já usou todas as posições do array
	
	# Adiciona distância no array de menores distâncias	
	sll $t1, $a0, 2			# Multiplica o índice por 4 para obter o deslocamento em bytes
	add $t1, $t1, $s2		# Soma o deslocamento à base do array para obter a próxima posição livre do array
	s.s $f0, 0($t1)			# Salva a distância ($f0) na posição livre calculada
	
	
	# Recupera valor da classificação da linha xtrain
	sll $a1, $a1, 2			# Multiplica o índice da linha xtrain por 4 para obter o deslocamento em bytes
	add $a1, $a1, $a2		# Soma o deslocamento à base do array para obter a classificação de xtrain
	l.s $f1, 0($a1)			# Carrega a classificação 
	
	# Adiciona valor da classificação no array de classificação das menores distâncias
	sll $t1, $a0, 2			# Multiplica o índice por 4 para obter o deslocamento em bytes
	add $t1, $t1, $a3		# Soma o deslocamento à base do array para obter a posição correta
	s.s $f1, 0($t1)			# Salva a classificação no endereço calculado
	
	
	addi $a0, $a0, 1		# Adiciona 1 na quantidade de números inseridos no array
	sw $a0, tamanho_menores_distancias	# Atualiza a variável
	
	j fim_selecao
		
	array_cheio:
		
		# Chama a função retorna_endeco_maior para encontrar o endereço da maior distância presente no vetor de menores distâncias
		jal retorna_endereco_maior
		
		l.s $f2, 0($v0)		# Carrega a maior distância armazenada
		
		# Verifica se a distância calculada ($f0) é menor do que a maior distância armazenada 
		c.le.s $f0, $f2
		bc1t troca_menor	# Se for, então troca a maior distância por $f0
		
		# Senão:
		j fim_selecao
		
		troca_menor:
			
			s.s $f0, 0($v0)		# Salva a distância calculada na posição do maior elemento
			
			# Recupera a classificação da linha xtrain
			sll $a1, $a1, 2			# Multiplica o índice da linha xtrain por 4 para obter o deslocamento em bytes
			add $a1, $a1, $a2		# Soma o deslocamento à base do array para obter a posição correta
			l.s $f1, 0($a1)			# Carrega a classificação da linha xtrain
			
			# Adiciona a classificação da linha xtrain no array de classificação das menores distâncias na posição em que estava o maior elemento
			sll $t1, $v1, 2			# Multiplica o índice da posição do maior elemento do array por 4 para obter o deslocamento em bytes
			add $t1, $t1, $a3		# Soma o deslocamento à base do array para obter a posição correta
			s.s $f1, 0($t1)			# Salva a classificação da linha xtrain


			
	fim_selecao:
		
		# Recupera o contexto
		lw $t0, 20($sp)
		lw $t1, 16($sp)
		lw $v0, 12($sp)
		l.s $f2, 8($sp)
		lw $ra, 4($sp)
		lw $fp, 0($sp)
		addi $sp, $sp, 24
				
		jr $ra		# Retorna ao chamador


# Função para retornar o endereço da maior distância no array de menores distâncias
# Retorno:
#	$v0 - Retorna o endereço do maior valor
#	$v1 - Retorna o índice do maior valor
retorna_endereco_maior:
	
	# Salva o contexto
	subi $sp, $sp, 36
	sw $t0, 32($sp)
	sw $t1, 28($sp)
	sw $t2, 24($sp)
	sw $t3, 20($sp)
	sw $t4, 16($sp)
	s.s $f2, 12($sp)
	s.s $f5, 8($sp)
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	
	
	# Carrega dados
	lw $t0, k	# $t0 armazenará o K, ou seja, quantos espaços tem o array de menores distâncias
	l.s $f2, 0($s2)		# Carrega a primeira distância do array. $f2 armazenará o maior valor
	
	li $t2, 0	# $t2 armazenará o endereço da maior distância do array
	li $t4, 0	# $t4 será o índice do maior valor no array
	
	li $t1, 0	# $t1 será o indíce do array
	loop_maior:
		
		beq $t0, $t1, fim_loop_maior	# Verifica se já percorreu todo o array
	
	
		sll $t3, $t1, 2		# Multiplica o índice por 4 para obter o deslocamento em bytes		
		add $t3, $t3, $s2	# Adiciona o deslocamento à base do array para obter o endereço da próxima posição
		
		l.s $f5, 0($t3)		# Carrega a distância a partir do endereço calculado
		
		# Verifica se a maior distância é menor que a distância atual carregada
		c.le.s $f2, $f5
		bc1t troca_maior	# Se for, então troca a maior distância pela distância atual
		
		# Senão:
		addi $t1, $t1, 1	# Avança para a próxima posição
		
		j loop_maior
	
		troca_maior:
			
			move $t4, $t1	# Atualiza o maior índice
			move $t2, $t3	# Atualiza o endereço da maior distância
			mov.s $f2, $f5	# Atualiza o valor da maior distância
			
			addi $t1, $t1, 1	# Avança para a próxima posição
			
			j loop_maior
	
	fim_loop_maior:
	
			move $v0, $t2	# Retorna o endereço do maior valor
			move $v1, $t4	# Retorna o indice do maior valor
	
			# Recupera o contexto
			lw $t0, 32($sp)
			lw $t1, 28($sp)
			lw $t2, 24($sp)
			lw $t3, 20($sp)
			lw $t4, 16($sp)
			l.s $f2, 12($sp)
			l.s $f5, 8($sp)
			lw $ra, 4($sp)
			lw $fp, 0($sp)
			addi $sp, $sp, 36
			
			jr $ra		# Retorna ao chamador




saida_programa:

	li $v0, 10         # Código de serviço para sair
    	syscall
