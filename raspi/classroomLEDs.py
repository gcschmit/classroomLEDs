import time
import datetime
import requests
import threading
from requests.exceptions import HTTPError
import adafruit_dotstar as dotstar
import board

num_pixels = 180
led_modes = {"solid": 0, "pulse": 1}
led_color = (0, 0, 0)
led_brightness = 0
led_mode = 0 # 0: solid; 1: pulse

def update_LEDs(lock):
    # Use SPI on the Raspberry Pi which is faster than bit banging.
    # Explicitly slow the baud rate to 16 MHz using the undocumented parameter which
    #   appears to improve reliability.
    # The pixel order of the DotStar strips that we have appear to be BGR, but there are
    #   still unresolved issues regarding colors.   
    pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=16000000)
    
    temp_led_brightness = 0;
    dimming = True;
    
    while True:
        if led_mode == 0:
        	lock.acquire()
            color_with_brightness = led_color + (led_brightness,)
            lock.release()
            pixels.fill(color_with_brightness)
            pixels.show()
            time.sleep(4)
        else:
            if dimming:
                temp_led_brightness -= 0.005
            else:
                temp_led_brightness += 0.005
        
            if temp_led_brightness < 0:
                temp_led_brightness = 0 
                dimming = False
            elif temp_led_brightness > led_brightness:
                temp_led_brightness = led_brightness
                dimming = True
        
        	lock.acquire()
            color_with_brightness = led_color + (temp_led_brightness,)
            lock.release()
            pixels.fill(color_with_brightness)
            pixels.show()
            time.sleep(0.01)


# create a semaphore used to protect the led_color and led_brightness variables
lock = threading.Lock()
led_thread = threading.Thread(target = update_LEDs, args=(lock,), daemon=True)
led_thread.start()



while True:
    
    try:
        url = "https://classroomLEDs.nnhsse.org/leds/1"
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
    scenes.sort(key=lambda k: k['start_time'])
    
    for scene in scenes:
        print(scene)
        print(scene["start_time"])
        print(scene["color"])
        print(scene["brightness"])
        print(scene["mode"])

        if "day_of_week" in scene:
            week_days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
            day_of_week = scene["day_of_week"]
            current_weekday = datetime.datetime.today().weekday();
            if week_days[current_weekday] == day_of_week:
                sch_date = datetime.datetime.strptime(scene["start_time"], '%Y-%m-%dT%H:%M:%S.%f')
                date_now = datetime.datetime.now()
                sch_time = datetime.time(sch_date.hour, sch_date.minute, sch_date.second)
                now = datetime.time(date_now.hour, date_now.minute, date_now.second)
                print(sch_time)
                print(now)
        
                if sch_time < now:
                    # the color can be specified as a tuple with 4 elements: (R, G, B, brightness)
                    temp_led_color = tuple(int(scene["color"][i:i+2], 16) for i in (2, 4, 6))
                    print(temp_led_color)
                    temp_led_brightness = scene["brightness"]
                    print(temp_led_brightness)
                    temp_led_mode = led_modes[scene["mode"]]
                    print(temp_led_mode)
        elif "date" in scene:
            sch_date = datetime.datetime.strptime(scene["date"], '%Y-%m-%dT%H:%M:%S.%f')
            date_now = datetime.datetime.now()
            if(sch_date.year == date_now.year and sch_date.month == date_now.month and sch_date.day == date_now.day):
                # the color can be specified as a tuple with 4 elements: (R, G, B, brightness)
                temp_led_color = tuple(int(scene["color"][i:i+2], 16) for i in (2, 4, 6))
                print(temp_led_color)
                temp_led_brightness = scene["brightness"]
                print(temp_led_brightness)
                temp_led_mode = led_modes[scene["mode"]]
                print(temp_led_mode)
        elif "override_duration" in scene:
                sch_date = datetime.datetime.strptime(scene["start_time"], '%Y-%m-%dT%H:%M:%S.%f')
                date_now = datetime.datetime.now()
                sch_time = datetime.time(sch_date.hour, sch_date.minute, sch_date.second)
                now = datetime.time(date_now.hour, date_now.minute, date_now.second)
                override_end = datetime.time(sch_date.hour, sch_date.minute + scene["override_duration"], sch_date.second)
                print(sch_time)
                print(now)
                print(override_end)
        
                if sch_time < now and (scene["override_duration"] == 0 or override_end > now):
                    # the color can be specified as a tuple with 4 elements: (R, G, B, brightness)
                    temp_led_color = tuple(int(scene["color"][i:i+2], 16) for i in (2, 4, 6))
                    print(temp_led_color)
                    temp_led_brightness = scene["brightness"]
                    print(temp_led_brightness)
                    temp_led_mode = led_modes[scene["mode"]]
                    print(temp_led_mode)
    
    lock.acquire()
    led_color = temp_led_color;
    led_brightness = temp_led_brightness;
    led_mode = temp_led_mode;
    lock.release()

    print("color", led_color)
    print("brightness", led_brightness)
    print("mode", led_mode)
    
    # a more sophisticated approach is needed where the server is checked only 
    #   occasionally but the LEDs are updated based on the last-read schedule more
    #   frequently
    time.sleep(5)