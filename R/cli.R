add_data_check_column_extra_campo <- function(xlsx_name, csv_name) {
  readr::read_csv(csv_name) |>
    readr::write_csv("/workdir/tests/data/cameras_extra_campo_with_date.csv")
}
