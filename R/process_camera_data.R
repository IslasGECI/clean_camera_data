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
    down_again = compute_down_again_camera_ids(field_check_records),
    retired_before_active = compute_retired_before_active_camera_ids(field_check_records),
    photos_without_capture_date = compute_camera_ids_with_undated_photos(cameras_memoria_df),
    no_captured_photos = compute_camera_ids_with_no_captured_photos(cameras_memoria_df)
  )
  last_photo_date_by_camera <- compute_last_photo_date_by_camera(cameras_memoria_df)

  field_check_records |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    compute_half_point() |>
    dplyr::ungroup() |>
    dplyr::left_join(last_photo_date_by_camera, by = c("ID" = "ID_camara")) |>
    apply_camera_status_rules(cameras_ids_classification)
}

apply_camera_status_rules <- function(daily_status_grid, cameras_ids_classification) {
  daily_status_grid |>
    dplyr::mutate(camera_status = dplyr::case_when(
      ID %in% cameras_ids_classification$down_again & Date <= last_photo_date ~ "A",
      ID %in% cameras_ids_classification$reactivated & (is.na(last_photo_date) | Date <= last_photo_date) ~ "A",
      ID %in% cameras_ids_classification$retired_before_active & camera_status == "R" ~ "R",
      ID %in% cameras_ids_classification$photos_without_capture_date & day_rank <= half_point ~ "A",
      ID %in% cameras_ids_classification$photos_without_capture_date & day_rank > half_point ~ "D",
      ID %in% cameras_ids_classification$no_captured_photos & ID %in% cameras_ids_classification$deactivated ~ "D",
      ID %in% cameras_ids_classification$deactivated & camera_status == "A" & Date > last_photo_date ~ "D",
      TRUE ~ camera_status
    ))
}
compute_half_point <- function(data) {
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

compute_down_again_camera_ids <- function(field_check_records) {
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

compute_camera_ids_with_no_captured_photos <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fotos_capturadas) | Fotos_capturadas == 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}
compute_camera_ids_with_undated_photos <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::filter(is.na(Fecha_captura_foto) & Fotos_capturadas > 0) |>
    dplyr::distinct(ID_camara) |>
    dplyr::pull(ID_camara)
}

compute_retired_before_active_camera_ids <- function(field_check_records) {
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::filter(dplyr::row_number() == 1 & camera_status == "R") |>
    dplyr::pull(ID)
}

rename_camera_field_check_columns <- function(cameras_campo_df) {
  cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}
