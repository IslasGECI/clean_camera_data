compute_daily_summary <- function(cameras_daily_status_df) {
  cameras_daily_status_df |>
    dplyr::filter(camera_status == "A") |>
    dplyr::group_by(Date) |>
    dplyr::summarise(
      Number_of_camera_traps = dplyr::n_distinct(ID),
      Total_photos = sum(Fotos_capturadas, na.rm = TRUE),
      Total_individuals = sum(Individuos_capturados, na.rm = TRUE)
    ) |>
    dplyr::mutate(Effort = Number_of_camera_traps) |>
    dplyr::ungroup()
}

compute_daily_status <- function(cameras_campo_df, cameras_memoria_df) {
  renamed_cameras_campo_df <- cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)

  cameras_campo_filled <- renamed_cameras_campo_df |>
    dplyr::mutate(Date = as.Date(Date)) |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    dplyr::ungroup()

  cameras_memoria_as_date <- cameras_memoria_df |>
    dplyr::mutate(Fecha_captura_foto = as.Date(Fecha_captura_foto))

  cameras_campo_filled |>
    dplyr::left_join(cameras_memoria_as_date, by = dplyr::join_by(ID == ID_camara, Date == Fecha_captura_foto))
}
