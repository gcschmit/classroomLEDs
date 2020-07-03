import time
import datetime
import requests
from requests.exceptions import HTTPError
import adafruit_dotstar as dotstar
import board

num_pixels = 10

# Use SPI on the Raspberry Pi which is faster than bit banging.
# Explicitly slow the baud rate to 16 MHz using the undocumented parameter which
#	appears to improve reliability.
# The pixel order of the DotStar strips that we have appear to be BGR, but there are
#	still unresolved issues regarding colors.	
pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=16000000)

while True:
    led_color = (0, 0, 0)

    try:
    	# eventually, update the URL to that for the server running on EC2
        url = "http://192.168.1.139:3000/leds/1"
        response = requests.get(url = url)
        response.raise_for_status()
        
        jsonResponse = response.json()
        print(jsonResponse)
        
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')

    
    weekday_schedule = jsonResponse["weekdaySchedule"]
    print(weekday_schedule)
    
    # don't assume that the scenes are sorted by time; it is important that they are
    #	since the LEDs will be set to the most recent scence whose time has passed
    weekday_schedule.sort(key=lambda k: k['time'])
    
    for event in weekday_schedule:
        print(event)
        print(event["time"])
        print(event["color"])
        print(event["brightness"])
        print(event["mode"])
        
        sch_time = datetime.datetime.strptime(event["time"], '%Y-%m-%dT%H:%M:%S.%fZ')
        now = datetime.datetime.now()
        print(sch_time)
        print(now)
        
        if sch_time < now:
        	# the color can be specified as a tuple with 4 elements: (R, G, B, brightness)
            led_color = tuple(int(event["color"][i:i+2], 16) for i in (2, 4, 6))
            led_color = led_color + (event["brightness"],)
            print(led_color)
        
    pixels.fill(led_color)
    pixels.show()
    
    # a more sophisticated approach is needed where the server is checked only 
    #	occasionally but the LEDs are updated based on the last-read schedule more
    #	frequently
    time.sleep(10)
