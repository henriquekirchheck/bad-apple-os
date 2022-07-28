use std::path::Path;

use ac_ffmpeg::{
    codec::{
        video::{
            frame::get_pixel_format, scaler::Algorithm, VideoDecoder, VideoFrame, VideoFrameScaler,
        },
        Decoder,
    },
    Error as FFmpegError,
};
use framebuffer::{Framebuffer, KdMode};

use crate::shared::{DemuxerInfo, ErrorVariant, PlayerError, StreamType};

// Made to get the information easier
#[derive(Debug)]
struct FramebufferInfo {
    pub framebuffer: Framebuffer,
    pub height: usize,
    pub width: usize,
}

impl FramebufferInfo {
    pub fn new<P: AsRef<Path>>(framebuffer_path: P) -> Result<Self, PlayerError> {
        let framebuffer = Framebuffer::new(framebuffer_path).map_err(|err| {
            PlayerError::new(
                format!("Framebuffer Error: {}", err.details),
                ErrorVariant::Video,
            )
        })?;
        let width = framebuffer.var_screen_info.xres as usize;
        let height = framebuffer.var_screen_info.yres as usize;

        Ok(Self {
            framebuffer,
            width,
            height,
        })
    }
}

pub struct Video {
    framebuffer_info: FramebufferInfo,
    demuxer_info: DemuxerInfo,
    decoder: VideoDecoder,
    scaler: VideoFrameScaler,
}

impl Video {
    pub fn new<P: AsRef<Path>>(
        framebuffer_path: P,
        demuxer_path: &str,
    ) -> Result<Self, PlayerError> {
        let framebuffer_info = FramebufferInfo::new(framebuffer_path)?;
        let demuxer_info = DemuxerInfo::new(demuxer_path, StreamType::Video)?;
        let decoder = VideoDecoder::from_stream(
            demuxer_info
                .demuxer
                .streams()
                .get(demuxer_info.index)
                .ok_or_else(|| {
                    PlayerError::new(format!("Can't find stream"), ErrorVariant::Video)
                })?,
        )
        .map_err(|err| PlayerError::new(err.to_string(), ErrorVariant::Video))?
        .build()
        .map_err(|err| PlayerError::new(err.to_string(), ErrorVariant::Video))?;

        let scaler = VideoFrameScaler::builder()
            .algorithm(Algorithm::FastBilinear)
            .source_height(decoder.codec_parameters().height())
            .source_width(decoder.codec_parameters().width())
            .source_pixel_format(decoder.codec_parameters().pixel_format())
            .target_height(framebuffer_info.height)
            .target_width(framebuffer_info.width)
            .target_pixel_format(get_pixel_format("bgra"))
            .build()
            .map_err(|err| PlayerError::new(err.to_string(), ErrorVariant::Video))?;

        Ok(Self {
            framebuffer_info,
            demuxer_info,
            decoder,
            scaler,
        })
    }
    pub fn init_framebuffer(&self) -> Result<(), PlayerError> {
        Framebuffer::set_kd_mode(KdMode::Graphics)
            .map_err(|error| PlayerError::new(error.details, ErrorVariant::Video))?;
        Ok(())
    }
    pub fn close_framebuffer(&self) -> Result<(), PlayerError> {
        Framebuffer::set_kd_mode(KdMode::Text)
            .map_err(|error| PlayerError::new(error.details, ErrorVariant::Video))?;
        Ok(())
    }

    pub fn get_frames(&mut self) -> Result<(), FFmpegError> {
        while let Some(packet) = self.demuxer_info.demuxer.take()? {
            if packet.stream_index() != self.demuxer_info.index {
                continue;
            }

            self.decoder.push(packet)?;

            while let Some(frame) = self.decoder.take()? {
                let scaled_frame = self.scaler.scale(&frame)?;
                // self.add_frame_to_video_buffer(scaled_frame);
                self.write_frame_to_framebuffer(scaled_frame);
            }
        }

        self.decoder.flush()?;

        while let Some(frame) = self.decoder.take()? {
            let scaled_frame = self.scaler.scale(&frame)?;
            // self.add_frame_to_video_buffer(scaled_frame);
            self.write_frame_to_framebuffer(scaled_frame);
        }

        Ok(())
    }

    // fn add_frame_to_video_buffer(&mut self, frame: VideoFrame) {
    //     if let Some(plane) = frame
    //         .planes()
    //         .into_iter()
    //         .filter(|plane| !(plane.line_size() <= 0))
    //         .nth(0)
    //     {
    //         todo!()
    //     }
    // }

    fn write_frame_to_framebuffer(&mut self, frame: VideoFrame) {
        if let Some(plane) = frame
            .planes()
            .into_iter()
            .filter(|plane| !(plane.line_size() <= 0))
            .nth(0)
        {
            self.framebuffer_info.framebuffer.write_frame(plane.data())
        }
    }
}
