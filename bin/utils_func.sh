#!/bin/sh
###########################################################################
# utils_func.sh                                                           #
# @author Paulo R. A. Sales.                                              #
# Define as funcoes de utilidade geral para rotinas shell script       .  #
###########################################################################

# Variaveis Gerais
RET_ERROR=-1
RET_OK=0
STD_OUT=out.$$.log
STD_ERR=err.$$.log
SHIFT_COLS=74

## FUNCOES ##

############################################################################
#msg()																	   #
#Mostra uma msg para o usuario com a cor passada como opcao                #
############################################################################
function msg() {
	# Msg de erro
	ERROR="Usage: msg [color] [msg]\n
[msg]\n
	\tPode ser qualquer frase ou palavra.\n
[color]:\n
	\t-n\t--normal\t: Normal\n
	\t-c\t--cyan\t\t: Cinza\n
	\t-r\t--red\t\t: Vermelho\n
	\t-g\t--green\t\t: Verde\n
	\t-y\t--yellow\t: Amarelo\n
	\t-b\t--blue\t\t: Azul"

	if [ "$#" -lt 2 ]
	then
		infoalert ${ERROR}
		return ${RET_ERROR}
	fi

	# Pega a opcao digitada
	tipo=${1}; #/* G=verde|Y=Amarelo|R=Vermelho */
	# Pega o restante de params digitados
	info=${*:2};
	
	case "${tipo}" in
		-n|--normal)   echo -e "${info} ";; # Normal
		-c|--cyan)     echo -e "\033[30;1m ${info} \033[m ";; # Cinza
		-r|--red)      echo -e "\033[31;1m ${info} \033[m ";; # Vermelho
		-g|--green)    echo -e "\033[32;1m ${info} \033[m ";; # Verde
		-y|--yellow)   echo -e "\033[33;1m ${info} \033[m ";; # Amarelo
		-b|--blue)     echo -e "\033[34;1m ${info} \033[m ";; # Azul
		-a|-w|--white) echo -e "\033[36;1m ${info} \033[m ";; # Branco
		*)             infoalert ${ERROR}; return ${RET_ERROR} ;;
	esac

	return ${RET_OK}
}

# Vertentes do comando msg()
function infoalert() {
	msg -r ${*}
}

function infoexec() {
	msg -y ${*}
}

function infolog() {
	msg -w ${*}
}

function infosuccess() {
	msg -g ${*}
}

############################################################################
#inforesult()                                							   #
#Informa o resultado [OK] para 0 e [FAIL] para <> 0 o 1 parametro	       #
#Se o 1 parametro for <> 0 e tiver um segundo parametro este sera mostrado #
############################################################################
function inforesult() {
	ERROR="Usage: inforesult [conditions] <info msg>\n[conditions]\n
	\t0\t: Sera mostrado [OK]\n
	\t<>0\t: Sera mostrado [FAIL]\n<info msg>\n
	\tMensagem informativa (nao eh obrigatorio)."

	if [ "${1}" ] 
	then
		#Mostra a msg informativa, caso exista.
		if [ "${2}" ]
		then
			MSG=${*:2}
			echo -n "${MSG}"
		fi

		#Mostra o resultado
		if [ "${1}" -eq 0 ]
		then
			echo -e "\033[0G\033["${SHIFT_COLS}"C[\033[32;1mOK\033[m]"
		else
			echo -e "\033[0G\033["${SHIFT_COLS}"C[\033[31;1mFAIL\033[m]"
		fi

		return ${1}
	else
		infoalert ${ERROR}
		return ${RET_ERROR}
	fi
}

############################################################################
#silentexec()                                							   #
#Executa um comando em modo silencioso e mostra o status.    			   # 
############################################################################
function silentexec() {
	ERRO="Usage: silentexec [option] [command] <msg>\n[option]\n
	\t-o\t--out\t: Grava saida padrao em ${STD_OUT}.\n
	\t-e\t--err\t: Grava saida de erro em ${STD_ERR}.\n
	\t-a\t--all\t: Grava saida padra e de erro em ${STD_OUT} e ${STD_ERR}.\n
	\t-n\t--none\t: Mostra saida padrao e de erro.\n
	[command]\n\tComando a ser executado.\n\t<msg>\n\tMensagem ao usuario, c/ 
	\"\" (nao eh obrigatorio)."

	if [ "${#}" -lt 2 ]
	then
		infoalert ${ERRO}
		return ${RET_ERROR}
	fi
	
	if [ -n "${3}" ]
	then
		infoexec "# ${3}"
	else
		infoexec "# ${2}"
	fi

	case "${1}" in
		-o|--out) eval ${2} 1> ${STD_OUT}
		;;
		-e|--err) eval ${2} 2> ${STD_ERR}
		;;
		-a|--all) eval ${2} 1> ${STD_OUT} 2> ${STD_ERR}
		;;
		-n|--none) eval ${2}
		;;
		*) infoalert ${ERROR}
		   return ${RET_ERROR}
		;;
	esac

	RET=${?};

	#Se existe arq. e tem dados, mostrar msg informativa no resultado
	if [ -s "${STD_ERR}" ]
	then
		inforesult ${RET} "Ver ${STD_ERR}"
	else
		inforesult ${RET};
	fi

	return ${RET};
}

############################################################################
#confirm()																   #
#Mostra uma msg para o usuario com direito a resposta de (s/n)             #
############################################################################
function confirm() {
	ERROR="Usage: confirm [msg]\n[msg]\n\tPode ser qualquer frase ou palavra."
	ret=`expr ${RET_ERROR}`;
	
	if [ "$#" -lt 1 ]
	then
		infoalert $ERROR
		return ${ret}
	fi
	
	read -p "${*} (s/n): " retorno;

	[ "${retorno}" == "s" ] && ret=${RET_OK};
	[ "${retorno}" == "n" ] && ret=${RET_ERROR};
	[ -z "${ret}"         ] && confirm;

	return ${ret};
}

############################################################################
#copyfile()																   #
#Executa o comando cp, mas utilizando msgs formatadas ao usuario.          #
############################################################################
function copyfile() {
	ERROR="Usage: copyfile [file] [dest]\n[file]\n
			\tArquivo de origem a ser copiado.\n
			[dest]\n\tDiretorio de destino do arquivo a ser copiado."

	if [ "$#" -lt 2 ]
	then
		infoalert ${ERROR}
		return ${RET_ERROR}
	fi

	ORIGEM=${1}
	DESTINO=${2}

	msgCmd="Copiando arquivo: ${ORIGEM}"
	exeCmd="cp -f ${ORIGEM} ${DESTINO}";
	silentexec -a "${exeCmd}" "${msgCmd}"
}

