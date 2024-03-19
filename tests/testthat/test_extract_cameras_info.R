describe("extract cameras info", {
  it("extract_cameras_info", {
    revision_campo_tibble <- readr::read_csv("/workdir/tests/data/cameras_extra_revision_campo_with_coordinates.csv", show_col_types = FALSE)
    obtained <- extract_cameras_info(revision_campo_tibble)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 4
    expect_equal(obtained_ncol, expected_ncol)
  })
  it("split cameras info and check date", {
    cameras_with_check_date <- readr::read_csv("/workdir/tests/data/cameras_extra_revision_campo_with_coordinates.csv", show_col_types = FALSE)
    obtained <- select_last_check_date(cameras_with_check_date)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 2
    expect_equal(obtained_ncol, expected_ncol)
  })
})

describe("`sort_cameras_ by_id()`", {
  it("Only CA", {
    messy_cameras <- tibble::tibble(ID_camara = c("CA-01-005-CA", "CA-01-002-CA", "CA-01-004-CA", "CA-01-001-CA", "CA-01-003-CA"))
    expected_cameras <- tibble::tibble(ID_camara = c("CA-01-001-CA", "CA-01-002-CA", "CA-01-003-CA", "CA-01-004-CA", "CA-01-005-CA"))
    obtained_cameras <- sort_cameras_by_id(messy_cameras)
    expect_equal(obtained_cameras, expected_cameras)
  })
  it("Between CA and CT", {
    messy_cameras <- tibble::tibble(ID_camara = c("CT-08-004-LM", "CA-01-002-CA"))
    expected_cameras <- tibble::tibble(ID_camara = c("CA-01-002-CA", "CT-08-004-LM"))
    obtained_cameras <- sort_cameras_by_id(messy_cameras)
    expect_equal(obtained_cameras, expected_cameras)
  })
  it("Between zones", {
    messy_cameras <- tibble::tibble(ID_camara = c("CA-02-002-CA", "CA-01-002-CA"))
    expected_cameras <- tibble::tibble(ID_camara = c("CA-01-002-CA", "CA-02-002-CA"))
    obtained_cameras <- sort_cameras_by_id(messy_cameras)
    expect_equal(obtained_cameras, expected_cameras)
  })
  it("Between zones", {
    messy_cameras <- tibble::tibble(ID_camara = c("CA-01-001-ED", "CA-01-001-CA"))
    expected_cameras <- tibble::tibble(ID_camara = c("CA-01-001-CA", "CA-01-001-ED"))
    obtained_cameras <- sort_cameras_by_id(messy_cameras)
    expect_equal(obtained_cameras, expected_cameras)
  })
})
