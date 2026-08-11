compute_daily_summary <- function(cameras_daily_status_df) {
  cameras_daily_status_df |>
    dplyr::filter(camera_status == "A") |>
    dplyr::group_by(Date) |>
    dplyr::summarise(
      Number_of_camera_traps = dplyr::n_distinct(ID),
      Total_photos = sum(Fotos_capturadas, na.rm = TRUE),
      Total_individuals = sum(Individuos_capturados, na.rm = TRUE),
      Effort = dplyr::n_distinct(ID),
    ) |>
    dplyr::ungroup()
}

compute_daily_status <- function(cameras_campo_df, cameras_memoria_df) {
  daily_status_grid <- rename_camera_field_check_columns(cameras_campo_df) |>
    fill_daily_camera_status(cameras_memoria_df) |>
    print(n = 20) |>
    add_taken_photos_and_individuals_to_daily_status_grid(cameras_memoria_df)
}

add_taken_photos_and_individuals_to_daily_status_grid <- function(daily_status_grid, cameras_memoria_df) {
  daily_status_grid |>
    dplyr::left_join(cameras_memoria_df, by = dplyr::join_by(ID == ID_camara, Date == Fecha_captura_foto))
}

fill_daily_camera_status <- function(field_check_records, cameras_memoria_df) {
  cameras_ids_classification <- list(
    deactivated = compute_deactivated_camera_ids(field_check_records),
    reactivated = compute_reactivated_camera_ids(field_check_records),
    double_deactivated = compute_double_deactivated_camera_ids(field_check_records),
    unknown_date = compute_camera_ids_with_taken_photos_without_detections(cameras_memoria_df),
    no_photos_taken = compute_camera_ids_without_taken_photos(cameras_memoria_df)
  )
  last_photo_date_by_camera <- compute_last_photo_date_by_camera(cameras_memoria_df)

  field_check_records |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    calculate_half_point_between_last_and_current_check() |>
    dplyr::ungroup() |>
    dplyr::left_join(last_photo_date_by_camera, by = c("ID" = "ID_camara")) |>
    apply_camera_status_rules(cameras_ids_classification)
}

apply_camera_status_rules <- function(daily_status_grid, cameras_ids_classification) {
  daily_status_grid |>
    dplyr::mutate(camera_status = dplyr::case_when(
      ID %in% cameras_ids_classification$double_deactivated & camera_status == "D" & Date <= last_photo_date ~ "A",
      ID %in% cameras_ids_classification$reactivated ~ "A",
      ID %in% cameras_ids_classification$unknown_date & day_rank <= half_point ~ "A",
      ID %in% cameras_ids_classification$unknown_date & day_rank > half_point ~ "D",
      ID %in% cameras_ids_classification$no_photos_taken & ID %in% cameras_ids_classification$deactivated ~ "D",
      ID %in% cameras_ids_classification$deactivated & camera_status == "A" & Date > last_photo_date ~ "D",
      TRUE ~ camera_status
    ))
}
calculate_half_point_between_last_and_current_check <- function(data) {
  data |>
    dplyr::mutate(
      day_rank = dplyr::row_number(),
      half_point = ceiling(dplyr::n() / 2),
    )
}

compute_last_photo_date_by_camera <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(!is.na(Fecha_captura_foto)) |>
    dplyr::group_by(ID_camara) |>
    dplyr::summarise(last_photo_date = max(Fecha_captura_foto)) |>
    dplyr::ungroup()
}

compute_deactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::filter(camera_status == "D") |>
    dplyr::pull(ID)
}

compute_double_deactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::filter(camera_status == "D" & (dplyr::lead(camera_status) == "D" | dplyr::lead(camera_status) == "R")) |>
    dplyr::pull(ID)
}

compute_reactivated_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::filter(camera_status == "D" & dplyr::lead(camera_status) == "A") |>
    dplyr::pull(ID)
}

compute_camera_ids_without_taken_photos <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fotos_capturadas) | Fotos_capturadas == 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}
compute_camera_ids_with_taken_photos_without_detections <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fecha_captura_foto) & Fotos_capturadas > 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}

rename_camera_field_check_columns <- function(cameras_campo_df) {
  cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}
