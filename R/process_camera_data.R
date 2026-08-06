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
  field_check_records <- rename_camera_field_check_columns(cameras_campo_df)

  deactivated_camera_ids <- get_deactivated_camera_ids(field_check_records)

  last_photo_date_by_camera <- get_last_photo_date_by_camera(cameras_memoria_df)

  daily_status_grid <- field_check_records |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    dplyr::ungroup() |>
    dplyr::left_join(last_photo_date_by_camera, by = c("ID" = "ID_camara")) |>
    dplyr::mutate(camera_status = dplyr::case_when(
      ID %in% deactivated_camera_ids & camera_status == "A" & Date > last_photo_date ~ "D",
      TRUE ~ camera_status
    ))

  daily_status_grid |>
    dplyr::left_join(cameras_memoria_df, by = dplyr::join_by(ID == ID_camara, Date == Fecha_captura_foto))
}

get_last_photo_date_by_camera <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(!is.na(Fecha_captura_foto)) |>
    dplyr::group_by(ID_camara) |>
    dplyr::summarise(last_photo_date = max(Fecha_captura_foto)) |>
    dplyr::ungroup()
}

get_deactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::filter(camera_status == "D") |>
    dplyr::pull(ID)
}

rename_camera_field_check_columns <- function(cameras_campo_df) {
  cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}
