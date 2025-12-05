calculate_effort <- function(revision_campo) {
  tibble::tibble(e = 1, Session = 2, Ocassion = 3)
}
get_session <- function(data_trapping_hunting) {
  months <- lubridate::month(data_trapping_hunting$Date)
  years <- lubridate::year(data_trapping_hunting$Date)
  sessions <- data_trapping_hunting %>%
    dplyr::mutate(Session = paste(years, months, sep = "-"))
  return(sessions)
}
