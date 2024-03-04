drop_last_check_date <- function(cameras_with_check_date) {
  cameras_with_check_date |> dplyr::select(-c("Ultima_revision"))
}


extract_cameras_info <- function(revision_campo_tibble) {
  columns_of_interest <- c("ID_camara", "Coordenada_Este", "Coordenada_Norte", "Ultima_revision", "Lineas")
  return(revision_campo_tibble |> dplyr::select(all_of(columns_of_interest)))
}
