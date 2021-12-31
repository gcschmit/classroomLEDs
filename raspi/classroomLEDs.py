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
scenes = []

# create a lock used to protect the led_color and led_brightness variables from race conditions
#   should really use an event to signal the thread that the LEDs have changed
color_lock = threading.Lock()
scenes_lock = threading.Lock()


def update_LEDs():
    global led_mode
    global led_color
    global led_brightness
    
    # Use SPI on the Raspberry Pi which is faster than bit banging.
    # Explicitly slow the baud rate to 1.6 MHz using the undocumented parameter which
    #   appears to improve reliability.
    # The pixel order of the DotStar strips that we have appear to be BGR, but there are
    #   still unresolved issues regarding colors.   
    pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=1600000)
    
    temp_led_brightness = 0;
    dimming = True;
    
    while True:
        if led_mode == 0:
            color_lock.acquire()
            color_with_brightness = led_color + (led_brightness,)
            color_lock.release()
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
        
            color_lock.acquire()
            color_with_brightness = led_color + (temp_led_brightness,)
            color_lock.release()
            pixels.fill(color_with_brightness)
            pixels.show()
            time.sleep(0.01)


def update_scene():
    global scenes
    
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

        scenes_lock.acquire()
        scenes = jsonResponse["scenes"]
        scenes_lock.release()
        
        time.sleep(600)


scenes_thread = threading.Thread(target = update_scene, daemon=True)
scenes_thread.start()
led_thread = threading.Thread(target = update_LEDs, daemon=True)
led_thread.start()


temp_led_color = (0, 0, 0)
temp_led_brightness = 0
temp_led_mode = 0

while True:
    
    scenes_lock.acquire()
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
    
    scenes_lock.release()
    
    color_lock.acquire()
    led_color = temp_led_color;
    led_brightness = temp_led_brightness;
    led_mode = temp_led_mode;
    color_lock.release()

    print("color", led_color)
    print("brightness", led_brightness)
    print("mode", led_mode)
    
    time.sleep(5)