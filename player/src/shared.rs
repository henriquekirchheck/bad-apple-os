use std::{fmt::Display, fs::File, path::PathBuf};

use ac_ffmpeg::{
    codec::CodecParameters,
    format::{
        demuxer::{Demuxer, DemuxerWithStreamInfo},
        io::IO,
    },
};

use crate::video::Video;

#[derive(Debug)]
pub enum ErrorVariant {
    Video,
    Audio,
    Other(String),
}

impl Display for ErrorVariant {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ErrorVariant::Video => write!(f, "Video"),
            ErrorVariant::Audio => write!(f, "Audio"),
            ErrorVariant::Other(other) => write!(f, "{}", other),
        }
    }
}

#[derive(Debug)]
pub struct PlayerError {
    pub msg: String,
    pub from: ErrorVariant,
}

impl PlayerError {
    pub fn new(msg: String, from: ErrorVariant) -> Self {
        Self { msg, from }
    }
}

impl Display for PlayerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Error from {}: \"{}\"", self.from, self.msg)
    }
}

pub enum StreamType {
    Video,
    Audio,
}

impl Display for StreamType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            StreamType::Video => write!(f, "Video"),
            StreamType::Audio => write!(f, "Audio"),
        }
    }
}

pub struct DemuxerInfo {
    pub demuxer: DemuxerWithStreamInfo<File>,
    pub index: usize,
    pub params: CodecParameters,
    pub from: StreamType,
}

impl DemuxerInfo {
    pub fn new(demuxer_path: &str, from: StreamType) -> Result<Self, PlayerError> {
        let demuxer = DemuxerInfo::open_file_demuxer_with_stream_info(demuxer_path)?;

        let (index, params) = demuxer
            .streams()
            .iter()
            .map(|stream| stream.codec_parameters())
            .enumerate()
            .find(|(_, params)| match from {
                StreamType::Video => params.is_video_codec(),
                StreamType::Audio => params.is_audio_codec(),
            })
            .ok_or_else(|| {
                PlayerError::new(
                    format!("No {} Stream", from),
                    match from {
                        StreamType::Video => ErrorVariant::Video,
                        StreamType::Audio => ErrorVariant::Audio,
                    },
                )
            })?;

        Ok(Self {
            demuxer,
            index,
            params,
            from,
        })
    }

    fn open_file_demuxer_with_stream_info(
        path: &str,
    ) -> Result<DemuxerWithStreamInfo<File>, PlayerError> {
        let input = File::open(path).map_err(|error| {
            PlayerError::new(
                format!("Can't open especified file {}, error: {}", path, error),
                ErrorVariant::Other("Create Demuxer".to_owned()),
            )
        })?;

        let io = IO::from_seekable_read_stream(input);

        Demuxer::builder()
            .build(io)
            .map_err(|err| {
                PlayerError::new(
                    err.to_string(),
                    ErrorVariant::Other("Create Demuxer".to_owned()),
                )
            })?
            .find_stream_info(None)
            .map_err(|(_, err)| {
                PlayerError::new(
                    err.to_string(),
                    ErrorVariant::Other("Create Demuxer".to_owned()),
                )
            })
    }
}

pub fn start(file: PathBuf, framebuffer: PathBuf) -> Result<(), PlayerError> {
    let mut video = Video::new(framebuffer, &file.display().to_string())?;

    video.init_framebuffer()?;
    video
        .get_frames()
        .map_err(|err| PlayerError::new(err.to_string(), ErrorVariant::Video))?;
    video.close_framebuffer()?;

    Ok(())
}
