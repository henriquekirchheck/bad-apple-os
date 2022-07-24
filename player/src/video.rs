use std::{fs::File, path::Path, process::exit};

use ac_ffmpeg::{
    codec::{
        video::{
            frame::get_pixel_format, scaler::Algorithm, VideoDecoder, VideoFrame, VideoFrameScaler,
        },
        Decoder,
    },
    format::demuxer::DemuxerWithStreamInfo,
    Error,
};
use framebuffer::{Framebuffer, KdMode};

pub fn start_video<P: AsRef<Path>>(
    demuxer: &mut DemuxerWithStreamInfo<File>,
    framebuffer_dev: P,
) -> Result<(), Error> {
    let mut framebuffer =
        Framebuffer::new(framebuffer_dev).map_err(|error| Error::new(error.details))?;

    Framebuffer::set_kd_mode(KdMode::Graphics).map_err(|error| Error::new(error.details))?;

    let (stream_index, (stream, _)) = demuxer
        .streams()
        .iter()
        .map(|stream| (stream, stream.codec_parameters()))
        .enumerate()
        .find(|(_, (_, params))| params.is_video_codec())
        .ok_or_else(|| Error::new("No Video Stream"))?;

    let mut decoder = VideoDecoder::from_stream(stream)?.build()?;

    while let Some(packet) = demuxer.take()? {
        if packet.stream_index() != stream_index {
            continue;
        }

        decoder.push(packet)?;

        while let Some(frame) = decoder.take()? {
            write_video_frame_to_framebuffer(frame, &mut framebuffer)?;
        }
    }

    decoder.flush()?;

    while let Some(frame) = decoder.take()? {
        write_video_frame_to_framebuffer(frame, &mut framebuffer)?;
    }

    Framebuffer::set_kd_mode(KdMode::Text).map_err(|error| Error::new(error.details))?;

    Ok(())
}

fn write_video_frame_to_framebuffer(
    frame: VideoFrame,
    framebuffer: &mut Framebuffer,
) -> Result<(), Error> {
    // let width = framebuffer.var_screen_info.xres as usize;
    let height = framebuffer.var_screen_info.yres as usize;
    let line_length = framebuffer.fix_screen_info.line_length as usize;
    // let bytes_per_pixel = (framebuffer.var_screen_info.bits_per_pixel / 8) as usize;

    let mut scaler = VideoFrameScaler::builder()
        .algorithm(Algorithm::Bicubic)
        .source_height(frame.height())
        .source_width(frame.width())
        .source_pixel_format(frame.pixel_format())
        .target_height(frame.height())
        .target_width(frame.width())
        .target_pixel_format(get_pixel_format("bgra"))
        .build()?;

    let scaler_frame = scaler.scale(&frame)?;

    let mut fb_frame = vec![0u8; (line_length * height) as usize];

    for plane in scaler_frame.planes().into_iter() {
        if plane.line_size() <= 0 {
            continue;
        }

        for (y, line) in plane.lines().enumerate() {
            for (x, color) in line.into_iter().enumerate() {
                let start_index = (y * line_length + x) as usize;
                fb_frame[start_index] = *color;
            }
        }
    }

    framebuffer.write_frame(&fb_frame);

    Ok(())
}
