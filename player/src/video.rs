use std::{fs::File, path::Path};

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
    let width = framebuffer.var_screen_info.xres as usize;
    let height = framebuffer.var_screen_info.yres as usize;

    Framebuffer::set_kd_mode(KdMode::Graphics).map_err(|error| Error::new(error.details))?;

    let (stream_index, (stream, _)) = demuxer
        .streams()
        .iter()
        .map(|stream| (stream, stream.codec_parameters()))
        .enumerate()
        .find(|(_, (_, params))| params.is_video_codec())
        .ok_or_else(|| Error::new("No Video Stream"))?;

    let mut decoder = VideoDecoder::from_stream(stream)?.build()?;

    let mut scaler = VideoFrameScaler::builder()
        .algorithm(Algorithm::FastBilinear)
        .source_height(decoder.codec_parameters().height())
        .source_width(decoder.codec_parameters().width())
        .source_pixel_format(decoder.codec_parameters().pixel_format())
        .target_height(height)
        .target_width(width)
        .target_pixel_format(get_pixel_format("bgra"))
        .build()?;

    while let Some(packet) = demuxer.take()? {
        if packet.stream_index() != stream_index {
            continue;
        }

        decoder.push(packet)?;

        while let Some(frame) = decoder.take()? {
            write_frame_to_framebuffer(frame, &mut scaler, &mut framebuffer)?;
        }
    }

    decoder.flush()?;

    while let Some(frame) = decoder.take()? {
        write_frame_to_framebuffer(frame, &mut scaler, &mut framebuffer)?;
    }

    Framebuffer::set_kd_mode(KdMode::Text).map_err(|error| Error::new(error.details))?;

    Ok(())
}

fn write_frame_to_framebuffer(
    frame: VideoFrame,
    scaler: &mut VideoFrameScaler,
    framebuffer: &mut Framebuffer,
) -> Result<(), Error> {
    let scaler_frame = scaler.scale(&frame)?;

    if let Some(plane) = scaler_frame
        .planes()
        .into_iter()
        .filter(|plane| !(plane.line_size() <= 0))
        .next()
    {
        framebuffer.write_frame(plane.data());
    }

    Ok(())
}
