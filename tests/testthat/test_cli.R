describe("Get version of the module", {
  it("The version is 0.2.0", {
    expected_version <- c("0.2.0")
    obtained_version <- packageVersion("cameraData")
    version_are_equal <- expected_version == obtained_version
    expect_true(version_are_equal)
  })
})

describe("Cli for module", {
  it("write_cameras_last_check", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_campo_with_coordinates.csv"
    output_path <- "/workdir/tests/data/cameras_last_check.csv"
    write_cameras_last_check(csv_name, output_path)
    expect_true(testtools::exist_output_file(output_path))
    testtools::delete_output_file(output_path)
  })
  it("write_camera_info", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_campo_with_coordinates.csv"
    output_path <- "/workdir/tests/data/cameras_info.csv"
    write_camera_info(csv_name, output_path)
    expect_true(testtools::exist_output_file(output_path))
    testtools::delete_output_file(output_path)
  })
  it("add_column", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_campo.csv"
    xlsx_name <- "IG_CAMARA_TRAMPA_EXTRA_23NOV2023.xls"
    output_with_date <- "/workdir/tests/data/cameras_extra_campo_with_date.csv"
    add_data_check_column_to_campo(xlsx_name, csv_name, output_path = output_with_date)
    expect_true(testtools::exist_output_file(output_with_date))
    obtained <- readr::read_csv(output_with_date, show_col_types = FALSE)
    testtools::delete_output_file(output_with_date)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 4
    expect_equal(obtained_ncol, expected_ncol)

    add_data_check_column_to_campo(xlsx_name, csv_name)
    default_output <- "/workdir/cameras_extra_revision_campo.csv"
    expect_true(testtools::exist_output_file(default_output))
    testtools::delete_output_file(default_output)
  })
  it("add date column to memoria", {
    csv_name <- "/workdir/tests/data/cameras_extra_revision_memoria.csv"
    xlsx_name <- "IG_CAMARA_TRAMPA_EXTRA_23NOV2023.xls"
    output_with_date <- "/workdir/tests/data/cameras_extra_memoria_with_date.csv"
    add_data_check_column_to_memoria(xlsx_name, csv_name, output_path = output_with_date)
    expect_true(testtools::exist_output_file(output_with_date))
    obtained <- readr::read_csv(output_with_date, show_col_types = FALSE)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 4
    expect_equal(obtained_ncol, expected_ncol)
    testtools::delete_output_file(output_with_date)
  })
})
