import time
import requests
from requests.exceptions import HTTPError
import adafruit_dotstar as dotstar
import board

num_pixels = 150

pixels= dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=dotstar.BGR, auto_write=False, baudrate=16000000)


def wheel(pos):
    # Input a value 0 to 255 to get a color value.
    # The colours are a transition r - g - b - back to r.
    if pos < 0 or pos > 255:
        return (0, 0, 0)
    if pos < 85:
        return (255 - pos * 3, pos * 3, 0)
    if pos < 170:
        pos -= 85
        return (0, 255 - pos * 3, pos * 3)
    pos -= 170
    return (pos * 3, 0, 255 - pos * 3)


def color_fill(color, wait):
    pixels.fill(color)
    pixels.show()
    time.sleep(wait)


def slice_alternating(wait):
    pixels[::2] = [RED] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[1::2] = [ORANGE] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[::2] = [YELLOW] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[1::2] = [GREEN] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[::2] = [TEAL] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[1::2] = [CYAN] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[::2] = [BLUE] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[1::2] = [PURPLE] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[::2] = [MAGENTA] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)
    pixels[1::2] = [WHITE] * (num_pixels // 2)
    pixels.show()
    time.sleep(wait)


def slice_rainbow(wait):
    pixels[::6] = [RED] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)
    pixels[1::6] = [ORANGE] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)
    pixels[2::6] = [YELLOW] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)
    pixels[3::6] = [GREEN] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)
    pixels[4::6] = [BLUE] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)
    pixels[5::6] = [PURPLE] * (num_pixels // 6)
    pixels.show()
    time.sleep(wait)


def rainbow_cycle(wait):
    for j in range(255):
        for i in range(num_pixels):
            rc_index = (i * 256 // num_pixels) + j
            pixels[i] = wheel(rc_index & 255)
        pixels.show()
        time.sleep(wait)


RED = (255, 0, 0)
YELLOW = (255, 150, 0)
ORANGE = (255, 40, 0)
GREEN = (0, 255, 0)
TEAL = (0, 255, 120)
CYAN = (0, 255, 255)
BLUE = (0, 0, 255)
PURPLE = (180, 0, 255)
MAGENTA = (255, 0, 20)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

while True:

    try:
        url = "http://192.168.1.139:3000/leds/1"
        response = requests.get(url = url)
        response.raise_for_status()
        jsonResponse = response.json()
        print(jsonResponse)
        print(jsonResponse["color"])
        led_color = tuple(int(jsonResponse["color"][i:i+2], 16) for i in (2, 4, 6))
        print(led_color)
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')

#modes = { dotstar.BGR, dotstar.BRG, dotstar.GBR, dotstar.GRB, dotstar.GRB, dotstar.RBG, dotstar.RGB }

#for mode in modes:
    #pixels = dotstar.DotStar(board.SCK, board.MOSI, num_pixels, brightness=0.2, pixel_order=mode, auto_write=False, baudrate=16000000)

    #print(mode)

    # Change this number to change how long it stays on each solid color.
    #color_fill(BLACK, 1.5)
    #color_fill(RED, 1.5)
    #color_fill(YELLOW, 1.5)
    #color_fill(ORANGE, 1.5)
    #color_fill(GREEN, 1.5)
    #color_fill(TEAL, 1.5)
    #color_fill(CYAN, 1.5)
    #color_fill(BLUE, 1.5)
    #color_fill(PURPLE, 1.5)
    #color_fill(MAGENTA, 1.5)
    #color_fill(WHITE, 1.5)
    color_fill(led_color, 1.5)
    pixels[0] = led_color
    pixels[2] = led_color

    # Increase or decrease this to speed up or slow down the animation.
    #slice_alternating(0.1)

    #color_fill(WHITE, 0.5)

    # Increase or decrease this to speed up or slow down the animation.
    #slice_rainbow(0.1)

    time.sleep(0.5)

    # Increase this number to slow down the rainbow animation.
    #rainbow_cycle(0)

    #pixels.deinit()

    time.sleep(10)

