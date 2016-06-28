#!/bin/bash

PATH="$PATH:/usr/local/bin:/export/appl/Util/bin";

CFG="${HOME}/.jornal";

# :: Dependencias - podem ser sobrecarregadas no arquivo rc
LYNX="lynx";
GREP="grep";
AWK="awk";
ECHO="echo";
SORT="sort";
READ="read";
PRINTF="printf";
WGET="wget";
SENDEMAIL="${HOME}/bin/sendEmail";
BASENAME="basename";
RM="rm";


# :: envia o email para a galera
function publica() {

	j="${1}"; #Jornal
	t="${2}"; #Titulo
	e="${3}"; #email
	f="${4}"; #From
	m="${5}"; #msg
	p="${6}"; #smtp

	[  -f ${j} ] && {
		#uuencode ${j} ${j} | mailx -s "DESTAK -ED ${edicao} - \"Preserve a natureza - nao pegue papel, leia nossa versao digital\"" ${emails};
        if [ -z "${LINK}" ] ; then
		${SENDEMAIL} \
				-f ${f} \
				-u "${t}" \
				-a ${j} \
				-m "${m}" \
				-bcc ${e} \
				-s ${p} >/dev/null 2>&1;
        else
		${SENDEMAIL} \
				-f ${f} \
				-u "${t}" \
				-m "${m} ${LINK}/${j}" \
				-bcc ${e} \
				-s ${p} >/dev/null 2>&1;
        fi
	}
}


# :: Pega no site a url do pdf
function getFornalUrl() {
	local url=${1};
	local edicao=${2};

	local urld=;

	[ -f  ${HOME}/.wgetrc ] && {
	# Pega o user e password do wgetrc
		eval $(cat ${HOME}/.wgetrc |grep "^proxy" | sed s/proxy-//g );
	}

	up=;

	[ ! -z "${user}" ] && {
		up="-pauth=${user}";

		[ ! -z "${passwd}" ] && {
			up="${up}:${passwd}";
		}
	}
	${LYNX} ${up} -dump ${url} | ${GREP} "pdf" | ${AWK} '{ print $2 }' | ${SORT} -u | while ${READ} line ; do
		${ECHO} $line | ${GREP} ${edicao} 2>/dev/null && {
			[ ! -z "${line}" ] && urld=$line;
		}
	done

	${ECHO} ${urld};
}

RC="${CFG}/getNews.${1}.rc";

[ ! -f "${RC}" ] && {
	${PRINTF} "Use: \t${0} <opc>\n";
	echo;
	${PRINTF} "\t opc:\n"
	for file in ${CFG}/getNews.*.rc ; do
		[ -f "${file}" ] && {
			f=$( ${BASENAME} ${file} );

			f=${f%%.rc};
			f=${f##getNews.};
			${PRINTF} "\t\t${f}\n";
		}
	done
	exit;
}

# :: Importa o arquivo RC
source ${RC};

cd ${CFG};

# :: verifica se a edicao ja foi transmitida
if [ -f edicao.${1}.rc ] ; then
	e="$( cat edicao.${1}.rc )";

	[ -f "${e}" ] && {
        #dt_file=$(  ls -la  edicao.${1}.rc | cut -d " " -f 6);
        dt_file=$(  ls -la  edicao.${1}.rc | cut -d " " -f 6,7);

        #today=$( date +%Y-%m-%d );
        today=$( date +"%b %d" );

        #[ "${dt_file}" != "${today}" ] && rm "${e}";
    }
	url=$( getFornalUrl "${URL}" "${OPC}" | ${GREP} -v "${e}" );
else
	url=$( getFornalUrl "${URL}" "${OPC}" );
fi

# :: coletou a url
[ ! -z "${url}" ] && {
	# :: Possui email
	[ ! -z "${EMAIL}" ] && {
		# :: pega jornal
		${WGET} -c  ${url} && {
			f="$( ${BASENAME} ${url} )";

			[ -f "${f}" ] && {
				echo ${f} > edicao.${1}.rc;
				# :: envia para a turma;
				publica ${f} "${TITLE:-$1}" "${EMAIL}" "${FROM}" "${MSG:-Preserve a natureza - nao pegue papel, leia nossa versao digital}" ${SMTP};

				#${RM} -f ${f};
			}
		}
	}
}

