This is a Dockerfile that starts a freeradius server configured for doing EAP-TLS with the provided certificates.
TODO: test if we can remove the private key of the CA and this still works. 
   This will require to generate the CSR by hand instead of using make  
REMEMBER TO REPLACE ALL CERTIFICATES UNDER THE raddb/certs folder with your real certificates
1. Download your CA private key to the raddb/certs folder and fill out all the empty files 
2. Run the make server script inside the raddb/certs folder inside the live container 
s will generate your server private and public key on the correct formats. (UNtested import a server cert coming from the same CA)
3. export the generated server private keys to the raddb/certs/ folder (this is the cert that your clients will receive when they try connecting to your wpa-enterprise wifi
4. Generate a client certificate for testing inside the raddb/certs/ folder running make client inside the running container for temporary testing.  remember to read every line of the make file for errors
5. use intune to make the device generate a private key using SCEP or similar from the same Root CA that you copied the private key to the freeradius server and use that on eapol_test client



modify raddb/clients.cnf to allow your radius client/unifi access points / docker access to the server

when creating the intune wifi profile make sure to put the server.cnf commonName SCEPman-Device-Root-CA-V1 
This will prevent a popup to show up asking the user to verify that he is conencting to the correct server. 
First for testing disable ocsp_checking on the mods-enabled/eap file after you get basic certificate working then enable ocsp checking of the certificates.


The test/ folder contains test eapol_test scripts to test out different	aspect of the tls process
Running the start-docker.sh container and reading every line every time you make a request will help you find out the majority of the issues since they mostly will be obvious.

When using the sample test configuration files under test/* first comment out the line related to the ca_certificate and uncomment it back once you got the tls login process working to make sure it works when the client is validating the cvertificate authority

The most obscure issues are related to missing or having a certficiate or key in the wront format in the raddb/certs/ directory.

There is a example under mods-config/*/authorize on how to setup vlan to the TLS clients.

Note that the username that intune asigns to the wifi profiles is added in that file and AFAIK cannot be changed.

# WiFi Setup Documentation
## Using Freeradius as RADIUS server, Private CA, and Intune as SCEP client
### Freeradius
#### Summary
- TODO
#### Configuration and Setup
##### Docker Environment
Using https://github.com/annerajb/intune-tls-freeradius as a starting environment.

##### Initial Testing Methodology
###### RADIUS Server Setup
- Setup docker environment, and clone repository
- Create snakeoil certificates
    - Run "make"  in raddb/certs/
- Modify clients.conf
    - Change one of the subnets to match your client that will be connecting to your RADIUS server
- Modify eap
    - The primary lines that need to be updated are:
        - private_key_file
        - private_key_password
        - certificate_file
        - ca_file
        - ca_path 
            - .crl file is expected here and auth will not work without it
    - Other notable lines are:
        - tls_min_version
        - tls_max_version
        - use_nonce
    
- run start-docker.sh
    - This will stop, delete, and recreate the docker containers every time you run it, replacing it with the latest version from the freeradius/freeradius-server docker image
    - This also starts an interactive session in the docker container running "freeradius -X", which is the debug/verbose mode of freeradius

###### Test Client Setup
 - Install eapol_test
    - Linux/Ubuntu
        - https://wiki.geant.org/display/H2eduroam/Testing+with+eapol_test
    - Windows build
        - https://github.com/janetuk/eapol_test
- Copy client certs to user readable directory
    - ```mkdir ~/certs/ && cp ./raddb/certs/ ~/certs/```
    - Example config: tls.conf 
    ```#
    #   eapol_test -c {config file} -s {Radius secret} -a {Radius server}
    #   Ex "eapol_test -c tls.conf -s testing123 -a 192.168.0.10"
    #   Set also "nostrip" in raddb/proxy.conf, realm "example.com"
    #   And make it a LOCAL realm.
    #
    network={
	   key_mgmt=WPA-EAP
	   eap=TLS
	#  identity="user@example.org"
    #  User-Name = "intune id"
	   identity="12345678-1234-1234-1234-123456789012"
    #  ca_cert="raddb/certs/rsa/ca.pem"
    #  ca_cert="~/certs/prod/ca.pem"
       ca_cert="~/certs/ca.crt"

    #  client_cert="raddb/certs/rsa/client.crt"
    #  client_cert="~/certs/prod/client.crt"
       client_cert="~/certs/client.crt"

    #   private_key="raddb/certs/rsa/client.key"
    #   private_key="~/certs/prod/client.key"
        private_key="~/certs/client.key"

    	private_key_passwd="whatever"

	    phase1="tls_disable_session_ticket=0"
    }
```

###### How to Use
- Create snakeoil certificates
- Modify clients.conf
- Modify eap
- run start-docker.sh
    - This will stop, delete, and recreate the docker containers every time you run it, replacing it with the latest version from the freeradius/freeradius-server docker image
    - This also starts an interactive session in the docker container running "freeradius -X", which is the debug/verbose mode of freeradius

### CA Setup
- Setup environment
    - TODO
- Create certificate for server and save to raddb/certs/
    - Easiest to use .pem file with both private key and cert
    - You will need to either update the eap file fields (replacing server.pem) with the new certificate name, or you can rename the certificate to match the configuration
    - Fix permissions (sudo chown -R $USER:$USER ./raddb/certs/)
- Make sure firewall is allowing inbound traffic to port 1812
- If testing certificate validation, there may need to be a match between the hostname and the certificate. This was not necessary with the snakeoil certificates during testing

### Intune Setup
- TODO
