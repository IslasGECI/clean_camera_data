split_cameras_and_check_date <- function(cameras_with_check_date) {

}


extract_cameras_info <- function(revision_campo_tibble) {
  columns_of_interest <- c("ID_camara", "Coordenada_Este", "Coordenada_Norte", "Ultima_revision", "Lineas")
  return(revision_campo_tibble |> dplyr::select(all_of(columns_of_interest)))
}
