use std::{fs::File, path::Path};

use ac_ffmpeg::{
    format::{
        demuxer::{Demuxer, DemuxerWithStreamInfo},
        io::IO,
    },
    Error,
};

use crate::video::start_video;

fn open_file_demuxer_with_stream_info(
    path: &str,
) -> Result<DemuxerWithStreamInfo<File>, Error> {
    let input = File::open(path).map_err(|error| {
        Error::new(format!(
            "Can't open especified file {}, error: {}",
            path, error
        ))
    })?;

    let io = IO::from_seekable_read_stream(input);

    Demuxer::builder()
        .build(io)?
        .find_stream_info(None)
        .map_err(|(_, err)| err)
}

pub fn start<P: AsRef<Path>>(input: &str, framebuffer_dev: P) -> Result<(), Error> {
    let mut demuxer = open_file_demuxer_with_stream_info(input)?;
    start_video(&mut demuxer, framebuffer_dev)?;

    Ok(())
}