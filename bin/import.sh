# ####################
# Extencoes conhecidas
#
#	html
#	css
#	jsp
#	java
#	vm
#	js
#	jpg
#	png
#	gif
#	
# ####################


function copyFiles {
	# $1 = Contexto [ Cetelem, Carrefour, WebAura, Portal ]
	# $2 = Dir Workspace - Full qualified name
	
	[  -z "$1" -o -z "$2" ] && {
		usage
	}
	
	CONTEXTO=$1
	WORKSPACE=$2
	BASE_DIR=${HOME}/Cetelem/Dev/${CONTEXTO}
	DEST_DIR=${HOME}/${WORKSPACE}/${CONTEXTO}
	WEBCONTENT_DIR=${DEST_DIR}/WebContent
	IMAGES_DIR=${WEBCONTENT_DIR}/images

	echo "WebContent: ${WEBCONTENT_DIR}"
	echo "DEST      : ${DEST_DIR}"
	echo "BaseDir   : ${BASE_DIR}"
	echo "Contexto  : ${CONTEXTO}"
	echo "Workspace : ${WORKSPACE}"
	echo ""

	# ######################################################
	# ATUALIZANDO ARQUIVOS DO TRONCO
	echo -e "\033[32;1mAtualizando Branch do contexto ${CONTEXTO}\033[m"
	DIR=$PWD
	cd ${BASE_DIR}
	cvs update
	cd ${DIR}
	# ######################################################
	# COPIANDO ARQUIVOS
	files[0]="html"
	files[1]="htm"
	files[2]="jsp"
	files[3]="css"
	files[4]="js"
	for ((i=0; i<5; i++)) {
		echo -e "\033[32;1mCopiando arquivos\033[m \033[33;1m${files[$i]}\033[m"
		if [ "${files[$i]}" != "htm" ]
		then
			mkdir -p ${WEBCONTENT_DIR}/${files[$i]}
		fi
		for arq in `find ${BASE_DIR} -name "*.${files[$i]}"`
		do
			if [ "${files[$i]}" = "htm" ] 
			then
				cp ${arq} ${WEBCONTENT_DIR}/html
			else
				cp ${arq} ${WEBCONTENT_DIR}/${files[$i]}
			fi
		done
	}
	
	# ######################################################
	# COPIANDO AS IMAGENS
	files[0]="jpg"
	files[1]="png"
	files[2]="gif"
	mkdir -p ${WEBCONTENT_DIR}/images
	for ((i=0; i<3; i++)) {
		echo -e "\033[32;1mCopiando arquivos\033[m \033[33;1m${files[$i]}\033[m"
		for arq in `find ${BASE_DIR} -name "*.${files[$i]}"`
		do
			cp ${arq} ${WEBCONTENT_DIR}/images
		done
	}

	# ######################################################
	# COPIANDO INFRA JAVA
	echo -e "\033[32;1mGerando tar com fontes java e arquivos diversos \033[m"
	mkdir -p ${DEST_DIR}/src
	DIR=$PWD
	cd ${BASE_DIR}
	ant migracao
	cp ${CONTEXTO}.jar ${DEST_DIR}/src
	rm ${CONTEXTO}.jar
	cd ${DEST_DIR}/src
	jar -xvf "${CONTEXTO}.jar"
	#rm ${CONTEXTO}.jar
	rm -rf META-INF
	cd ${DIR}
	
	echo ""
	echo -e "\033[32;1mVerifique os diretorios\033[m"
	echo -e "\033[33;1mContexto  : ${CONTEXTO}\033[m"
	echo -e "\033[33;1mWorkspace : ${WORKSPACE}\033[m"
	echo -e "\033[33;1mWebContent: ${WEBCONTENT_DIR}\033[m"
	echo -e "\033[33;1mDEST      : ${DEST_DIR}\033[m"
	echo -e "\033[33;1mBaseDir   : ${BASE_DIR}\033[m"
	echo ""

}

function usage() {
	echo " "
	echo " $0 <param1> <param2>"
	echo "           <param1> = Contexto: Carrefour Cetelem Portal WebAura Util"
	echo "           <param2> = Diretorio do workspace"
	echo " "
	echo " "
	exit
}

[ -z "$1" -o -z "$2" ] && usage

#works=${HOME}/workspace_eclipse/
context=$1
works=$2

copyFiles ${context} ${works}

