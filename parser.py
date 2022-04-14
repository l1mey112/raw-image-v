import zlib

from ctypes.wintypes import UINT
import numpy as np
from PIL import Image,UnidentifiedImageError
import sys

#? l-m.dev 2022

print("l-m.dev 2022\n")

if sys.argv.__len__() != 3:
    print("Usage: python3 "+sys.argv[0]+" <file> <output>")
    exit(1)

try:
    image = Image.open(sys.argv[1])
except FileNotFoundError:
    print("File not found!")
    exit(1)
except UnidentifiedImageError:
    print("Not a valid image file!")
    exit(1)

open(sys.argv[2], 'w').close()
f = open(sys.argv[2], "wb")

img_array = np.array(image, dtype=np.uint8)

print(image.format +" with " + image.mode)

print("Image data in bytes: "+img_array.size.__str__())
print("Array bounds: "+img_array.shape.__str__())

print("Working...")

sy, sx, ch = img_array.shape

f.write(bytes("l-m.dev", 'UTF-8'))

f.write((ch).to_bytes(1, byteorder=sys.byteorder,  signed=True))
f.write((sx).to_bytes(2, byteorder=sys.byteorder, signed=True))
f.write((sy).to_bytes(2, byteorder=sys.byteorder, signed=True))

compressed = bytearray()

for c in range(ch):
    for y in range(sy):
        for x in range(sx):
            compressed += img_array[y, x, c].tobytes()

f.write(zlib.compress(compressed))
f.close()

print("\nWritten "+sys.argv[2])
exit(0)