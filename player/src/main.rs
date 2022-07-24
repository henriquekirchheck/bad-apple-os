mod shared;
mod video;

use std::{path::PathBuf, process::exit};

use clap::Parser;
use framebuffer::{Framebuffer, KdMode};
use shared::start;

#[derive(Parser)]
#[clap(author, version, long_about = None)]
/// A media player that writes to the Linux Framebuffer
struct Cli {
    #[clap(value_parser)]
    /// Video File Path
    file: PathBuf,

    #[clap(short, long, value_parser, value_name = "FRAMEBUFFER")]
    /// Specify Framebuffer (Default: "/dev/fb0")
    framebuffer: Option<PathBuf>,
}

fn main() {
    ctrlc::set_handler(move || {
        Framebuffer::set_kd_mode(KdMode::Text).unwrap();
        exit(1);
    })
    .expect("Failed to set termination handler");

    let cli = Cli::parse();
    let file: PathBuf = cli.file;
    let framebuffer: PathBuf = cli.framebuffer.unwrap_or(PathBuf::from("/dev/fb0"));

    if let Err(error) = start(&file.display().to_string(), framebuffer) {
        eprintln!("error: {}", error)
    }
}
