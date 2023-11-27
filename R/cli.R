add_data_check_column_extra_campo <- function(xlsx_name, csv_name, output_path) {
  raw_data <- readr::read_csv(csv_name, show_col_types = FALSE)
  date_send_data <- extract_date_from_filename(xlsx_name)
  add_column_fecha_envio_revision_campo(raw_data, date_send_data) |>
    readr::write_csv("/workdir/tests/data/cameras_extra_campo_with_date.csv")
}
