use anyhow::{anyhow, Result};
use std::io;
use std::process::{Command, Output};

pub trait Build {
    fn build(&self) -> Result<Output>;
}

pub struct Rpm<'a> {
    pub bin_path: &'a str,
    pub specfile: &'a str,
    pub build_flags: &'a str,
}

impl Build for Rpm<'_> {
    fn build(&self) -> Result<Output> {
        let cmd_out: io::Result<Output> = Command::new(self.bin_path)
            .arg(self.build_flags)
            .arg(self.specfile)
            .output();

        let cmd = match cmd_out {
            Ok(cmd) => cmd,
            Err(e) => {
                return Err(anyhow!(e));
            }
        };

        Ok(cmd)
    }
}
