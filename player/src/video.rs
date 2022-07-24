use std::{fs::File, path::Path};

use ac_ffmpeg::{
    codec::{
        video::{VideoDecoder, VideoFrame},
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
    framebuffer_frame: VideoFrame,
    framebuffer: &mut Framebuffer,
) -> Result<(), Error> {
    // TODO Write Frame to Framebuffer
    todo!("Make it write the frame to the framebuffer")
}
