change_to_tidy_effort_format <- function(revision_campo) {
  days_of_effort_by_week <- 7
  revision_campo |>
    dplyr::rename(Date = Fecha_envio_datos) |>
    fill_ocassions() |>
    dplyr::mutate(e = dplyr::case_when(Estado_camara == "D" ~ 0, TRUE ~ days_of_effort_by_week), Session = 2)
}
fill_ocassions <- function(effort_data) {
  effort_data_filled <- effort_data |>
    dplyr::mutate(Date = lubridate::ymd(Date)) |>
    dplyr::group_by(ID_camara_trampa) |>
    tidyr::complete(Date = seq.Date(min(Date, na.rm = TRUE), max(Date, na.rm = TRUE), by = "1 week")) |>
    dplyr::ungroup() |>
    get_ocassion() |>
    tidyr::fill(c(ID_camara_trampa, Revision, Estado_camara), .direction = "down")
  return(effort_data_filled)
}
get_session <- function(raw_data_with_date) {
  months <- lubridate::month(raw_data_with_date$Date)
  years <- lubridate::year(raw_data_with_date$Date)
  sessions <- raw_data_with_date |>
    dplyr::mutate(Session = paste(years, months, sep = "-"))
  return(sessions)
}
get_ocassion <- function(raw_data_with_date) {
  ocassions <- sapply(raw_data_with_date$Date, get_week_of_year_from_date, USE.NAMES = FALSE)
  trapping_hunting_with_ocassions <- raw_data_with_date |>
    dplyr::mutate(Ocassion = ocassions)
  return(trapping_hunting_with_ocassions)
}
get_week_of_year_from_date <- function(date) {
  iso_week_of_year <- lubridate::isoweek(date)
  week_of_year <- is_first_day_of_year_in_first_week(date, iso_week_of_year)
  month_of_year <- lubridate::month(date)
  if ((month_of_year == 1) & (week_of_year >= 52)) {
    week_of_year <- 1
  }
  if ((month_of_year == 12)) {
    if (week_of_year == 1) {
      week_of_year <- 53
    } else if (week_of_year == 2) {
      week_of_year <- 54
    }
  }
  return(week_of_year)
}
is_first_day_of_year_in_first_week <- function(date, week_of_year) {
  year <- lubridate::year(date)
  first_day_of_year_string <- paste0(year, "-01-01")
  first_week_of_year <- lubridate::isoweek(first_day_of_year_string)
  if (first_week_of_year >= 52) {
    week_of_year <- week_of_year + 1
  }
  return(week_of_year)
}
