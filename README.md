# classroomLEDs

There are three components that comprise this project:

* raspi: A python script that reads the schedule of scenes from the server and controls the LEDs.
* server: A node.js server that publishes a CRUD API.
* mobileApp: A flutter app that displays the scenes and supports editing the scenes.


## raspi

### installation

* Start with a clean installation of raspios. This project was created with all full image of buster.
* Step through the Welcome to Raspberry Pi wizard, including updating software.
* [Enable SPI](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-4-gpio-setup/configuring-spi) on the Raspberry Pi and reboot.
* Clone this repository.
* Change to the raspi directory.
* Create a python virtual environment: `$ python3 -m venv venv`
* Activate the virtual environment: `$ source venv/bin/activate`
* Upgrade the setuptools module: `$ pip install --upgrade setuptools`
* Install the required python modules: `$ pip install -r requirements.txt`
* Run the python script : `$ python classroomLEDs.py`

### hardware configuration

This component is designed drive Adafruit DotStar LEDs using SPI.

* The black wire from the breadboard should be connected to the Pi GND
* The yellow wire to the Pi SCLK
* The green wire, to the Pi MOSI

Adafruit has a [tutorial](https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython#python-computer-wiring-3004880-8) for wiring DotStar LEDs to the Raspberry Pi. Note that given the number of LEDs being driven, this system is designed to be used with an external 5V, 10A power supply.

* The LED strip connects to the power supply via the 2.1 mm jack.
* The LED strip connects to the breadboard via the 4-pin JST SM receptacle. 

### design

Adafruit [recommends](https://learn.adafruit.com/adafruit-neopixel-uberguide/powering-neopixels) adding a large capacitor (1000 µF, 6.3V) across power and ground. The breadboard has a 4700 µF capacitor across power and ground.

DotStars are 5 V devices and the Raspberry Pi provides 3.3 V. Therefore, as [recommended](https://learn.adafruit.com/adafruit-dotstar-leds/power-and-connections#connecting-dotstar-leds-3004523-2) by Adafruit, the [74AHCT125 quad level-shifter](https://www.adafruit.com/product/1787) is used to boost the 3V signals to 5V.


## server

### Production Server Deployment

Based on [this tutorial](https://ourcodeworld.com/articles/read/977/how-to-deploy-a-node-js-application-on-aws-ec2-server).

* Create a new EC2 instance used on Ubuntu.
* Open ports for HTTP and HTTPS when walking through the EC2 wizard.
* Generate a key pair for this EC2 instance. Download and save the private key, which is needed to connect to the instance in the future.
* After the EC2 instance is running, click on the Connect button the EC2 Management Console for instructions on how to ssh into the instance.
* On the EC2 instance, [install Node.js v10](https://github.com/nodesource/distributions/blob/master/README.md)
	`curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -`
    `sudo apt-get install -y nodejs`
* [Install certbot](https://itnext.io/node-express-letsencrypt-generate-a-free-ssl-certificate-and-run-an-https-server-in-5-minutes-a730fbe528ca) to automate the generation and maintenance of SSL certificates so HTTPS works:
	`sudo add-apt-repository ppa:certbot/certbot`
	`sudo apt-get update`
	`sudo apt-get install certbot`
* Generate an SSL certificate:
	`sudo certbot certonly --manual`
	*specify scouting.team3061.org as the domain name*
	*make a note of the a-string and a-challenge*
	*pause here and ssh into the EC2 instance in another terminal]*
* In the home directory, create:
	`mkdir server`
	`cd server/`
	`mkdir .well-known`
	`cd .well-known/`
	`mkdir acme-challenge`
	`cd acme-challenge/`
	`vi <a-string>`
	*paste <a-challenge> into this file*
* Back in the server directory, [create a node server](https://gist.github.com/DavidMellul/2afcd7ecbe6ad83894972af8a2e0d536/raw/f207f9df6a96852c828462d17964ab231739eb2c/HTTPChallengeServer.js) to authenticate for the SSL certificate:
	`vi HTTPChallengeServer.js`
* Start the HTTPChallengeServer node server:
	`sudo node HTTPChallengeServer.js`
* In a browser, go to the following page to authenticate for the SSL certificate:
	`http://<EC2 instance ip>/.well-known/acme-challenge/<a-string>` (replace a-string with the actual string)
* The browser will download the challenge file. If that works, continue.
* Go back to the terminal that is in the process of creating the certificate and press enter to continue.
* Kill the HTTPChallengeServer node server.
* Add a crontab entry to renew the SSL certificate:
	`crontab -e`
	`0 */12 * * * root /usr/local/bin/certbot renew >/dev/null 2>&1`
* Generate a [new SSH key for GitHub](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) *without a passphrase* and add it to GitHub.
* Clone this repository.
* Inside of the server directory for this repository:
	`npm install`
	`node app.js`
* Copy the public DNS from the EC2 Management Console, and connect to the app in a browser.
* Back on the EC2 instance, kill the node server.
* Install Production Manager 2, which is used to keep the node server running and restart it when changes are pushed to master:
	`sudo npm install pm2 -g`
	`sudo pm2 start app.js`
* Verify that the node server is running:
	`sudo pm2 list`
* Configure pm2 to automatically run when the EC2 instance restarts:
	`sudo pm2 startup`
* Add a crontab entry to pull from GitHub every minute:
	`crontab -e`
	`*/1 * * * * cd /home/ubuntu/classroomLEDs && git pull`
* Restart the node server:
	`sudo pm2 restart app`
	
### design

The server provides a CRUD JSON API for multiple LED strips and multiple scenes per LED strip.

All of the LED strips and their scenes can be retrieved with a GET request to /leds.

Each LED strip has an ID and a list of scenes. The attributes of a specific LED strip, including its scenes, can be retrieved with a GET request to /leds/*ledID*.

All of the scenes of a specific LED strip, can be retrieved with a GET request to /leds/*ledID*/scenes. In addition, new scenes can be created with a POST request.

Each scene has an ID, a time (stored as an ISO 8601 string where the date is ignored at the moment), a color (stored as an 8-digit hex string: alpha, red, green, blue), a brightness (stored as a floating point value between 0 and 1), and a mode (stored as a string; currently "solid" and "pulse" are supported). The attributes of a specific scene, can be retrieved with a GET request to /leds/*ledID*/scenes/*sceneID*. A specific scene can be updated with a PUT request or deleted with DELETE request.

The main thread in the script gets the scenes for the LED strip with ID 1 every 60 seconds. The most recent scene whose time has passed determines the state of the LEDs. The LEDs are updated in a separate thread every 10 milliseconds to support the pulse mode.


## mobileApp

### installation

* [Setup](https://flutter.dev/docs/get-started/install) the machine to support Flutter development.
* Clone this repository.
* Open the mobileApp/classroomLEDs folder in VS Code
* Run the app.

### design

