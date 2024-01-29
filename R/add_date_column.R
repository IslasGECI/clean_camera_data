extract_date_from_filename <- function(file_name) {
  splited_string <- stringr::str_split(file_name, "\\.")[[1]][1]
  date <- stringr::str_sub(splited_string, -9)
  day <- stringr::str_sub(date, 1, 2)
  month <- stringr::str_to_title(stringr::str_sub(date, 3, 5))
  year <- stringr::str_sub(date, 6, 9)
  glue::glue("{day}/{month}/{year}")
}

add_column_fecha_envio_revision_campo <- function(raw_data, date_send_data) {
  raw_data |>
    dplyr::mutate(Fecha_envio_datos = date_send_data, .after = "Fecha_revision") |>
    dplyr::select(-any_of(c("Ultima_revision", "Lineas")))
}

add_column_fecha_envio_revision_memoria <- function(raw_data, date_send_data) {
  raw_data |>
    dplyr::mutate(Fecha_envio_datos = date_send_data, .after = "Fotos capturadas") |>
    dplyr::select(-any_of("Lineas"))
}
