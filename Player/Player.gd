extends KinematicBody2D
#__________________________________________________________#
#------------------Constantes------------------------------#
const GRAVITY = 1500 #Gravidade
var gravidade = null
#__________________________________________________________#
var Level = 1 #Level do Player
#__________________________________________________________#
var controleDash = 0 #Controlede de DASH
var dashTimer = 0.1 #Tempo de duração do DASH
#__________________________________________________________#
#Velocidade Variaveis e direção
var speed = 150 #Velocidade
var vel = Vector2() #Velocidade do Player
var dir = 0 #Localização de direção do sprite se a direita ou esquerda
#__________________________________________________________________#
#-----------------------Pulos Variaveis----------------------------#
var jumpTwo = false #Pulo Duplo
var jumpForce = -500 #Força de pulo
#__________________________________________________________________#
#---------------Variaveis de Habilidade----------------------------#
var hab1 = 1 #Pulo Duplo#-------------#
var hab2 = 1 #Dash#-------------------#
var hab3 = 1 #Corrida#----------------#
#var hab4 = 1
#var hab5 = 1
#var hab6 = 1
#------------------Lista de Variaveis de Atributos-----------#
#--------------Stamina e controles---------------------------#
var stamina = 50 #Quantidade de Stamina Inicial e controle da mesmo
var staminaTimer = 5 #Tempo de recuperação de Stamina Inicial 
var staminaRec = 0
var staminaRecOn = false
#____________________________________________________________#
#------------------Variaveis Vitalidade----------------------#

var baseHp = 1 #Hp inicial do player
var vitalidade = 1 #Vitalidade Inicial do player
var deffis = 1 #Defesa fisica inicial do player

# -------------- Ataque Variaveis e combo --------------------#

var combo = 1 #Contagem de golpes para controle de animação
var atackAnim = null #Variavel que substitui a chamada de animação
var attack = false #Controle para liberação de timer do ataque
var timerAttack = 0.8 #Valor de timer do Ataque

# -------------------Special Moves---------------------------#
var specialMoveTimer = 0.3
var esquivaMove = 0
var esquivaAnim = null

func _physics_process(delta):
	#---------Mudanças de Variaveis-----------------------------#
	atackAnim = "Atack" + str(combo) + "Dir" + str(dir)
	esquivaAnim = "EsquivaDir" + str(dir)
	gravidade = GRAVITY
	#------------Teste com Prints-------------------------------#
	print(specialMoveTimer)
	print(esquivaMove)
	
	#-----------------------------------------------------------#
	#---------Funções Iniciais do sistema-----------------------#
	run() #Corrida
	VitalidadeControl() #Controle de quantidade de vitalidade
	hudControl()
	esquivaControl()
	#___________________________________________________________#
	#-------------------Controle de Duração do Attack-----------#
	if attack == true: #Se o ataque for verdadeiro
		timerAttack -= delta #Inicie o timer pelo delta
	if combo == 4: #Se combo for igual a 4
		combo = 1 #passe ele para valor 1
	if timerAttack <= 0: #Se o timer do ataque for igual ou menos q 0
		combo = 1 #Combo retorna a 1
		timerAttack = 0.8 #Timer ataque retorna a valor inicial
		attack = false #E o controle de ataque passa a ser falso
	#___________________________________________________________#
	#-------------------Controle de Duração do Dash-------------#
	if controleDash >= 1: #Se o controle do Dash for maior ou igua 1
		dashTimer -= delta #Inicie o timer pelo delta
		dashControl() #chame a função
	#___________________________________________________________#
	#-------------Controle de Duração da Esquiva----------------#
	if esquivaMove >= 1:
		specialMoveTimer -= delta
	if specialMoveTimer <= 0:
		specialMoveTimer = 0.3
		esquivaMove = 0
	#___________________________________________________________#
	#---------------Sistema de Stamina--------------------------#
	if stamina <= 0: #Verficação da quantidade de Stamina
		staminaControl()#Função chamada caso stamina seja menor ou igual a 0
		staminaTimer -= delta #Sistema de Timer da Stamina
	#___________________________________________________________#
	if staminaRecOn == true:
		staminaRec += delta
		staminaRecControl()
	#___________________________________________________________#
	#___________________________________________________________#
	vel.y += GRAVITY * delta #Funcionamento da Gravidade
	#_____________________________________________________________
	#---------Controle de Movimento Basico-----------------------#
	if Input.is_action_pressed("ui_left"): #Mover para esquerda
		staminaRecOn = false
		vel.x = -speed #Velocidade para Esquerda
		dir = 1 #Valor referente a sentido Esquerdo
	elif Input.is_action_pressed("ui_right"): #Mover para direita
		staminaRecOn = false
		vel.x = speed #Velocidade para Direita
		dir = 2 #Valor referente ao sentido Direito
	else:
		staminaRecOn = true
		vel.x = 0 #Velocidade Parado

	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		esquivaMove += 1

	if Input.is_action_just_pressed("ui_atack") and stamina > 0:
		atack1()
	#-----------Controle de pulo---------------------------------#
	var jump = Input.is_action_just_pressed("ui_up") #Mover para pulo
	var jump_stop = Input.is_action_just_released("ui_up") #Verificação se botão pulo ainda está pressionado
	#--------------------#####################-------------------#
	#__________________Controle de Pulo e queda__________________#
	if is_on_floor(): #Verificação se está no chão
		if stamina > 0: #Verificação da quantidade de Stamina
			jumpTwo = true; #Controle do Pulo duplo
			if jump: #Velocidade para Pulo
				stamina -= 1 #Gasto de Stamina
				vel.y = jumpForce #Força do pulo
	elif jump_stop and vel.y < 0: #Verificação da parada no pulo
			vel.y *= 0.3 #Velocidade da Queda pós pulo
	#____________________________________________________________#
	#------------------Lista de Habilidades----------------------#
	#__________________HABILIDADE 1______________________________#
	#________________Controle de Pulo Duplo______________________#
	#Se Hab é igual 1 o jumptwo é verdadeiro e Jump é verdadeiro e a
	#Stamina é maior que 0 e não está no chão.
	if hab1 == 1 and jumpTwo and jump and stamina > 0 and not is_on_floor():
		stamina -= 2 #Gasto de Stamina
		vel.y = -400 #Força ddo segundo pulo
		jumpTwo = false #Controle para impedir mais pulos
	#------------------------------------------------------------#
	#____________________________________________________________#
	#__________________HABILIDADE 2______________________________#
	#________________Dash Velocidade curta distancia_____________#
	if hab2 == 1 and controleDash == 0 and Input.is_action_just_pressed("ui_dash") and stamina > 0:
		dash()
	#____________________________________________________________#
	#------------------------MOVIMENTO---------------------------#
	vel = move_and_slide(vel, Vector2(0, -1))
	#____________________________________________________________#
	#-----------------Função Dash--------------------------------#
