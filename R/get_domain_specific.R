get_domain_specific_options <- function() {
  camera_field_check <- gecioptparse::character_option(c("-c", "--camera-field-check-path"), default = "camaras_revision_campo.csv", help = "Path to the camera field check CSV file")
  camera_memory_check <- gecioptparse::character_option(c("-m", "--camera-memory-check-path"), default = "camaras_revision_memoria.csv", help = "Path to the camera memory check CSV file")
  output_path <- gecioptparse::character_option(c("-o", "--output-path"), default = "output_file.csv", help = "Path to the output CSV file")
  option_names <- c(camera_field_check, camera_memory_check, output_path)
  gecioptparse::get_options_from_vec(option_names)
}
