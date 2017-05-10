#CHPASSWORD SCRIPT
#Authored by Stefan Andrieux and Calvin Robinson of VMware
#Script changes the password of the provisioned linux machine to whatever value is passed as a property at request time
#In this example, the property vra.gugent.selfmanaged.password.linux
/bin/grep '"vra.gugent.selfmanaged.password.linux"' /usr/share/gugent/site/InstallSoftware/properties.xml | /bin/sed 's/<property name="vra.gugent.selfmanaged.password.linux" value="//' | /bin/sed 's/"\/>//' | /bin/awk '{print $1}' | /usr/bin/passwd --stdin root && /usr/bin/passwd -e root
/bin/grep '"vra.gugent.selfmanaged.password.linux"' /usr/share/gugent/site/InstallSoftware/properties.xml | /bin/sed 's/<property name="vra.gugent.selfmanaged.password.linux" value="//' | /bin/sed 's/"\/>//' | /bin/awk '{print $1}' | /usr/bin/passwd --stdin default && /usr/bin/passwd -e default
/bin/rm -f /var/tmp/rootpw.sh
