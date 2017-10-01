#!/bin/bash

echo

echo "aenigma.xyz ejabberd installer by nikksno [https://github.com/openspace42/aenigma]"
echo

echo "Run this once logged into your newly creater server via ssh as the root user"
echo
read -p "Are you currently root in your target machine (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo "Confirmed. Now continuing..."
echo

echo "! ! ! ! ! ! ! !"
echo
echo "WARNING: This script is NOT meant to be re-run. If you have previously run it, ONLY run it again if you whish to either:"
echo
echo "1] Fix an incomplete deployment that happened on the first run"
echo
echo "2] Start fresh with a brand new server"
echo
echo "Running this script again WILL completely obliterate any existing conigurations and data."
echo
read -p "Have you read and understood the above, and do you whish to continue now? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo "Confirmed. Now continuing..."
echo

if [ -f /root/.dfbs-run-ok ]; then
        echo "Debian First Boot Setup was previously run successfully. Continuing..."
        echo
else
	echo "Debian First Boot Setup was NOT previously run successfully OR the system was not rebooted at the end."
	echo
	echo "Run it now [or re-run it and make sure you reboot at the end] by executing the following command:"
	echo
	echo "        wget -qO dfbs https://gh.nk.ai/dfbs && sudo bash dfbs"
	echo
	exit
fi

echo "----------------"
echo
echo "0] First of all, a little introduction on how XMPP actually works"
echo
echo "XMPP works a little bit like email. You can have a domain [amsterdamhacklab.xyz] and receive email for that domain on a server located at mx01.amsterdamhacklab.xyz, by using the appropriate DNS configuration, and also have other servers [webserver, mapserver, etc...] on other subdomains. In that case, a DNS "MX" record tells sending servers to direct mail intended for amsterdamhacklab.xyz to mx01.amsterdamhacklab.xyz."
echo
echo "In the same way, the XMPP server for amsterdamhacklab.xyz can be located at xmpp.amsterdamhacklab.xyz and a DNS "SRV" record tells any sending servers that XMPP for that domain [i.e. a message directed to mark@amsterdamhacklab.xyz] is handled by the server located at xmpp.amsterdamhacklab.xyz."
echo
read -p "[press enter to continue reading...]"
echo
echo "1] Now, if the domain for which you're setting up your new aenigma server is a domain connected to a bigger project, for which XMPP is just another way of getting in touch with you, definitely set things up like this by using the first option."
echo
echo "This will give you working @domain.tld xmpp account addresses, but the aenigma server will reside at subdomain.domain.tld, as in the following example."
echo
echo "Main domain:          amsterdamhacklab.xyz."
echo "Website:              amsterdamhacklab.xyz / www.amsterdamhacklab.xyz [hosted by another server]."
echo "Your XMPP address:    mark@amsterdamhacklab.xyz."
echo "XMPP server:          xmpp.amsterdamhacklab.xyz"
echo
echo "PROs:                 a] clean addresses [no mark@xmpp.amsterdamhacklab.xyz stuff]"
echo "                      b] more logical setup."
echo "CONs:                 a] requires TLS [SSL] certificate for the top level domain [amsterdamhacklab.xyz]"
echo "                         to be copied over to your new aenigma server [not hard at all, can be automated, see below]"
echo
read -p "[press enter to continue reading...]"
echo
echo "2] If instead your domain [i.e. aenigmapod42.im] is only intended to be used for your shiny new aenigma server, and you don't need other, different servers [a webserver for instance] managing different aspects of your project, you can do as so:"
echo
echo "Set your aenigma server to be located directly at your top level domain, therefore responding directly to amsterdamhacklab.xyz."
echo
echo "Your server hostname:  aenigmapod42.im"
echo "Your addresses:        mark@aenigmapod42.im."
echo
echo "PROs:                  a] clean addresses"
echo "                       b] no separate TLS certificate needed."
echo "CONs:                  a] your domain must be logically dedicated to your aenigma server"
echo "                          and not to a wider project."
echo
read -p "[press enter to continue reading...]"
echo
echo "3] In a third, although NOT suggested case, if you have a domain tied to a wider project [i.e. amsterdamhacklab.xyz] but you don't mind having longer and more complex XMPP account addresses [like mark@xmpp.amsterdamhacklab.xyz], you can choose the third option."
echo
echo "Your server hostname:  subdomain.domain.tld"
echo "Your addresses:        mark@subdomain.domain.tld."
echo
echo "PROs:                  a] domain can be logically connected to other stuff and different servers"
echo "                          with no separate TLS certificate needed."
echo "CONs:                  a] longer and more complex addresses"
echo "                       b] not logically 'clean'."
echo
read -p "[press enter to continue reading...]"
echo
echo "Now that you know how XMPP works, make your choice and let's get your brand new aenigma server up and running!"
echo
echo "----------------"
echo

