describe("Calculate effor by month and week", {
  revision_campo <- readr::read_csv("/workdir/tests/data/revision_campo_cameras_example.csv", show_col_types = FALSE)
  it("check columns", {
    obtained_effort <- calculate_effort(revision_campo)
    obtained_columns <- colnames(obtained_effort)
    expected_columns <- c("e", "Session", "Ocassion")
    expect_true(all(obtained_columns %in% expected_columns))
  })
})
