calculate_cameras_summary <- function(revision_campo_df, revision_memoria_df) {
  revision_campo_cleaned <- dplyr::filter(revision_campo_df, Revision == "si") |>
    transform_spanish_dates_to_iso_format()
  filled_revision_campo <- fill_missing_sundays(revision_campo_cleaned)
  revision_memoria_iso <- convert_spanish_date_column_to_iso(revision_memoria_df, Fecha_envio_datos)
  joined_cameras_info <- join_cameras_info(filled_revision_campo, revision_memoria_iso)
  summary_df <- get_cameras_effort(joined_cameras_info) |>
    summarise_cameras_info() |>
    dplyr::rename(Date = Fecha_envio_datos)
}

fill_missing_sundays <- function(revision_campo_df) {
  revision_campo_complete <- revision_campo_df |>
    dplyr::arrange(ID_camara_trampa, Fecha_envio_datos) |>
    dplyr::group_by(ID_camara_trampa) |>
    tidyr::complete(Fecha_envio_datos = seq.Date(min(Fecha_envio_datos, na.rm = TRUE), max(Fecha_envio_datos, na.rm = TRUE), by = "1 week")) |>
    dplyr::ungroup() |>
    dplyr::arrange(ID_camara_trampa, Fecha_envio_datos)
  revision_campo_complete |>
    dplyr::group_by(ID_camara_trampa) |>
    tidyr::fill(Estado_camara)
}


join_cameras_info <- function(revision_campo_df, revision_memoria_df) {
  revision_memoria_summary <- get_weekly_pictures_summary(revision_memoria_df)
  dplyr::full_join(revision_campo_df, revision_memoria_summary, by = dplyr::join_by(ID_camara_trampa == ID_camara, Fecha_envio_datos)) |>
    dplyr::select(c("ID_camara_trampa", "Fotos_capturadas", "Fecha_envio_datos", "Fecha_revision_campo", "Individuos_capturados", "Estado_camara"))
}

get_cameras_effort <- function(joined_cameras_info) {
  joined_cameras_info |>
    dplyr::arrange(ID_camara_trampa, Fecha_envio_datos) |>
    dplyr::group_by(ID_camara_trampa) |>
    dplyr::mutate(effort = dplyr::case_when(
      Estado_camara == "A" ~ as.numeric(Fecha_envio_datos - dplyr::lag(Fecha_envio_datos)),
      Estado_camara == "D" ~ as.numeric(Fecha_revision_campo - dplyr::lag(Fecha_envio_datos)),
      TRUE ~ 0
    ))
}
summarise_cameras_info <- function(joined_cameras_with_effort) {
  joined_cameras_with_effort |>
    dplyr::group_by(Fecha_envio_datos) |>
    dplyr::summarise(
      Number_of_camera_traps = dplyr::n_distinct(ID_camara_trampa),
      Effort = sum(effort, na.rm = TRUE),
      Total_photos = sum(Fotos_capturadas, na.rm = TRUE),
      Total_individuals = sum(Individuos_capturados, na.rm = TRUE)
    ) |>
    dplyr::ungroup()
}

get_weekly_pictures_summary <- function(revision_memoria_df) {
  revision_memoria_df |>
    dplyr::group_by(ID_camara, Fecha_envio_datos) |>
    dplyr::summarise(
      Fotos_capturadas = dplyr::first(Fotos_capturadas),
      Individuos_capturados = sum(Individuos_capturados, na.rm = TRUE)
    )
}

transform_spanish_dates_to_iso_format <- function(joined_cameras_info) {
  joined_cameras_info |>
    convert_spanish_date_column_to_iso(Fecha_envio_datos) |>
    convert_spanish_date_column_to_iso(Fecha_revision_campo)
}
convert_spanish_date_column_to_iso <- function(data, date_column) {
  data |>
    dplyr::rename(Fecha = {{ date_column }}) |>
    gecitools::convert_spanish_dates() |>
    dplyr::rename({{ date_column }} := Fecha)
}