choice='Please enter your choice: '
options=("configuration 1" "configuration 2" "configuration 3" "exit")
select opt in "${options[@]}"
do
    echo
    case $opt in
	"configuration 1")
	    echo "you chose configuration 1"
	    echo
	    configoption=1
	    break
	    ;;
	"configuration 2")
	    echo "you chose configuration 2"
	    echo
	    configoption=2
	    break
	    ;;
	"configuration 3")
	    echo "you chose configuration 3"
	    echo
	    configoption=3
	    break
	    ;;
	"exit")
	    echo "Exiting..."
	    echo
	    exit
	    ;;
	*)  echo "Invalid option. Retry..."
	    echo
	    ;;
    esac
done

hostname="$(cat /etc/hostname)"

if [ $configoption = "1" ]

then
	echo "Ok, you've chosen option 1."
	echo
	read -p "Now set your top level domain, which will also be the part after the @ in your XMPP account addresses: " domain
	echo
	read -p "Is | $domain | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
	echo
	echo "Your hostname must be a third level domain [subdomain] of either $domain or another domain."
	echo
	echo "Your current hostname is | $hostname |"
	echo
	read -p "Do you want to change it? (Y/n): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]
	then
		read -p "Ok, now set your new hostname: " newhostname
		echo
		read -p "Is | $newhostname | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
		echo
		echo $newhostname > /etc/hostname
		echo "New hostname set to | $newhostname |"
		echo
		hostname="$(cat /etc/hostname)"
	else
		echo "Leaving hostname set to | $hostname |"
		echo
	fi

elif [ $configoption = 2 ]

then
	echo "Ok, you've chosen option 2."
	echo
	read -p "Now set your top level domain, the part after the @ in your XMPP account addresses: " domain
	echo
	read -p "Is | $domain | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
	echo
	echo "Your hostname must be identical to your domain: $domain."
	echo
	echo "Your current hostname is | $hostname |"
	echo
	if [ $hostname = $domain ]
	then
		echo "Your hostname matches your domain, all good!"
		echo
	else
		echo "Your hostname doesn't match the domain you've specified."
		echo
		echo "Having chosen option 2, they must be identical."
		echo
		read -p "Do you want to set your hostname to match your domain? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
		then
			echo "Ok, setting hostname to match domain."
			echo
			echo $domain > /etc/hostname
			echo "New hostname set to | $domain |"
			echo
			hostname="$(cat /etc/hostname)"
		else
			echo "Not changing hostname. Exiting..."
			echo
			exit
		fi
	fi

elif [ $configoption = 3 ]

then
	echo "Ok, you've chosen option 3."
	echo
	echo "The part after the @ in your XMPP account addresses will match your server hostname."
	echo
	echo "Your hostname will be a third level domain [subdomain] of your main domain."
	echo
	echo "Your current hostname is | $hostname |"
	echo
	echo "Make sure it is a subdomain of your main domain, and is it what you want it to be."
	echo
	read -p "That said, do you want to change it? (Y/n): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]
	then
		echo "Ok, now we'll be setting your new hostname."
		echo
		echo "Make sure it is a subdomain [third level domain] of your main domain, and keep in mind it will also become the part after the @ in your XMPP account addresses."
		echo
		read -p "Now specify your new new hostname: " newhostname
		echo
		read -p "Is | $newhostname | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
		echo
		echo $newhostname > /etc/hostname
		echo "New hostname set to | $newhostname |"
		echo
		hostname="$(cat /etc/hostname)"
	else
		echo "Leaving hostname set to | $hostname |"
		echo
	fi
		domain=$hostname
