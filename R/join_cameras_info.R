join_cameras_info <- function(revision_campo_df, revision_memoria_df) {
  revision_memoria_summary <- get_weekly_pictures_summary(revision_memoria_df)
  dplyr::full_join(revision_campo_df, revision_memoria_summary, by = dplyr::join_by(ID_camara_trampa == ID_camara, Fecha_envio_datos)) |>
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
