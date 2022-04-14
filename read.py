import zlib

import ctypes
import numpy as np
from PIL import Image
import sys

#? l-m.dev 2022

print("l-m.dev 2022\n")

if sys.argv.__len__() < 3:
    print("Usage: python3 "+sys.argv[0]+" <file> <output>")
    print("Using _ as <output> will not save the file. (useful for checking corruption)")
    print("Appending \"show\" to the end of program arguments will display the image.")
    exit(1)

if sys.argv.__len__() == 4 and sys.argv[3] == "show":
    show = True
else:
    show = False

try:
    file = open(sys.argv[1], 'rb')
except FileNotFoundError:
    print("File not found!")
    exit(1)
f = file.read()
file.close()

if f[0:7].decode("utf-8") != "l-m.dev":
    print("Not a valid image file!")
    exit(1) #? troleld

def uindt(thing):
    return int.from_bytes(thing, sys.byteorder, signed=True)

ch, sx, sy = uindt(f[7:8]), uindt(f[8:10]), uindt(f[10:12])

print("Reading...")

print(sx,"by", sy)
print("With "+ch.__str__()+" channels.")


compress = zlib.decompress(f[12:])

if compress.__len__() != (ch * sx * sy):
    print("Does not match dimensions!")
    print("File may be corrupted")
    exit(1) #? padding

img_arr = np.ndarray((sy,sx,ch),np.uint8)

for c in range(ch):
    for y in range(sy):
        for x in range(sx):
            img_arr[y, x, c] = (compress[c * sx * sy + y * sx + x])

if show:
    Image.fromarray(img_arr).show()

if sys.argv[2] != "_":
    Image.fromarray(img_arr).save(sys.argv[2])
    print("\nWritten "+sys.argv[2])
else:
    print("\nNot saving file")

exit(0)