fi

sleep 1

echo "----------------"
echo
echo "To make sure everything is correct:"
echo
echo "1] Your XMPP domain [the part after the @ in your XMPP account addresses] will be:"
echo
echo "| $domain |"
echo
echo "2] And therefore an XMPP account address will look as follows:"
echo
echo "| mark@$domain|"
echo
echo "3] Your hostname, the location on the internet of this server, will be:"
echo
echo "| $hostname |"
echo
echo "4] And therefore your aenigma admin panel will be located at:"
echo
echo "| https://$hostname |"
echo
echo "----------------"
echo

read -p "Does everything look all right? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	echo "Ok, continuing."
	echo
else
	echo "Ok, no worries. You can re-run this script right now and make the correct choices. Exiting..."
	echo
	exit
fi

#!/bin/bash

thisip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
dignxcheck="$(getent hosts $hostname. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
digresult="$(getent hosts $hostname. | grep -oP '^\d+(\.\d+){3}\s')"
wwwdignxcheck="$(getent hosts www.$hostname. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
wwwdigresult="$(getent hosts www.$hostname. | grep -oP '^\d+(\.\d+){3}\s')"
xcdignxcheck="$(getent hosts xc.$hostname. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
xcdigresult="$(getent hosts xc.$hostname. | grep -oP '^\d+(\.\d+){3}\s')"
xudignxcheck="$(getent hosts xu.$hostname. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
xudigresult="$(getent hosts xu.$hostname. | grep -oP '^\d+(\.\d+){3}\s')"

echo "Now let's make sure your DNS settings are correct."
echo
echo "1] Now checking this machine's hostname in IPv4 on public DNS..."
echo
if [ $dignxcheck = "0" ]
then
	echo "The hostname does NOT appear to be at all set on public DNS."
	echo
	echo "Please ensure you set your DNS record as follows:"
	echo
	echo "| $hostname                    A      $ip |"
	echo
else
	if [ $digresult = $thisip ]
	then
		echo "The hostname appears to resolve correctly to this server on public DNS."
		echo
		echo "| $hostname                    A      $ip |"
		echo
	else
		echo "The hostname does NOT appear to correctly resolve to this server on public DNS."
		echo
		echo "This is the result of a dig query for this machine's hostname:"
		echo
		sleep 3
		dig +noall +answer $hostname
		echo
		echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
		echo
		read -p "Continue setup? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
		then
			echo "Ok, continuing..."
			echo
		else
			echo "Ok, exiting..."
			echo
			exit
		fi
	fi
fi

sleep 1

echo "2] Now checking this machine's hostname's www. subdomain in IPv4 on public DNS..."
echo
echo "The www.$hostname subdomain record is required for the TLS certificate we'll be generating later."
echo
if [ $wwwdignxcheck = "0" ]
then
	echo "The www.$hostname record does NOT appear to be at all set on public DNS."
	echo
	echo "Please ensure you set your DNS record as follows:"
	echo
	echo "| www.$hostname                A      $ip |"
	echo
else
	if [ $wwwdigresult = $thisip ]
	then
		echo "The www.$hostname record appears to resolve correctly to this server on public DNS."
		echo
		echo "| www.$hostname                A      $ip |"
		echo
	else
		echo "The www.$hostname record does NOT appear to correctly resolve to this server on public DNS."
		echo
		echo "This is the result of a dig query for this machine's hostname's www. subdomain:"
		echo
		sleep 3
		dig +noall +answer www.$hostname
		echo
		echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
		echo
		read -p "Continue setup? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
		then
			echo "Ok, continuing..."
			echo
		else
			echo "Ok, exiting..."
			echo
			exit
		fi
	fi
