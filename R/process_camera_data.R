compute_daily_status <- function(cameras_campo_df) {
  renamed_cameras_campo_df <- cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
  cameras_campo_filled <- renamed_cameras_campo_df |>
    dplyr::mutate(Date = as.Date(Date)) |>
    dplyr::group_by(ID) |>
    tidyr::complete(Date = seq(min(Date), max(Date), by = "day")) |>
    tidyr::fill(camera_status, .direction = "down") |>
    dplyr::ungroup()
}
