extract_cameras_info <- function(revision_campo_tibble) {
  columns_of_interest <- c("ID_camara", "Coordenada_Este", "Coordenada_Norte", "Ultima_revision", "Lineas")
  return(revision_campo_tibble |> dplyr::select(columns_of_interest))
}
