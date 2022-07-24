use std::fs::File;

use ac_ffmpeg::{
    format::{
        demuxer::{Demuxer, DemuxerWithStreamInfo},
        io::IO,
    },
    Error,
};

pub fn open_file_demuxer_with_stream_info(
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
