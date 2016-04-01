###########################################################################
# .bashrc                                                                 #
# @author Paulo R. A. Sales.                                              #
# Define funcionalidades que o a sessao do usuario logado tera direito.   #
###########################################################################

# carrega variaveis de ambiente .bashrc_define
[ -f ~/.bashrc_define ] && source ~/.bashrc_define

# carrega funcoes .bashrc_func 
[ -f ~/.bashrc_func ] && source ~/.bashrc_func

# carrega funcoes de teste (experiencias com programacao shell)
[ -f ~/.bashrc_test ] && source ~/.bashrc_test

# carrega funcoes do RVM - Ruby Version Management
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
