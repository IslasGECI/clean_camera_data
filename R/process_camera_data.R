compute_daily_status <- function(cameras_campo_df) {
  cameras_campo_df |> dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}
