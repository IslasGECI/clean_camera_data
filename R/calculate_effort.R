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
get_ocassion <- function(raw_trapping_hunting) {
  ocassions <- sapply(raw_trapping_hunting$Date, get_week_of_year_from_date, USE.NAMES = FALSE)
  trapping_hunting_with_ocassions <- raw_trapping_hunting %>%
    dplyr::mutate(Ocassion = ocassions)
  return(trapping_hunting_with_ocassions)
}
get_week_of_year_from_date <- function(date) {
  year <- lubridate::year(date)
  first_day_of_year_string <- paste0(year, "-01-01")
  first_week_of_year <- lubridate::isoweek(first_day_of_year_string)
  week_of_year <- lubridate::isoweek(date)
  if (first_week_of_year >= 52) {
    week_of_year <- week_of_year + 1
  }
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
