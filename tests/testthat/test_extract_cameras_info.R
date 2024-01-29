describe("extract cameras info", {
  it("extract_cameras_info", {
    revision_campo_tibble <- readr::read_csv("/workdir/tests/data/cameras_extra_revision_campo_with_coordinates.csv", show_col_types = FALSE)
    obtained <- extract_cameras_info(revision_campo_tibble)
    obtained_ncol <- ncol(obtained)
    expected_ncol <- 5
    expect_equal(obtained_ncol, expected_ncol)
  })
})
