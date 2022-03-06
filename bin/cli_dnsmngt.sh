#! /bin/bash
#set -x
# * **************************************************************************
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * Author:		cli_dnsmngt.sh
# * Version:		1.1.13
# *
# * Description:	Tool to configure DNS Zone.
# *
# * Creation: December 16, 2017
# * Change:   January 19, 2022
# *
# **************************************************************************
# * chmod 500 cli_dnsmngt.sh
# **************************************************************************

# ## Cleaning the screen.
clear


#####################################################################
# ## CUSTOM VARIABLES

# ## Server DNS slave.
declare -r serverSlave=(192.168.0.10)
#declare -r serverSlave=(192.168.0.10 192.168.0.11)

# ## Put here your favorite editor (editor, vim, nano, etc.). The default is the system-defined editor.
declare -r editor='editor'

# ## Path for zone files.
# ## Default path for files.
declare -r zonePath='/var/chroot/bind/var/bind/pri'

# ## Path for primary zone files.
declare -r zonePriPath='/var/chroot/bind/var/bind/pri'

# ## Path for secondary zone files.
declare -r zoneSecPath='/var/chroot/bind/var/bind/sec'

# ## Default file zone.
declare -r declaredZones='named.pri.conf'

# ## Primary file zone.
declare -r declaredPriZones='"named.pri.conf'

# ## Secondary file zone.
declare -r declaredSecZones='named.sec.conf'


#####################################################################
# ## VARIABLES

# ## Actual version of this script.
version='0.1.13'
declare -r version

# ## Actual date.
actualYear=$(date +"%Y")
declare -r actualYear


# ############################################################
# ## LANGUAGE

langFR() {
 labelTitle="(c) 2004-${actualYear}  Cybionet - Bind9 tools"
 txtSplitDetect='Vue DNS partagée détectée!'
 msgNbrTotalZone='Nombre total de zones trouvées:'
 msgFoundCgf='trouvée dans la configuration.'
 msgNbrActZone='Nombre de zone active: '
 msgNbrInact='Nombre de zone inactive:'
 msgInactZone='Zone inactive'
 msgInactZones='Zones inactives'
 msgNoInactZone='Aucune zone inactive'

 # ## syncZone
 txtMsg1='Recharger le fichier de configuration et des zones, puis transfer de toutes les zones esclaves depuis le serveur maître.'
 txtMsg2='Recharger le fichier de configuration et des zones, puis transférer la zone esclave spécifiée depuis le serveur maître.'
 txtMsg3='Local'

 # ## searchZone
 txtAZ1='The zone for this domain ('
 txtAZ2=') do not exist.'
 txtMsg6='Aucune erreur trouvée'
 txtMsg7='Erreur'

 # ## menu
 txtmnumsg1='Show all zones'
 txtmnumsg2='Show active zones'
 txtmnumsg3='Show disabled zones'
 txtmnumsg4='Edit existing zone'
 txtmnumsg5='Launch zone replication'
 txtmnumsg6='Manage Bind9 service'
 txtmnumsg7='Enter the domain name'

 # ## submenu
 txtmnumsg8='Modifier la zone:'
 txtmnumsg9='Afficher la date Epoch'
 txtmnumsg10='Vérifier le fichier de la zone'
 txtmnumsg11='Réplique cette zone vers le serveur esclave'
 txtmnumsg12='Voir/modifier la note'
 txtmnumsg13='Ajouter une note'
 txtmnumsg14='Retour au menu principal'

 # ## sysmenu
 txtmnumsg15='Action on service.'
 txtmnumsg16='Restart'
 txtmnumsg17='Start'
 txtmnumsg18='Stop'
 txtmnumsg19='Status'
 txtmnumsg20='Check bind9 config'
 txtmnumsg21='Retour au menu principal'

 # ## selectZoneType
 txtmnumsg22='Zones Primaires'
 txtmnumsg23='Zones Secondaires'

 # ## version
 txtvermsg1='Appuyer sur Entrée pour continuer'

 # ## 
 msgActive='Active'
 #msgInactive='Inactive'
 msgQuit='Quitter'
 msgChoice='Votre choix'
}