fi

sleep 1

echo "3] Now checking this machine's hostname's xc. subdomain in IPv4 on public DNS..."
echo
echo "The xc.$hostname subdomain record is required for XMPP messaging groups [aka conferences / MUCs in XMPP lingo]"
echo
if [ $xcdignxcheck = "0" ]
then
	echo "The xc.$hostname record does NOT appear to be at all set on public DNS."
	echo
	echo "Please ensure you set your DNS record as follows:"
	echo
	echo "| xc.$hostname                 A      $ip |"
	echo
else
	if [ $xcdigresult = $thisip ]
	then
		echo "The xc.$hostname record appears to resolve correctly to this server on public DNS."
		echo
		echo "| xc.$hostname                 A      $ip |"
		echo
	else
		echo "The xc.$hostname record does NOT appear to correctly resolve to this server on public DNS."
		echo
		echo "This is the result of a dig query for this machine's hostname's xc. subdomain:"
		echo
		sleep 3
		dig +noall +answer xc.$hostname
		echo
		echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
		echo
		read -p "Continue setup? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
		then
			echo "Ok, continuing..."
			echo
		else
			echo "Ok, exiting..."
			echo
			exit
		fi
	fi
fi

sleep 1

echo "4] Now checking this machine's hostname's xu. subdomain in IPv4 on public DNS..."
echo
echo "The xu.$hostname subdomain record is required for XMPP HTTP uploads."
echo
if [ $xudignxcheck = "0" ]
then
	echo "The xu.$hostname record does NOT appear to be at all set on public DNS."
	echo
	echo "Please ensure you set your DNS record as follows:"
	echo
	echo "| xu.$hostname                 A      $ip |"
	echo
else
	if [ $xudigresult = $thisip ]
	then
		echo "The xu.$hostname record appears to resolve correctly to this server on public DNS."
		echo
		echo "| xu.$hostname                 A      $ip |"
		echo
	else
		echo "The xu.$hostname record does NOT appear to correctly resolve to this server on public DNS."
		echo
		echo "This is the result of a dig query for this machine's hostname's xu. subdomain:"
		echo
		sleep 3
		dig +noall +answer xu.$hostname
		echo
		echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
		echo
		read -p "Continue setup? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
		then
			echo "Ok, continuing..."
			echo
		else
			echo "Ok, exiting..."
			echo
			exit
		fi
	fi
fi

sleep 1

