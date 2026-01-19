calculate_cameras_summary <- function(revision_campo_df, revision_memoria_df) {
  joined_cameras_info <- revision_campo_df |>
    join_cameras_info(revision_memoria_df)
  summary_df <- get_cameras_effort(joined_cameras_info) |>
    summarise_cameras_info()
  summary_df |>
    dplyr::mutate(Date = Fecha_envio_datos) |>
    dplyr::select(c("Date", "Number_of_camera_traps", "Effort", "Total_photos", "Total_individuals"))
}
summarise_cameras_info <- function(joined_cameras_with_effort) {
  joined_cameras_with_effort |>
    dplyr::group_by(Fecha_envio_datos) |>
    dplyr::summarise(Number_of_camera_traps = dplyr::n_distinct(ID_camara_trampa), Effort = sum(effort), Total_photos = sum(Fotos_capturadas), Total_individuals = sum(Individuos_capturados)) |>
    dplyr::ungroup()
}
join_cameras_info <- function(revision_campo_df, revision_memoria_df) {
  revision_campo_filtered <- dplyr::filter(revision_campo_df, Revision == "si")
  revision_memoria_summary <- get_weekly_pictures_summary(revision_memoria_df)
  dplyr::full_join(revision_campo_filtered, revision_memoria_summary, by = dplyr::join_by(ID_camara_trampa == ID_camara, Fecha_envio_datos)) |>
    dplyr::select(c("ID_camara_trampa", "Fotos_capturadas", "Fecha_envio_datos", "Fecha_revision_campo", "Individuos_capturados", "Estado_camara"))
}

get_weekly_pictures_summary <- function(revision_memoria_df) {
  revision_memoria_df |>
    dplyr::group_by(ID_camara, Fecha_envio_datos) |>
    dplyr::summarise(
      Fotos_capturadas = dplyr::first(Fotos_capturadas),
      Individuos_capturados = sum(Individuos_capturados, na.rm = TRUE)
    )
}

get_cameras_effort <- function(joined_cameras_info) {
  joined_cameras_info |>
    transform_spanish_dates_to_iso_format() |>
    dplyr::arrange(ID_camara_trampa, Fecha_envio_datos) |>
    dplyr::group_by(ID_camara_trampa) |>
    dplyr::mutate(effort = dplyr::case_when(
      Estado_camara == "A" ~ as.numeric(Fecha_envio_datos - dplyr::lag(Fecha_envio_datos)),
      Estado_camara == "D" ~ as.numeric(Fecha_revision_campo - dplyr::lag(Fecha_envio_datos)),
      TRUE ~ 0
    ))
}
transform_spanish_dates_to_iso_format <- function(joined_cameras_info) {
  joined_cameras_info |>
    dplyr::mutate(Fecha = Fecha_envio_datos) |>
    gecitools::convert_spanish_dates() |>
    dplyr::mutate(Fecha_envio_datos = Fecha, Fecha = Fecha_revision_campo) |>
    gecitools::convert_spanish_dates() |>
    dplyr::mutate(Fecha_revision_campo = Fecha) |>
    dplyr::select(-Fecha)
}