func dash():
	
	speed = 1000 
	stamina -= 3 #Gasto de Stamina
	controleDash = 1

	
func dashControl():
	if dashTimer < 0:
		controleDash = 0
		dashTimer = 0.1
		speed = 150

func esquivaControl():
	if esquivaMove >= 2:
		$anim.play(esquivaAnim)
		$".".GRAVITY = 0
		get_node("shape").disabled = true
		yield($anim, "animation_finished")
		get_node("shape").disabled = false
		$".".GRAVITY = 1500
		#gravidade = 1500
		self.position += Vector2(+10, 0)
		stamina -= 2
		esquivaMove = 0 

	#____________________________________________________________#
	#__________________HABILIDADE 3______________________________#
	#________________Corrida velocidade longa distancia__________#
func run():
	#Se Stamina é maior que 0 e Hab3 é é igual 1 e o botão 
	#shift está presionado
	if stamina > 0 and hab3 == 1 and Input.is_action_pressed("ui_run"):
		stamina -= 0.01 #Gasto de Stamina a cada passo
		speed = 300 #Velocidade correndo
	#Caso solte o botão
	elif Input.is_action_just_released("ui_run"):
		speed = 150 #Velocidade andando
#________________________________________________________________#
#________________________________________________________________#



#----------------------------------------------------------------#
#--------------------Sistema de Combate--------------------------#
#Função de Ataque e inicio de combo
func atack1():
	#Se o botão do mouse está pressionado e a stamina é maior que zero
	#Se a variavel dir é = 2
	attack = true
	if dir == 2:
		$anim.play(atackAnim) #Inicie esta animação
		stamina -= 1 #Gasto de Stamina a cada ataque
		combo += 1
		yield ($anim, "animation_finished")


		
		#__________________________________________________#
	#Se a variavel dir é = 1
	if dir == 1:
		$anim.play(atackAnim)#Inicie esta animação
		stamina -= 1 #Gasto de Stamina a cada ataque
		combo += 1
		yield ($anim, "animation_finished")
		


#------------------Funções de Atributos----------------------#
#__________________STAMINA CONTROLE__________________________#
#Função chamada caso Stamina seja = ou menos que 0
func staminaControl():
	speed = 50 #Velocidade de caminhada cansado
	if staminaTimer <= 0: #Verificação do valor do StaminaTimer
		staminaTimer = 5 #quando ele chega a 0 então ele retorna ao valor de tempo 5
		stamina = 50 #Valor da stamina que era 0 retorna a 50
		speed = 150 #Velocidade inicial retomada
#___________________________________________________________#
func staminaRecControl():
	if staminaRec >= 2 and stamina <= 49:
		stamina += 1
		staminaRec = 0
#__________________STAMINA HUD TEXT__________________________#
func hudControl():
	get_node("hud/stamina").set_text(str(int(stamina)))
#-------------------------------------------------------------------#
func VitalidadeControl():
	baseHp = (Level * 2) + (vitalidade * 5) #Hp do player baseado em Vit e Level
	deffis = vitalidade * 2 #Defesa fisica passiva do player
