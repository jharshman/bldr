mod rpm;
use rpm::Build;

use anyhow::Result;
use clap::Parser;
use handlebars::Handlebars;
use serde_derive::{Deserialize, Serialize};
use serde_yaml;
use std::fs::File;
use uuid::Uuid;

/*
* BlDr
*
* Command line arguments
*/
#[derive(Parser, Debug)]
struct BlDr {
    #[arg(short, long)]
    /// specfile template
    spec_file: String,

    #[arg(short, long)]
    /// value file used to render templated specfile
    value_file: String,
}

/*
* Values
*
* Data type housing information read from values file.
* Used for templating RPM spec file.
*/
#[derive(Debug, Serialize, Deserialize)]
struct Values {
    name: String,
    version: String,
    release: i32,
    summary: String,
    description: String,
    packager: String,
}

/*
* get_values_from_file
*
* Takes a String representing the name of the file to open.
* Reads the contents of the file and returns the Values type.
*/
fn get_values_from_file(file_name: String) -> Result<Values> {
    let f = File::open(file_name)?;
    let v: Values = serde_yaml::from_reader(f)?;
    Ok(v)
}

fn main() {
    let flags = BlDr::parse();

    let mut template = Handlebars::new();
    if let Err(result) = template.register_template_file("specfile", flags.spec_file) {
        println!("error reading specfile template: {}", result);
        std::process::exit(1)
    };

    let v: Values = match get_values_from_file(flags.value_file) {
        Ok(v) => v,
        Err(e) => {
            println!("error getting values from file: {}", e);
            std::process::exit(1)
        }
    };

    let name = format!("/root/rpmbuild/SPECS/{}.spec", Uuid::new_v4());
    let f: File = match File::create(&name) {
        Ok(f) => f,
        Err(e) => {
            println!("error creating tmp file: {}", e);
            std::process::exit(1)
        }
    };

    template.render_to_write("specfile", &v, f).unwrap();

    let r = rpm::Rpm {
        bin_path: "/usr/bin/rpmbuild",
        specfile: name.as_str(),
        build_flags: "-bb",
    };

    match r.build() {
        Ok(out) => {
            if !out.stdout.is_empty() {
                match String::from_utf8(out.stdout) {
                    Ok(standard_output) => {
                        println!("rpmbuild status {}:\n {}", out.status, standard_output)
                    }
                    Err(e) => println!("{}", e),
                }
            }
            if !out.stderr.is_empty() {
                match String::from_utf8(out.stderr) {
                    Ok(standard_error) => {
                        println!("rpmbuild status {}:\n {}", out.status, standard_error)
                    }
                    Err(e) => println!("{}", e),
                }
            }
        }
        Err(e) => {
            println!("{}", e)
        }
    };
}
