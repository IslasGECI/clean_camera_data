describe("Cli for module", {
  it("add_column", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_campo.csv"
    xlsx_name <- "IG_CAMARA_TRAMPA_EXTRA_23NOV2023.xls"
    add_data_check_column_extra_campo(xlsx_name, csv_name)
    output_with_date <- "/workdir/tests/data/cameras_extra_campo_with_date.csv"
    expect_true(testtools::exist_output_file(output_with_date))
    obtained <- readr::read_csv(output_with_date)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 4
    expect_equal(obtained_ncol, expected_ncol)
  })
})
