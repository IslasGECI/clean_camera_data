describe("compute daily summary", {
  cameras_daily_status_df <- readr::read_csv("/workdir/tests/data/cameras_daily_status.csv", show_col_types = FALSE)
  obtained <- compute_daily_summary(cameras_daily_status_df)
  obtained_column_names <- colnames(obtained)
  expected_column_names <- c("Date", "Number_of_camera_traps", "Effort", "Total_photos", "Total_individuals")
  expect_true(all(expected_column_names %in% obtained_column_names))
  expected_effort_2022_01_02 <- 3
  obtained_effort_2022_01_02 <- obtained[obtained$Date == "2022-01-02", ]$Effort
  expect_equal(obtained_effort_2022_01_02, expected_effort_2022_01_02)
})

describe("Create cameras daily status", {
  cameras_campo_df <- readr::read_csv("/workdir/tests/data/camaras_campo.csv")
  cameras_memoria_df <- readr::read_csv("/workdir/tests/data/camaras_memoria.csv")
  it("compute_daily_status", {
    obtained <- compute_daily_status(cameras_campo_df, cameras_memoria_df)
    print(obtained)
    expected_column_names <- c("Date", "ID", "camera_status", "Individuos_capturados", "Fotos_capturadas")
    obtained_column_names <- colnames(obtained)
    expect_true(all(expected_column_names %in% obtained_column_names))
    expected_rows <- 24
    expect_equal(nrow(obtained), expected_rows)
    expected_individuals_for_ct_zzz <- 2
    expect_equal(obtained[obtained$ID == "CT-01-zzz-CT" & obtained$Date == "2022-01-04", ]$Individuos_capturados, expected_individuals_for_ct_zzz)
    expected_status_for_ct_www <- c(rep("A", 4), "R")
    expect_equal(obtained[obtained$ID == "CT-01-www-CT", ]$camera_status, expected_status_for_ct_www)
    expected_status_for_ct_ad1 <- c(rep("A", 3), rep("D", 2))
    expect_equal(obtained[obtained$ID == "CT-01-ad1-CT", ]$camera_status, expected_status_for_ct_ad1)
    expected_status_for_ct_ad2 <- c(rep("A", 3), rep("D", 3))
    expect_equal(obtained[obtained$ID == "CT-01-ad2-CT", ]$camera_status, expected_status_for_ct_ad2)
  })
})
