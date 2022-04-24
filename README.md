# raw-image-v
A simple to parse, raw image file format. Implementations to read images in python and V.

[**Blog post**](https://blog.l-m.dev/Creating-my-own-Image-format-in-V-3b034c73334d4d35a592329dbd910217)

![A 32x32 image printed in the terminal with no texture filtering in V](https://blog.l-m.dev/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F33ba0916-49fd-4b8a-939f-c014c4f38ae0%2FUntitled.png?table=block&id=52779783-2f9c-4141-a4b0-cfdf12504dcc&spaceId=5ce513b1-1277-4ba2-9c22-37bbd861a0ec&width=2000&userId=&cache=v2 "A 32x32 image printed in the terminal with no texture filtering")

## V implementation

`v run rimg-reader.v` will run the file in the terminal and the file specified in the main function `test.rimg` will be read and displayed inside the terminal

Default constants
```vlang
const (
	r_width = 32
	r_height = 32
	bilinear_filtering = true // enable or disable texture filtering
)
```

## Python
Create images using the `parser.py` and read or display them using `read.py`

```
$ python3 parser.py

Usage: python3 parser.py <file> <output>
```
```
$ python3 read.py

Usage: python3 read.py <file> <output>
Using _ as <output> will not save the file. (useful for checking corruption)
Appending "show" to the end of program arguments will display the image.
```