if [ $configoption = 1 ]
then

	additionalTLScertmode=elsewhere
	echo "Since you've chosen option 1, your domain is different from your hostname."
	echo
	echo "Therefore, we have to set some DNS 'SRV' records which will direct XMPP connections for $domain accounts to this server."
	echo
	echo "Make sure your DNS settings are as follows:"
	echo
	echo "| _jabber._tcp.$domain         SRV    0 0 5269 $hostname. |"
	echo "| _xmpp-server._tcp.$domain    SRV    0 0 5269 $hostname. |"
	echo "| _xmpp-client._tcp.$domain    SRV    0 0 5222 $hostname. |"
	echo
	read -p "[press enter to continue when finished setting your DNS SRV records...]"
	echo

	echo "Now it's time to set up the TLS [SSL] certificate that is valid for $domain."
	echo
  echo "The certificate file required for aenigma must be an all-in-one private key + certificate + chain file."
  echo
  echo "This means the file must include, in this order, the following:"
  echo
  echo "1] Private key; 2] Leaf [server] cert; 3] Certification Chain [Intermediate cert(s) + Root cert]"
  echo
  read -p "[press enter to continue reading...]"
  echo
  echo "This certificate, if it already exists, resides on the server responding to $domain"
  echo
	echo "This is usually a web server, but check your domain/hosting infrastructure to see what server it is."
	echo
	echo "This is the IP to which your bare domain $domain is pointing to:"
	echo
	dig +noall +answer $domain
	echo
  echo "[If you see no output, then it might be misconfigured or not configured at all.]"
  echo
  read -p "[press enter to continue reading...]"
  echo
	read -p "That said, do you have a running server that responds to $domain? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]
        then
		read -p "Ok, does this server have a configured TLS [SSL] certificate up and running on it? (Y/n): " -n 1 -r
	        echo
	        if [[ ! $REPLY =~ ^[Nn]$ ]]
	        then
			read -p "Ok, is this a Linux server? (Y/n): " -n 1 -r
                        echo
                        if [[ ! $REPLY =~ ^[Nn]$ ]]
                        then
				read -p "Ok, is this a Letsencrypt certificate? [if unsure, answer no] (Y/n): " -n 1 -r
	                	echo
	                	if [[ ! $REPLY =~ ^[Nn]$ ]]
	                	then
					echo "Very good, therefore access that server as root [or using sudo], and download this script in the root user's home directory:"
					echo
					echo "https://github.com/nikksno/LetsEncrypt-Cert-Push"
					echo
					echo "Now configure it to push its LE TLS cert to this server by following the instructions."
					echo
				else
					echo "Ok, no problem, you can adapt this script:"
					echo
					echo "https://github.com/nikksno/LetsEncrypt-Cert-Push"
                                        echo
					echo "To have it fetch and concatenate your existing private key, TLS cert, and certification chain on the other server and push the resulting all-in-one file here periodically."
					echo
					echo "Follow the instructions and adapt the paths to the existing TLS certs and private key."
					echo
				fi
			else
				echo "Ok, no problem, find your TLS certificate and related files on the other server and make a simple script to periodically concatenate your existing private key, TLS cert, and certification chain on the other server and send the resulting all-in-one file over to this server, or copy it here manually [and remember to copy it over again every time you renew the cert!]."
				echo
			fi
		else
			read -p "Ok, no problem. Is this server a linux server? (Y/n): " -n 1 -r
                        echo
                        if [[ ! $REPLY =~ ^[Nn]$ ]]
                        then
				echo "Very good. You can therefore install letsencrypt on the other server, generate a cert for $domain, and copy it over here with this script:"
				echo
				echo "https://github.com/nikksno/LetsEncrypt-Cert-Push"
				echo
			else
				echo "Ok, no problem, get a TLS certificate, install it and its related files on the other server, and make a simple script to periodically concatenate your existing private key, TLS cert, and certification chain on the other server and send the resulting all-in-one file over to this server, or copy it here manually [and remember to copy it over again every time you renew the cert!]."
				echo
			fi
		fi
		read -p "Now, in whatever way you've installed or copied to this server the all-in-one TLS cert file for $domain, specify its absolute path [i.e. /home/username/domain.pem] on this server now: " domtlscertloc
		echo
		read -p "Is | $domtlscertloc | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
		echo
	else
		echo "Ok, so we'll point $domain to this server and provision a TLS certificate for it on this very server."
		echo
		echo "If you ever add a new server to respond to $domain [a webserver for instance], simply make sure you periodically send the TLS certificate you'll generate on the new server back here, either by using this script on the new server:"
		echo
		echo "https://github.com/nikksno/LetsEncrypt-Cert-Push"
		echo
		echo "[or an adaptation of it] or by doing some other manual scripting that periodically fetches the TLS cert and all of its related files on the other server, concatenates your private key, TLS cert, and certification chain on the other server, and sends the resulting all-in-one file over to this server, [and does so again every time you renew the cert!]."
    echo
    echo "For now, no need to worry about that."
		echo
		echo "Let's point $domain and www.$domain to this server for the time being."
		echo
		echo "The www.$domain subdomain record is required for the TLS certificate we'll be generating shortly on this server."
		echo

		additionalTLScertmode=here
		domdignxcheck="$(getent hosts $domain. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
		domdigresult="$(getent hosts $domain. | grep -oP '^\d+(\.\d+){3}\s')"
		domwwwdignxcheck="$(getent hosts $domain. | grep -oP '^\d+(\.\d+){3}\s' | wc -l)"
		domwwwdigresult="$(getent hosts $domain. | grep -oP '^\d+(\.\d+){3}\s')"

		if [ $domdignxcheck = "0" ]
		then
			echo "The domain does NOT appear to be at all set on public DNS."
			echo
			echo "Please ensure you set your DNS record as follows:"
			echo
			echo "| $domain                      A      $ip |"
			echo
		else
			if [ $domdigresult = $thisip ]
			then
				echo "The domain appears to already resolve correctly to this server on public DNS."
				echo
				echo "| $domain                      A      $ip |"
				echo
			else
				echo "The domain does NOT yet appear to correctly resolve to this server on public DNS."
				echo
				echo "This is the result of a dig query for $domain:"
				echo
				sleep 3
				dig +noall +answer $domain
				echo
				echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
				echo
				read -p "Continue setup? (Y/n): " -n 1 -r
				echo
				if [[ ! $REPLY =~ ^[Nn]$ ]]
				then
					echo "Ok, continuing..."
					echo
				else
					echo "Ok, exiting..."
					echo
					exit
				fi
			fi
		fi

		if [ $domwwwdignxcheck = "0" ]
		then
			echo "The domain's www. subdomain does NOT appear to be at all set on public DNS."
			echo
			echo "Please ensure you set your DNS record as follows:"
			echo
			echo "| www.$domain                  A      $ip |"
			echo
		else
			if [ $domwwwdigresult = $thisip ]
			then
				echo "The domain's www. subdomain appears to already resolve correctly to this server on public DNS."
				echo
				echo "| www.$domain                  A      $ip |"
				echo
			else
				echo "The domain's www. subdomain does NOT yet appear to correctly resolve to this server on public DNS."
				echo
				echo "This is the result of a dig query for www.$domain:"
				echo
				sleep 3
				dig +noall +answer www.$domain
				echo
				echo "If you think this result is not accurate or if you've just now corrected this issue, please continue."
				echo
				read -p "Continue setup? (Y/n): " -n 1 -r
				echo
				if [[ ! $REPLY =~ ^[Nn]$ ]]
				then
					echo "Ok, continuing..."
					echo
				else
					echo "Ok, exiting..."
					echo
					exit
				fi
			fi
		fi
	fi
