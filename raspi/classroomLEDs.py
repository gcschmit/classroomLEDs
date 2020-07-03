import time
import datetime
import requests
from requests.exceptions import HTTPError
import adafruit_dotstar as dotstar
import board

num_pixels = 10
led_modes = {"solid": 0, "pulse": 1}
led_color = (0, 0, 0)
led_brightness = 0
led_mode = 0 # 0: solid; 1: pulse

def update_LEDs():
    # Use SPI on the Raspberry Pi which is faster than bit banging.
    # Explicitly slow the baud rate to 16 MHz using the undocumented parameter which
    #   appears to improve reliability.
    # The pixel order of the DotStar strips that we have appear to be BGR, but there are
    #   still unresolved issues regarding colors.   
    pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=16000000)
    
    
    while True:
        temp_led_brightness -= 0.05
        if temp_led_brightness < 0:
            temp_led_brightness = led_brightness
        
        if led_mode == 0:
            color_with_brightness = led_color + (led_brightness,)
        else:
            color_with_brightness = led_color + (temp_led_brightness,)
        
        pixels.fill(color_with_brightness)
        pixels.show()
        time.sleep(0.1)


led_thread = threading.Thread(target = update_LEDs, daemon=True)
led_thread.start()

while True:
    
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

    
    scenes = jsonResponse["scenes"]
    print(scenes)
    
    # don't assume that the scenes are sorted by time; it is important that they are
    #   since the LEDs will be set to the most recent scence whose time has passed
    scenes.sort(key=lambda k: k['time'])
    
    for scene in scenes:
        print(scene)
        print(scene["time"])
        print(scene["color"])
        print(scene["brightness"])
        print(scene["mode"])
        
        sch_date = datetime.datetime.strptime(scene["time"], '%Y-%m-%dT%H:%M:%S.%fZ')
        date_now = datetime.datetime.now()
        sch_time = datetime.time(sch_date.hour, sch_date.minute, sch_date.second)
        now = datetime.time(date_now.hour, date_now.minute, date_now.second)
        print(sch_time)
        print(now)
        
        if sch_time < now:
            # the color can be specified as a tuple with 4 elements: (R, G, B, brightness)
            led_color = tuple(int(scene["color"][i:i+2], 16) for i in (2, 4, 6))
            print(led_color)
            led_brightness = scene["brightness"]
            print(led_brightness)
            led_mode = led_modes[scene["mode"]]
            print(led_mode)
    
    # a more sophisticated approach is needed where the server is checked only 
    #   occasionally but the LEDs are updated based on the last-read schedule more
    #   frequently
    time.sleep(60)
