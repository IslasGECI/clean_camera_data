describe("Calculate effor by month and week", {
  revision_campo <- readr::read_csv("/workdir/tests/data/revision_campo_cameras_example.csv", show_col_types = FALSE)
  obtained_effort <- change_to_tidy_effort_format(revision_campo)
  it("check columns", {
    obtained_columns <- colnames(obtained_effort)
    expected_columns <- c("e", "Session", "Ocassion")
    expect_true(all(expected_columns %in% obtained_columns))
  })
  it("check filling of ocassions for one ID", {
    revision_campo <- tibble::tibble(
      Date = c("2025-11-16", "2025-11-30"),
      ID_camara_trampa = rep("CT-04-049-JV", 2),
      Revision = rep("si", 2),
      Estado_camara = rep("A", 2)
    )
    obtained <- fill_ocassions(revision_campo)
    expected_ocassions <- 3
    expect_equal(nrow(obtained), expected_ocassions)
    expect_filled_date <- lubridate::ymd(c("2025-11-16", "2025-11-23", "2025-11-30"))
    expect_equal(obtained$Date, expect_filled_date)
    expect_equal(obtained$ID_camara_trampa, rep("CT-04-049-JV", 3))
  })
  it("check filling of ocassions for two ID", {
    revision_campo <- tibble::tibble(
      Date = c("2025-11-16", "2025-11-30", "2025-11-23"),
      ID_camara_trampa = c("CT-04-049-JV", "CT-04-049-JV", "CT-04-999-LM"),
      Revision = rep("si", 3),
      Estado_camara = rep("A", 3)
    )
    obtained <- fill_ocassions(revision_campo)
    expected_ocassions <- 4
    expect_equal(nrow(obtained), expected_ocassions)
    expect_filled_date <- lubridate::ymd(c("2025-11-16", "2025-11-23", "2025-11-30", "2025-11-23"))
    expect_equal(obtained$Date, expect_filled_date)
    expect_equal(obtained$ID_camara_trampa, c(rep("CT-04-049-JV", 3), "CT-04-999-LM"))
  })
  it("check effort values", {
    obtained <- change_to_tidy_effort_format(revision_campo[22:23, ])
    expected_effort <- rep(7, 3)
    expect_equal(obtained$e, expected_effort)
  })
  it("check effort values for deactivated trap", {
    revision_campo$Estado_camara[23] <- "D"
    obtained <- change_to_tidy_effort_format(revision_campo[22:23, ])
    expected_effort <- c(7, 7, 0)
    expect_equal(obtained$e, expected_effort)
  })
  example_tibble <- tibble::tibble(Date = c("2021-08-11", "2021-08-20", "2021-10-24", "2022-01-18", "2022-03-04", "2022-04-23", "2022-05-19"))
  it("test get_session with new tables", {
    obtained_session <- get_session(example_tibble)
    expected_session <- c("2021-8", "2021-8", "2021-10", "2022-1", "2022-3", "2022-4", "2022-5")
    expect_equal(obtained_session$Session, expected_session)
  })
  it("test get_ocassion with new tables", {
    obtained_ocassion <- get_ocassion(example_tibble)
    expected_ocassion <- c(33, 34, 43, 4, 10, 17, 21)
    expect_equal(obtained_ocassion[["Ocassion"]], expected_ocassion)
  })
})
describe("get_week_of_year_from_date", {
  it("Testing January", {
    expected_week <- 1
    date <- "2007-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2008-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2009-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2010-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2011-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2012-01-01"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
  })
  it("Testing December", {
    expected_week <- 53
    date <- "2007-12-31"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2008-12-31"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2009-12-31"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2010-12-31"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2011-12-31"
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
    date <- "2012-12-31"
    expected_week <- 54
    obtained_week <- get_week_of_year_from_date(date)
    expect_equal(obtained_week, expected_week)
  })
})