fi

echo "Now setting UFW rules..."
echo
echo "1] ufw allow 5222"
echo "2] ufw allow 5269"
echo "3] ufw allow 5444"
echo "4] ufw allow 80"
echo "5] ufw allow 443"
ufw allow 5222
ufw allow 5269
ufw allow 5444
ufw allow 80
ufw allow 443
echo "Finished setting UFW rules."
echo
sleep 1

echo "Now installing easyengine..."
echo
wget -qO ee rt.cx/ee && sudo bash ee
echo "Finished installing easyengine."
echo
sleep 1

echo "Now creating easyengine site for $hostname, generating its TLS certificate, and installing it..."
echo
ee site create $hostname
ee site update $hostname  --le
echo "Finished creating easyengine site for $hostname."
echo
sleep 1

echo "Now creating all-in-one TLS file for $hostname for ejabberd..."
echo
touch /opt/ejabberd-17.08/conf/hostname.pem
cat /etc/letsencrypt/live/$hostname/privkey.pem > /opt/ejabberd-17.08/conf/hostname.pem
cat /etc/letsencrypt/live/$hostname/fullchain.pem >> /opt/ejabberd-17.08/conf/hostname.pem
echo "Finished creating all-in-one TLS file for $hostname for ejabberd."
echo
sleep 1

echo "Now setting custom nginx config for $hostname..."
echo
wget -qO nginx.conf https://raw.githubusercontent.com/openspace42/aenigma/master/nginx.conf
sed -i "s/example.im/${hostname}/g" nginx.conf
cp nginx.conf /etc/nginx/sites-available/$hostname
service nginx reload
echo "Finished setting custom nginx config for $hostname."
echo
sleep 1