langEN() {
 labelTitle="(c) 2004-${actualYear}  Cybionet - Bind9 tools"
 txtSplitDetect='DNS split view detected!'
 msgNbrTotalZone='Number of total zone found:'
 msgFoundCgf='found in the configuration.'
 msgNbrActZone='Number of active zone:'
 msgNbrInact='Number of inactive zone:'
 msgInactZone='Inactive zone'
 msgInactZones='Inactives zones'
 msgNoInactZone='No inactive zone'

 # ## syncZone
 txtMsg1='Reloading of the configuration file and zones and transfer of all slave zones from the master server.'
 txtMsg2='Reload the configuration file and zones, then transfer the specified slave zone from the master server.'
 txtMsg3='Local'

 # ## searchZone
 txtAZ1='The zone for this domain ('
 txtAZ2=') do not exist.'
 txtMsg6='No errors found'
 txtMsg7='Error'

 # ## menu
 txtmnumsg1='Show all zones'
 txtmnumsg2='Show active zones'
 txtmnumsg3='Show disabled zones'
 txtmnumsg4='Edit existing zone'
 txtmnumsg5='Launch zone replication'
 txtmnumsg6='Manage Bind9 service'
 txtmnumsg7='Enter the domain name'

 # ## submenu
 txtmnumsg8='Edit the actual zone'
 txtmnumsg9='Show Epoch date'
 txtmnumsg10='Check zone file'
 txtmnumsg11='Replicate this zone to the slave server'
 txtmnumsg12='View/Edit zone note'
 txtmnumsg13='Add zone note'
 txtmnumsg14='Return main menu'

 # ## sysmenu
 txtmnumsg15='Action on service.'
 txtmnumsg16='Restart'
 txtmnumsg17='Start'
 txtmnumsg18='Stop'
 txtmnumsg19='Status'
 txtmnumsg20='Check bind9 config'
 txtmnumsg21='Return main menu'

 # ## selectZoneType
 txtmnumsg22='Primary zones'
 txtmnumsg23='Secondary zones'

 # ## version
 txtvermsg1='Press enter to continue'

 # ##
 msgActive='Active'
 #msgInactive='Inactive'
 msgQuit='Quit'
 msgChoice='Your choice'
}

# ## Search the language of the operating system.
getLang()
{
 if [ "${LANG}" == 'fr_CA.UTF-8' ]; then
   langFR
 else
   # Set english by default.
   langEN
 fi
}


#####################################################################
# ## ARRAYS

# Define the array.
declare -a activeZones=($(cat /etc/bind/named.pri.conf | grep '^zone' | grep -v '#' | awk -F '["]' '{print $2}'))
declare -a inactiveZones=($(cat /etc/bind/named.pri.conf | grep '#zone' | awk -F '["]' '{print $2}'))
declare -a allZones=($(cat /etc/bind/named.pri.conf | grep '^zone\|#zone' | awk -F '["]' '{print $2}'))


#####################################################################
# ## FUNCTIONS

# ## Show menu header.
function header {
 echo -e "\e[34m${labelTitle}\e[0m"
 printf '%.s─' $(seq 1 "$(tput cols)")
}

