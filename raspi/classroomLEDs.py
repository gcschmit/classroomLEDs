import time
import requests
from requests.exceptions import HTTPError
import adafruit_dotstar as dotstar
import board

num_pixels = 10

pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=16000000)

while True:

    try:
        url = "http://192.168.1.139:3000/leds/1"
        response = requests.get(url = url)
        response.raise_for_status()
        
        jsonResponse = response.json()
        print(jsonResponse)
        
        weekday_schedule = jsonResponse["weekdaySchedule"]
        print(weekday_schedule)
        
        weekday_schedule.sort(key=lambda k: k['time'])
        
        for event in weekday_schedule:
        	print(event)
        	print(event["time"])
        	print(event["color"])
        	print(event["brightness"])
        	print(event["mode"])
        	
        	time = datetime.strptime(event["time"], '%Y-%m-%dT%H:%M:%S.%fZ')
        	print(time)
        	
        	if time < datetime.now():        	
	        	led_color = tuple(int(event["color"][i:i+2], 16) for i in (2, 4, 6))
	        	led_brightness = event["brightness"]
    	    	print(led_color)
    	    	print(led_brightness)
        
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')

    pixels.fill(led_color)
    pixels.brightness(led_brightness)
    pixels.show()
    
    time.sleep(10)
