extract_date_from_filename <- function(file_name) {
  date <- stringr::str_sub(file_name, -13)
  day <- stringr::str_sub(date, 1, 2)
  month <- stringr::str_to_title(stringr::str_sub(date, 3, 5))
  year <- stringr::str_sub(date, 6, 9)
  glue::glue("{day}/{month}/{year}")
}

return_one <- function() {
  return(1)
}