echo "Now setting index.html in docroot for $hostname..."
echo
wget -qO index.html https://raw.githubusercontent.com/openspace42/aenigma/master/index.html
mv index.html /var/www/$hostname/htdocs/
echo "Finished setting index.html in docroot for $hostname."
echo
sleep 1

echo "Now generating DHparams..."
echo
#openssl dhparam -out /opt/ejabberd-17.08/conf/dh.pem 4096
echo "Finished generating DHparams."
echo
sleep 1

if [ $additionalTLScertmode = "here" ]
then

  echo "Since you've chosen to provision a TLS certificate for $domain on this server, now we're now going to do so."
  echo

  echo "Now creating easyengine site for $domain, generating its TLS certificate, and installing it..."
  echo
	ee site create $domain
	ee site update $domain --le
  echo "Finished creating easyengine site for $domain."
  echo
  sleep 1

  echo "Now creating all-in-one TLS file for $domain for ejabberd..."
  echo
  touch /opt/ejabberd-17.08/conf/domain.pem
	cat /etc/letsencrypt/live/$domain/privkey.pem > /opt/ejabberd-17.08/conf/domain.pem
	cat /etc/letsencrypt/live/$domain/fullchain.pem >> /opt/ejabberd-17.08/conf/domain.pem
	domtlscertloc=/opt/ejabberd-17.08/conf/domain.pem
  echo "Finisher creating all-in-one TLS file for $domain for ejabberd..."
  echo
  sleep 1

fi

echo "Now downloading ejabberd..."
echo
wget -qO ejabberd_17.08-0_amd64.deb https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/17.08/ejabberd_17.08-0_amd64.deb
echo "Finished downloading ejabberd."
echo
sleep 1

echo "Now installing ejabberd..."
echo
dpkg -i ejabberd_17.08-0_amd64.deb
echo "Finished installing ejabberd."
echo
sleep 1

echo "Now setting custom aenigma config to ejabberd.yml..."
echo
wget -qO aenigma-ejabberd.yml https://raw.githubusercontent.com/openspace42/aenigma/master/ejabberd-1708.yml
sed -i "s/example.im/${domain}/g" aenigma-ejabberd.yml
if [ $configoption = 1 ]
then
  wget -qO ejabberd-tlsaddition.txt https://raw.githubusercontent.com/openspace42/aenigma-server/master/ejabberd-tlsaddition.txt
  sed -i "s|example.im|${domain}|g" ejabberd-tlsaddition.txt
  sed -i "s|pathtofile|${domtlscertloc}|g" ejabberd-tlsaddition.txt
  sed -i '/## aenigma_host_config_placeholder_start:/,/## aenigma_host_config_placeholder_end:/{//!d}' aenigma-ejabberd.yml
  sed -i '/## aenigma_host_config_placeholder_start:/ r ejabberd-tlsaddition.txt' aenigma-ejabberd.yml
fi
cp aenigma-ejabberd.yml /opt/ejabberd/conf/ejabberd.yml
# cp aenigma-ejabberd.yml /opt/ejabberd-17.08/conf/ejabberd.yml #shouldn't be needed
echo "Finished setting custom aenigma config to ejabberd.yml."
echo
sleep 1

echo "Now starting ejabberd..."
echo
/opt/ejabberd-17.08/bin/ejabberdctl start
echo
sleep 8
/opt/ejabberd-17.08/bin/ejabberdctl status
echo
sleep 1
echo "Finished starting ejabberd."
echo
sleep 1

echo "Now registering ejabberd admin user..."
echo
ejbdadminpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
/opt/ejabberd-17.08/bin/ejabberdctl register admin $domain $ejbdadminpw
echo "Finished registering ejabberd admin user"
echo
sleep 1

echo "Now log in:"
echo
echo "https://$hostname"
echo
echo "admin@$domain"
echo $ejbdadminpw
echo

echo "All done!"
echo

exit