# ##
function showAllZones {
 header

 len=${#allZones[*]}
 echo -e "\n${msgNbrTotalZone} ${len}"
 countView

 declare -i i=0

 if [ "${len}" -eq 0 ]; then
   vZone='Zone'
 else
   vZone='Zones'
 fi

 echo -e -n "${vZone} ${msgFoundCgf}\n"
 while [ "${i}" -lt "${len}" ]
  do
    echo -e -n "\e[36;1;208m\t${allZones[$i]}\e[0m\n"
    let i++
  done

 echo -n -e "\n"
 printf '%.s─' $(seq 1 65)

 menu
}

# ## Display Inactives Zones.
function showActiveZones {
 header

 aclen=${#activeZones[*]}
 echo -e "\n${msgNbrActZone} ${aclen}"
 countView

 declare -i i=0

 if [ "${aclen}" -lt 2 ]; then
   vacZone='zone'
 else
   vacZone='zones'
 fi


 echo -e -n "${msgActive} ${vacZone}.\n"
 while [ "${i}" -lt "${aclen}" ]
  do
    echo -e -n "\e[36;1;208m\t${activeZones[$i]}\e[0m\n"
    let i++
  done

 echo -n -e "\n"
 printf '%.s─' $(seq 1 65)

 menu
}

# ## Display Inactives Zones.
function showInactiveZones {
 header

 inlen=${#inactiveZones[*]}
 echo -e "\n${msgNbrInact} ${inlen}"
 countView

 declare -i i=0

 if [ "${inlen}" -eq 1 ]; then
   vinZone="${msgInactZone}"
 elif [ "${inlen}" -eq 0 ]; then
   vinZone="${msgNoInactZone}"
 else
   vinZone="${msgInactZones}"
 fi

  echo -e -n "${vinZone}.\n"
  while [ "${i}" -lt "${inlen}" ]
  do
   echo -e -n "\e[36;1;208m\t${inactiveZones[$i]}\e[0m\n"
   let i++
 done

 echo -n -e "\n"
 printf '%.s─' $(seq 1 65)

 menu
}


# ##
function searchZone {
 header

 declare -A map

 for key in "${!activeZones[@]}"; do map[${activeZones[$key]}]="${key}"; done  # see below

 zoneName=$1
 if [ ! -f "${zonePath}/${zoneName}.zone" ]; then
   echo -e "\n${txtAZ1}${zoneName}${txtAZ2}"
   echo -n -e "\n"
   printf '%.s─' $(seq 1 65)
   menu
 else
   cat "${zonePath}"/"${zoneName}".zone
   echo -n -e "\n"
   printf '%.s─' $(seq 1 65)
   submenu
 fi
}

# ##
function showEpoch {
 header

 now=$(date)
 epoch=$(date +%s)

 echo "Date: ${now}"
 echo "Epoch: ${epoch}"

 echo -n -e "\n"
 printf '%.s─' $(seq 1 65)

 submenu
}

# ##
function syncZone {
 header

 if [[ "${fullSync}" -eq 1 ]]; then
   echo -e "${txtMsg1}\n"
   echo "${txtMsg3}"
   rndc flush
   rndc reload
   echo ' '

   for srvDNS in "${serverSlave[@]}"; do
     echo "${srvDNS}"
     rndc -s "${srvDNS}" flush
     rndc -s "${srvDNS}" reload
     echo ' '
   done
 else
   echo -e "${txtMsg2}\n"
   echo "${txtMsg3}"
   rndc flushname "${zoneName}"
   rndc reload
   echo ' '

   for srvDNS in "${serverSlave[@]}"; do
     echo "${srvDNS}"
     rndc -s "${srvDNS}" flushname "${zoneName}"
     rndc -s "${srvDNS}" reload "${zoneName}"
     echo ' '
   done
 fi

  printf '%.s─' $(seq 1 65)

 # ## Reset variable.
 fullSync=0
}

# ##
function checkZone {
 header
 named-checkzone "${zoneName}" /var/chroot/bind/var/bind/pri/"${zoneName}".zone
 echo -e "\n$(whois "${zoneName}" | egrep -i 'Registration Expiration Date|Registry Expiry Date|Expiry date' | sed -e 's/^[ \t]*//' | awk -F 'T' '{print $1}')"
 printf '%.s─' $(seq 1 65)
}

# ##
function checkConfig {
 chkcfg=$(/usr/sbin/named-checkconf /etc/bind/named.conf)
 if [ -z "${chkcfg}" ] ; then
   echo "${txtMsg6}"
 else
   echo -e "${txtMsg7}:\n${chkcfg}"
 fi
}

# ##
function countView {
 # ## Count number of view for DNS split brain.
 splitBrain=$(cat /etc/bind/named.options.conf | grep -c "^view")
 if [ "${splitBrain}" -gt 1 ]; then
  echo -e "\e[31;1;208m\t${txtSplitDetect}\e[0m\n"
 else
  echo -e "\n"
 fi
}

# ##
function getVersion {
 echo "Version: ${version}"
 printf '%.s─' $(seq 1 65)
 echo -e '\n'
 read -r -p "${txtvermsg1}" -t 50
 clear
 header
}


#####################################################################
# ## EXPERIMENTAL

function createZone {
 # ## Enter the name of the new zone.
 read -r -p "Enter the name of the new zone you want create: " domain
 echo "${domain}"
 # ## Check if the zone already exists.

 # ## Enter the IP address.
 read -r -p "Enter the IP address for the domain: " ipaddress
 echo "${ipaddress}"

 # ## Retreive epoch date.
 epoch=$(date +%s)

 # ## Copy template and generate zone
 # ## Full sed....

 #ns1 = localhost
 #ns2 = serverSlave (incrementiel)
}

# ## EXPERIMENTAL - UNUSED.
function showRawZone {
 if [ -n "${1}" ]; then
  zonefile="${1}"

  named-checkzone -f raw -F text -o - "${zonefile}" "${zonePath}"/"${zonefile}"\.zone
 fi
}


#####################################################################
# ## MENU
function menu {
  echo -e "\n1) ${txtmnumsg1}"
  echo "2) ${txtmnumsg2}"
  echo "3) ${txtmnumsg3}"
  echo "4) ${txtmnumsg4}"
  echo "5) ${txtmnumsg5}"
  echo "6) ${txtmnumsg6}"
  printf '%.s─' $(seq 1 30)
  echo -e "\nQ) ${msgQuit}"
  echo -n -e "\n${msgChoice}: "
  read -r case;

  case "${case}" in
        1)
            clear
            showAllZones
            ;;
        2)
            clear
            showActiveZones
            ;;
        3)
            clear
            showInactiveZones
            ;;
        4)
           echo -n "${txtmnumsg7}: "
           read -r result in
           clear
           searchZone "${result}"
           ;;
        5)
           clear
           fullSync=1
           syncZone
           menu
           ;;
        6)
           clear
           header
           sysmenu
           ;;
        7)
           clear
           createZone
           ;;
        8)
           clear
           header
           selectZoneType
           ;;
        q|Q)
           clear
           exit 0
           ;;
         V|v)
           clear
           header
           getVersion
           menu
           ;;
        *)
           clear
           header
           menu
           ;;
  esac
}

