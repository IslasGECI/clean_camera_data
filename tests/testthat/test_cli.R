describe("Cli for module", {
  it("add_column", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_campo.csv"
    xlsx_name <- "IG_CAMARA_TRAMPA_EXTRA_23NOV2023.xls"
    add_data_check_column_extra_campo(xlsx_name, csv_name)
    expect_true(testtools::exist_output_file(csv_name))
  })
})
