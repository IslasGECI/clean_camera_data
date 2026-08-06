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
  field_check_records <- rename_camera_field_check_columns(cameras_campo_df) |>
    fill_daily_camera_status(cameras_memoria_df) |>
    print(n = 20) |>
    add_taken_photos_and_individuals_to_daily_status_grid(cameras_memoria_df)
}

add_taken_photos_and_individuals_to_daily_status_grid <- function(daily_status_grid, cameras_memoria_df) {
  daily_status_grid |>
    dplyr::left_join(cameras_memoria_df, by = dplyr::join_by(ID == ID_camara, Date == Fecha_captura_foto))
}

fill_daily_camera_status <- function(field_check_records, cameras_memoria_df) {
  deactivated_camera_ids <- get_deactivated_camera_ids(field_check_records)
  reactivated_camera_ids <- get_reactivated_camera_ids(field_check_records)
  double_deactivated_ids <- get_double_deactivated_camera_ids(field_check_records)
  unkwnow_date_camera_ids <- get_camera_ids_with_taken_photos_without_detections(cameras_memoria_df)

  no_photos_taken_ids <- get_camera_ids_without_taken_photos(cameras_memoria_df)
  last_photo_date_by_camera <- get_last_photo_date_by_camera(cameras_memoria_df)

  field_check_records |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    dplyr::mutate(
      day_rank = dplyr::row_number(),
      half_point = ceiling(dplyr::n() / 2),
    ) |>
    dplyr::ungroup() |>
    dplyr::left_join(last_photo_date_by_camera, by = c("ID" = "ID_camara")) |>
    dplyr::mutate(camera_status = dplyr::case_when(
      ID %in% double_deactivated_ids & camera_status == "D" & Date <= last_photo_date ~ "A",
      ID %in% reactivated_camera_ids ~ "A",
      ID %in% unkwnow_date_camera_ids & day_rank <= half_point ~ "A",
      ID %in% unkwnow_date_camera_ids & day_rank > half_point ~ "D",
      ID %in% no_photos_taken_ids ~ "D",
      ID %in% deactivated_camera_ids & camera_status == "A" & Date > last_photo_date ~ "D",
      TRUE ~ camera_status
    ))
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

get_double_deactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::filter(camera_status == "D" & dplyr::lead(camera_status) == "D" | dplyr::lead(camera_status) == "R") |>
    dplyr::pull(ID)
}

get_reactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::filter(camera_status == "D" & dplyr::lead(camera_status) == "A") |>
    dplyr::pull(ID)
}

get_camera_ids_without_taken_photos <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fotos_capturadas) | Fotos_capturadas == 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}
get_camera_ids_with_taken_photos_without_detections <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fecha_captura_foto) & Fotos_capturadas > 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}

rename_camera_field_check_columns <- function(cameras_campo_df) {
  cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}
