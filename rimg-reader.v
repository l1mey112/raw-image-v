import compress.zlib
import term
import os
import math

struct Vector {
	mut:
		x f64
		y f64
		z f64
}

struct Vector2 {
	mut:
		x f64
		y f64
}

struct Vector2Int {
	mut:
		x int
		y int
}

fn (vec1 Vector2Int) float()Vector2{
	return Vector2{
		x: f64(vec1.x),
		y: f64(vec1.y)
	}
}
fn (vec1 Vector2) integer()Vector2Int{
	return Vector2Int{
		x: rint(vec1.x),
		y: rint(vec1.y)
	}
}

fn lerp(point1 f64, point2 f64, interp f64)f64{
	return point1 + ((point2-point1)/(1.0)) * (math.clamp(interp, 0.0, 1.0))
}

fn mapf(old_min f64, old_max f64, new_min f64, new_max f64, value f64)f64{
	return new_min + ((new_max-new_min)/(old_max-old_min)) * (math.clamp(value, old_min, old_max))
}

fn (vec1 Vector2) lerp(vec2 Vector2, interp f64) Vector2 {
	return Vector2{
		x: lerp(vec1.x, vec2.x, interp),
		y: lerp(vec1.y, vec2.y, interp),
	}
}

fn (vec1 Vector) lerp(vec2 Vector, interp f64) Vector {
	return Vector{
		x: lerp(vec1.x, vec2.x, interp),
		y: lerp(vec1.y, vec2.y, interp),
		z: lerp(vec1.z, vec2.z, interp)
	}
}

fn (vec1 Vector2) subtract(vec2 Vector2) Vector2 {return Vector2{vec1.x-vec2.x,vec1.y-vec2.y}}
fn (vec1 Vector2) divide(vec2 Vector2) Vector2 {return Vector2{vec1.x/vec2.x,vec1.y/vec2.y}}

fn (vec1 Vector2) floor() Vector2 {
	return Vector2{
		x: math.floor(vec1.x),
		y: math.floor(vec1.y)
	}
}

fn (vec1 Vector2) ceil() Vector2 {
	return Vector2{
		x: math.ceil(vec1.x),
		y: math.ceil(vec1.y)
	}
}

struct Vector4 {
	mut:
		x f64
		y f64
		z f64
		w f64
}

fn (vec1 Vector4) lerp(vec2 Vector4, interp f64) Vector4 {
	return Vector4{
		x: lerp(vec1.x, vec2.x, interp),
		y: lerp(vec1.y, vec2.y, interp),
		z: lerp(vec1.z, vec2.z, interp),
		w: lerp(vec1.w, vec2.w, interp)
	}
}

fn (vec1 Vector4) multiply(vec2 Vector4) Vector4 {
	return Vector4{
		x: vec1.x*vec2.x,
		y: vec1.y*vec2.y,
		z: vec1.z*vec2.z,
		w: vec1.w*vec2.w
	}
}

fn (vec1 Vector4) smultiply(scalar f64) Vector4 {
	return Vector4{
		x: vec1.x*scalar,
		y: vec1.y*scalar,
		z: vec1.z*scalar,
		w: vec1.w*scalar
	}
}
fn (vec1 Vector4) sadd(scalar f64) Vector4 {
	return Vector4{
		x: vec1.x+scalar,
		y: vec1.y+scalar,
		z: vec1.z+scalar,
		w: vec1.w+scalar
	}
}

fn (vec1 Vector4) add(vec2 Vector4) Vector4 {
	return Vector4{
		x: vec1.x+vec2.x,
		y: vec1.y+vec2.y,
		z: vec1.z+vec2.z,
		w: vec1.w+vec2.w
	}
}

struct RImage {
	width u16
	height u16
	channels u8

	mut:
		data [][]Vector4
}

fn rint(v f64)int{
	return int(math.round(v))
}

fn sampletexture(vec Vector2, image RImage)Vector4{
	mut y := mapf(0.0,1.0,image.height-1,0.0,vec.y)
	mut x := mapf(0.0,1.0,0.0,image.width-1,vec.x)

	if bilinear_filtering{
		point1 := Vector2{x,y}.floor().integer()
		point2 := Vector2{x,y}.ceil().integer()
		interp := Vector2{x,y}.subtract(point1.float())
			//* get float component

		sample1 := image.data[point1.y][point1.x]
		sample2 := image.data[point1.y][point2.x]
		sample3 := image.data[point2.y][point1.x]
		sample4 := image.data[point2.y][point2.x]

		return sample1.smultiply((1-interp.x)*(1-interp.y))
					.add(sample2.smultiply((1-interp.y) * interp.x))
					.add(sample3.smultiply((1-interp.x)*interp.y))
					.add(sample4.smultiply(interp.x*interp.y))

			//! FULL AND COMPLETE BILINEAR INTERPOLATION
			//? https://math.stackexchange.com/questions/3230376/interpolate-between-4-points-on-a-2d-plane
			//* THANK YOU THANK YOU THANK YOU
	} else {
		return image.data[rint(y)][rint(x)]
	}
}

fn renderbuffer( framebuffer[][] Vector4) {
	for el in framebuffer{
		for pixel in el{
			if pixel.w > 0.5 {
				print(term.rgb(rint(pixel.x*255),rint(pixel.y*255),rint(pixel.z*255),"██"))
			}else{
				print("  ")
			}
		}
		print("\n")
	}
}

fn parse_rimage(mut framebuffer[][] Vector4,name string)?RImage{
	bytes := os.read_bytes(name)?

	if bytes[0..7] != "l-m.dev".bytes() {
		return error("not a file")
	}

	ch := bytes[7]
	sx := bytes[8] | u16(bytes[9]) << 8
	sy := bytes[10] | u16(bytes[11]) << 8
		//! LITTLE ENDIAN BYTE ORDERING
	
	data := zlib.decompress(bytes[12..]) or {
		return error("decompression failed")
	}
	if data.len != ch*sx*sy {
		return error("data size mismatch, file may be corrupted")
	}
	
	assert ch <= 4

	mut raw := RImage{
		width: sx,
		height: sy,
		channels: ch,
		data: [][]Vector4{len:int(sy),init: []Vector4{len:int(sx)}},
	}

	for c := 0; c < ch; c++ {
		for y := 0; y < sy; y++ {
			for x := 0; x < sx; x++ {
				if c == 0 {
					raw.data[y][x].x = f64(data[c*sx*sy + y*sx + x])/255.0
				} else if c == 1 {
					raw.data[y][x].y = f64(data[c*sx*sy + y*sx + x])/255.0
				}else if c == 2 {
					raw.data[y][x].z = f64(data[c*sx*sy + y*sx + x])/255.0
				}else if c == 3{
					raw.data[y][x].w = f64(data[c*sx*sy + y*sx + x])/255.0
				}
			}
		}
	}
	return raw
}

fn map_image(mut framebuffer[][] Vector4, image RImage){
	for y := 0; y < r_height; y++ {
		for x := 0; x < r_width; x++ {
			mx := mapf(0.0,r_width,0.0,1.0,x)
			my := mapf(0.0,r_height,1.0,0.0,y)
			framebuffer[y][x] = sampletexture(Vector2{mx,my},image)
		}
	}
}

const (
	r_width = 32
	r_height = 32
	bilinear_filtering = true
)

fn main(){
	term.clear()
	mut framebuffer := [][]Vector4{len:r_height,init: []Vector4{len:r_width}}

	image := parse_rimage(mut framebuffer,"test.rimg") or {
		panic(err)
	}
	map_image(mut framebuffer,image)

	renderbuffer(framebuffer)
}