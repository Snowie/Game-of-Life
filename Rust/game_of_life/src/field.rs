use std::io::BufReader;
use std::fs::File;
use std::io::prelude::*;
use std::path::Path;

extern crate rand;
use field::rand::Rng;

//Generate a new blank field
pub fn new_field(width: usize, height: usize) -> Vec<Vec<(bool, bool)>> {
    vec![vec![(false, false); width]; height]
}

//Randomize a field state
pub fn randomize_field(field: &mut Vec<Vec<(bool, bool)>>) {
    let mut rng = rand::thread_rng();
    for row in field {
        for ref mut col in row {
            col.0 = rng.gen();
        }
    }
}

//Load a field from a pregenerated file
pub fn new_field_from_file(filename: &str) -> Vec<Vec<(bool, bool)>> {
    let mut result: Vec<Vec<(bool, bool)>> = Vec::new();

    let file = match File::open(Path::new(filename)) {
        Ok(f) => {
            f
        },
        Err(e) => {
            println!("Error: {}", e);
            panic!("Error on file read!");
        },
    };
    let reader = BufReader::new(file);
    for line in reader.lines() {
        //Add a new row to the field
        result.push(vec![]);
        for c in line {
            //Set the state based upon the character in the file.
            let state =
                match c.to_lowercase().as_ref() {
                    "x" => (true, false),
                    _ => (false, false),
                };

            //Sigh, borrowck. We can't do result[result.len() - 1].push(state);
            let index = result.len() - 1;
            result[index].push(state);
        }
    }
    result
}

fn sum_nine(field: &Vec<Vec<(bool, bool)>>, y: i32, x: i32) -> i32 {
    //Sum the 3x3 square
    let mut result = 0;
    for y_index in y-1..y+2 {
        if y_index <= field.len() as i32  && y_index >= 0{
            for x_index in x-1..x+2 {
                if x_index <= field[y_index as usize].len() as i32 && x_index >= 0 {
                    result +=
                        if field[y_index as usize][x_index as usize].0 {
                            1
                        } else {
                            0
                        };
                }
            }
        }
    }
    result
}

//Publicfunction to handle field logic.
pub fn step_field(field: &mut Vec<Vec<(bool, bool)>>) {
    //Swap it first
    swap_state(field);

    //Figure out the future
    for y in 0..field.len() {
        for x in 0..field[y].len() {
            //Get the sum of the 3x3 with x, y at its center
            match sum_nine(field, y as i32, x as i32) {
                //3 means live/be born
                3 => field[y][x].1 = true,
                //4 means retain state
                4 => field[y][x].1 = field[y][x].0,
                //Otherwise, die or remain dead.
                _ => field[y][x].1 = false,
            }
        }
    }
}

//Just swap the future to the present
fn swap_state(field: &mut Vec<Vec<(bool, bool)>>) {
    for row in field {
        for ref mut col in row {
            col.0 = col.1;
            col.1 = false;
        }
    }
}
