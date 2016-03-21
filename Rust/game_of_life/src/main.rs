mod field;

fn main() {
    let mut f = field::new_field(10, 10);
    field::randomize_field(&mut f);

    let mut ffile = field::new_field_from_file("../../test.txt");
    field::step_field(&mut ffile);
    println!("Hello, world!");
}
