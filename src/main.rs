use std::{fs::File, io};
use uuid::Uuid;
use clap::Parser;
use serde_yaml;
use serde_derive::{self, Deserialize, Serialize};
use handlebars::Handlebars;

/*
* BlDr
*
* Command line arguments
*/
#[derive(Parser, Debug)]
struct BlDr {
    #[arg(short, long)]
    spec_file: String,

    #[arg(short, long)]
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
}

/*
* get_values_from_file
* 
* Takes a String representing the name of the file to open.
* Reads the contents of the file and returns the Values type.
*/
fn get_values_from_file(file_name: String) -> Result<Values, String> {
    let f = match File::open(file_name) {
        Ok(f) => f,
        Err(e) => return Err(e.to_string()),
    };

    let v: Values = match serde_yaml::from_reader(f) {
        Ok(v) => v,
        Err(e) => return Err(e.to_string()),
    };
 
    Ok(v)
}

/*
* new_tmp_file
*
* Creates a new file at a given directory. File is named with a
* uuid to ensure uniqueness.
*/
fn new_tmp_file(tmp_dir: String) -> Result<File, io::Error> {
    let id = Uuid::new_v4();
    let tmp_file = File::create(format!("{}/{}.spec", tmp_dir, id))?;
    Ok(tmp_file)
}

fn main() {
    let flags = BlDr::parse();

    let mut template = Handlebars::new();
    if let Err(result) = template.register_template_file("specfile", flags.spec_file) {
        println!("error reading specfile template: {}", result);
        std::process::exit(1)
    };

    let v = match get_values_from_file(flags.value_file) {
        Ok(v) => v,
        Err(e) => {
            println!("error getting values from file: {}", e);
            std::process::exit(1)
        }
    };

    let f = match new_tmp_file("/tmp".to_string()) {
        Ok(f) => f,
        Err(e) => {
            println!("error opening file for write: {}", e);
            std::process::exit(1)
        }
    };

    template.render_to_write("specfile", &v, f).unwrap();

    // todo: build specfile with rpmbuild
    // rpmbuild -bb <specfile>

}
