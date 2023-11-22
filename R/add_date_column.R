extract_date_from_filename <- function(file_name) {
  date <- stringr::str_sub(file_name, -13)
  day <- stringr::str_sub(date, 1, 2)
  month <- stringr::str_to_title(stringr::str_sub(date, 3, 5))
  year <- stringr::str_sub(date, 6, 9)
  glue::glue("{day}/{month}/{year}")
}

add_column_fecha_envio <- function(raw_data, date_send_data) {
  raw_data |>
    dplyr::mutate(Fecha_envio_datos = date_send_data)
}
