use std::{env, fs, thread::sleep, time::Duration};

use framebuffer::{Framebuffer, KdMode};
use image::{open, GenericImageView};

fn main() {
    let args: Vec<String> = env::args().collect();
    let frames_files_dir_arg = &args[1];

    let frames_files_dir = fs::read_dir(frames_files_dir_arg).unwrap();
    let frames_files_paths: Vec<String> = frames_files_dir
        .map(|file| file.unwrap().path().display().to_string())
        .collect();

    let mut framebuffer = Framebuffer::new("/dev/fb0").unwrap();
    let width = framebuffer.var_screen_info.xres;
    let height = framebuffer.var_screen_info.yres;
    let line_length = framebuffer.fix_screen_info.line_length;
    let bytes_per_pixel = framebuffer.var_screen_info.bits_per_pixel / 8;

    println!(
        "width: {} \nheight:{} \nline_length: {} \nbytes_per_pixel: {} ",
        width, height, line_length, bytes_per_pixel
    );

    let mut frame = vec![0u8; (line_length * height) as usize];

    let _ = Framebuffer::set_kd_mode(KdMode::Graphics).unwrap();

    for img_path in frames_files_paths {
        let img = open(img_path).unwrap();
        for (x, y, rgba) in img.pixels() {
            let start_index = (y * line_length + x * bytes_per_pixel) as usize;
            frame[start_index] = rgba.0[2];
            frame[start_index + 1] = rgba.0[1];
            frame[start_index + 2] = rgba.0[0];
        }

        sleep(Duration::from_millis(33));

        let _ = framebuffer.write_frame(&frame);
    }

    sleep(Duration::from_secs(1));
    let _ = Framebuffer::set_kd_mode(KdMode::Text).unwrap();
}
