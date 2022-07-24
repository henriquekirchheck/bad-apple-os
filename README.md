# This project is still in the development fase, it will not work in it's current state

# Bad Apple OS

This is a project that creates a bootable image that contain a Musl/Linux OS that sole function is to play BadApple


## Video Player

It's a video player written in Rust that outputs to the linux framebuffer, may become it's own project on the future, but for now it's going to be used as the video player for this project

## Video file format

For now, i'm limiting the format to MKV with libvpx-vp9 and libopus for easier ffmpeg compiling, but the player should support other codecs if ffmpeg is compiled with the extra codecs