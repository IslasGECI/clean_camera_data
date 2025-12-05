describe("Calculate effor by month and week", {
  revision_campo <- readr::read_csv("/workdir/tests/data/revision_campo_cameras_example.csv", show_col_types = FALSE)
  obtained_effort <- calculate_effort(revision_campo)
  it("check columns", {
    obtained_columns <- colnames(obtained_effort)
    expected_columns <- c("e", "Session", "Ocassion")
    expect_true(all(obtained_columns %in% expected_columns))
  })
  example_tibble <- tibble::tibble(Date = c("2021-08-11", "2021-08-20", "2021-10-24", "2022-01-18", "2022-03-04", "2022-04-23", "2022-05-19"))
  it("test get_session with new tables", {
    obtained_session <- get_session(example_tibble)
    expected_session <- c("2021-8", "2021-8", "2021-10", "2022-1", "2022-3", "2022-4", "2022-5")
    expect_equal(obtained_session$Session, expected_session)
  })
  it("test get_ocassion with new tables", {
    obtained_ocassion <- get_ocassion(example_tibble)
    expected_ocassion <- c(32, 33, 43, 3, 9, 16, 20)
    expect_equal(obtained_ocassion$Ocassion, expected_ocassion)
  })
})
