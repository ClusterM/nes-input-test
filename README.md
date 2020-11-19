[README на Русском](https://github.com/kotleni/nes-input-test/blob/main/README_ru.md)

# NES Input Test ROM
This is simple NES/Famicom ROM to test different input accessories.

After standard strobe on $4016.0 it reads $4016.0-$4016.7 and $4017.0-$4017.7 (yes, all 8 data lines including not connected on most consoles) 24 times (yes, not only 8 times). So you can test and reverse-engineer almost any input device. This ROM optimized to update screen with all 384 bits every frame.

## Examples
NES Four Score:

![NES Four Score](screenshots/four_score.png)

You can see signature in third byte on $4016.0 and $4017.0 and pressed buttons on the first two bytes.


Hori 4-Players Adapter:

![Hori 4-Players Adapter](screenshots/hori4.png)

Same here but using D1 line. You can see signature in third byte on $4016.1 and $4017.1 and pressed buttons on the first two bytes.