function submenu {
 echo -e "\n1) ${txtmnumsg8} (${zoneName})"
 echo "2) ${txtmnumsg9}"
 echo "3) ${txtmnumsg10}"
 echo "4) ${txtmnumsg11}"
 if [ -f "${zonePath}/${zoneName}.note" ]; then
   echo "5) ${txtmnumsg12}"
 else
   echo "5) ${txtmnumsg13}"
 fi
 printf '%.s─' $(seq 1 30)
 echo -e "\nR) ${txtmnumsg14}"
 echo -e "Q) ${msgQuit}"
 echo -n -e "\n${msgChoice}: "
 read -r subcase;

 case "${subcase}" in
        1)
           clear
           "${editor}" "${zonePath}"/"${zoneName}".zone
           header
           submenu
            ;;
        2)
           clear
           showEpoch
            ;;
        3)
           clear
           checkZone
           submenu
           ;;
       4)
           clear
           syncZone
           submenu
           ;;
        5)
           clear
           "${editor}" "${zonePath}"/"${zoneName}".note
           header
           submenu
           ;;
        R|r)
           clear
           header
           menu
           ;;
        Q|q)
           clear
           exit 0
           ;;
        *)
           clear
           header
           menu
           ;;
 esac
}

function sysmenu {
 echo -e "${txtmnumsg15}"
 echo -e "\n1) ${txtmnumsg16}"
 echo "2) ${txtmnumsg17}"
 echo "3) ${txtmnumsg18}"
 echo "4) ${txtmnumsg19}"
 echo "5) ${txtmnumsg20}"
 printf '%.s─' $(seq 1 30)
 echo -e "\nR) ${txtmnumsg21}"
 echo -e "Q) ${msgQuit}"
 echo -n -e "\n${msgChoice}: "
 read -r syscase;

 case "${syscase}" in
        1)
           clear
           header
           systemctl restart bind9.service
           printf '%.s─' $(seq 1 30)
           echo -e '\n'
           sysmenu
           ;;
        2)
           clear
           header
           systemctl start bind9.service
           printf '%.s─' $(seq 1 30)
           echo -e '\n'
           sysmenu
           ;;
        3)
           clear
           header
           systemctl stop bind9.service
           printf '%.s─' $(seq 1 30)
           echo -e '\n'
           sysmenu
           ;;
        4)
           clear
           header
           echo -e '\n'
           systemctl status bind9.service
           printf '%.s─' $(seq 1 30)
           echo -e '\n'
           sysmenu
           ;;
        5)
           clear
           header
           checkConfig
           printf '%.s─' $(seq 1 30)
           echo -e '\n'
           sysmenu
           ;;
        R|r)
           clear
           header
           menu
           ;;
        Q|q)
           clear
           exit 0
           ;;
        *)
           clear
           header
           menu
           ;;
 esac
}

# ##
function selectZoneType {
  echo -e "\n1) ${txtmnumsg22}"
  echo "2) ${txtmnumsg23}"
  printf '%.s─' $(seq 1 30)
  echo -e "\nQ) ${msgQuit}"
  echo -n -e "\n${msgChoice}: "
  read -r case;

  case "${case}" in
        1)
            clear
            declaredZones="${declaredPriZones}"
            zonePath="${zonePriPath}"

            activeZones=($(cat /etc/bind/"${declaredZones}" | grep '^zone' | grep -v '#' | awk -F '["]' '{print $2}'))
            inactiveZones=($(cat /etc/bind/"${declaredZones}" | grep '#zone' | awk -F '["]' '{print $2}'))
            allZones=($(cat /etc/bind/"${declaredZones}" | grep '^zone\|#zone' | awk -F '["]' '{print $2}'))
            header
            menu
            ;;
        2)
            clear
            declaredZones="${declaredSecZones}"
            zonePath="${zoneSecPath}"

            activeZones=($(cat /etc/bind/"${declaredZones}" | grep '^zone' | grep -v '#' | awk -F '["]' '{print $2}'))
            inactiveZones=($(cat /etc/bind/"${declaredZones}" | grep '#zone' | awk -F '["]' '{print $2}'))
            allZones=($(cat /etc/bind/"${declaredZones}" | grep '^zone\|#zone' | awk -F '["]' '{print $2}'))
            header
            menu
            ;;
        q|Q)
           clear
           exit 0
           ;;
        *)
           clear
           menu
           ;;
  esac
}


#####################################################################
# ## EXECUTION
getLang

header
menu

# ## Exit.
exit 0

# ## END
