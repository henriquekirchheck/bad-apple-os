mod shared;
mod video;

use std::{env, path::Path, process::exit};

use ac_ffmpeg::Error;
use framebuffer::{Framebuffer, KdMode};
use shared::open_file_demuxer_with_stream_info;
use video::start_video;

fn get_args() -> Vec<String> {
    let mut args: Vec<String> = env::args().collect();
    args.remove(0);
    args
}

fn start<P: AsRef<Path>>(input: &str, framebuffer_dev: P) -> Result<(), Error> {
    let mut demuxer = open_file_demuxer_with_stream_info(input)?;

    start_video(&mut demuxer, framebuffer_dev)?;

    Ok(())
}

fn main() {
    ctrlc::set_handler(move || {
        Framebuffer::set_kd_mode(KdMode::Text).unwrap();
        exit(1);
    })
    .expect("Failed to set termination handler");

    let framebuffer_default_device = "/dev/fb0".to_owned();

    let args = get_args();
    let video_file_arg = args.get(0).expect("Requires file path");
    let framebuffer_device_arg = args.get(1).unwrap_or(&framebuffer_default_device);

    start(video_file_arg, framebuffer_device_arg).unwrap();
}
