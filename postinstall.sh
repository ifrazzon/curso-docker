#!/bin/bash -x

VERSAO_VBOX="6.0.8"
VERSAO_VAGRANT="2.2.4"
BUILD_VBOX="130520"

f_dir(){
export_variables $NAME 
DIR_PROG="$HOME/Programas"
}

install_hd() {
        f_dir
        cd $DIR_PROG
	echo "---------------------------------------------------"
        echo      "Executando a instalacao do $NAME..."
        echo "---------------------------------------------------"

       hdiutil attach $NAME.dmg && \
       sudo installer -pkg /Volumes/$NAME/$NAME.pkg -target /Volumes/Macintosh\ HD
       diskutil unmount /Volumes/$NAME
}

download_programa(){
f_dir

GARANTIR_ARQ=$(du -sm $DIR_PROG/$NAME.dmg 2>&- )

if [ $? == 1 ];then

        cd $DIR_PROG
        echo "---------------------------------------------------"
        echo      "Baixando o instalador do $NAME..."
        echo "---------------------------------------------------"
	case $NAME in

 	 VirtualBox)
    		curl  https://download.virtualbox.org/virtualbox/$VERSAO_VBOX/VirtualBox-$VERSAO_VBOX-$BUILD_VBOX-OSX.dmg -o $NAME.dmg
    		;;
 	Vagrant)
    		curl https://releases.hashicorp.com/vagrant/"$VERSAO_VAGRANT"/vagrant_"$VERSAO_VAGRANT"_x86_64.dmg -o $NAME.dmg
    		;;
     
	esac
else
 

        echo "---------------------------------------------------"
        echo      "ARQUIVO  $NAME.dmg já existe, não será baixado..."
        echo "---------------------------------------------------"
        
fi
}

criar_diretorio(){
f_dir

if [ ! -d $DIR_PROG ]; then
        echo ""
        echo       "Criando diretorio: $DIR_PROG" 
        echo "----------------------------------------------------------------"
        mkdir -p $DIR_PROG
        echo "Executando permissao para o diretorio $DIR_PROG   "
        echo "----------------------------------------------------------------"
        chmod 777 $DIR_PROG
else
        echo "--------------------------------------------------"
        echo       "Diretório existente, não será criado..."
        echo "--------------------------------------------------"
fi

}

msn_erro(){ 
 
  echo "---------------------------------------------------"
  echo      "Erro:  $NAME"
  echo "---------------------------------------------------"      
}

ip_vm(){
f_dir
FILE="/private/etc/hosts"
IP=$(vagrant ssh -c "grep -o '10.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /etc/hosts") 
echo $IP
cp -rf $FILE $DIR_PROG 

printf "$IP  docker.com.br" >> $DIR_PROG/hosts 
sudo cp -rf $DIR_PROG/hosts $FILE && dscacheutil -flushcache

}
install() {
f_dir
 
criar_diretorio
if [ $? -ne 0 ]; then
  msn_erro "Criar Diretório..."
fi

 download_programa 
if [ $? -ne 0 ]; then
  msn_erro "Realizar Download..."
fi

install_hd 
if [ $? -ne 0 ]; then
  msn_erro "Realizar instalação no HD..."
fi
}

export_variables(){
NAME=$1
TAM=$2
}

VIRTUALBOX=$(virtualBox --help 2>&-)
if [ $? == 126 ]; then
 
 NAME="VirtualBox"
 f_dir $NAME
 install
else
 v_virtualbox=$(virtualBox --help | head -n 1 | awk '{print $6}' | cut -b 2-6)
 echo "Virtualbox instalado: v$v_virtualbox"
fi

VAGRANT=$(vagrant -v 2>&- )
if [ $? == 127 ]; then
 
 NAME="Vagrant"
 f_dir $NAME
 install && cd $HOME/curso-docker && vagrant up 

else
 v_vagrant=$(vagrant -v | awk '{print $2}')
 echo "Vagrant instalado: v$v_vagrant"
 
fi
