join_cameras_info <- function(revision_campo_df, revision_memoria_df) {
  dplyr::full_join(revision_campo_df, revision_memoria_df, by = dplyr::join_by(ID_camara_trampa == ID_camara, Fecha_envio_datos))
}
