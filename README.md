# classroomLEDs

There are three components that comprise this project:

* raspi: A python script that reads the schedule of scenes from the server and controls the LEDs.
* server: A node.js server that publishes a REST API


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