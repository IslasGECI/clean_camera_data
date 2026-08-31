describe("compute daily summary", {
  cameras_daily_status_df <- readr::read_csv("/workdir/tests/data/cameras_daily_status.csv", show_col_types = FALSE)
  obtained <- compute_daily_summary(cameras_daily_status_df)
  print(obtained)
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
  obtained <- compute_daily_status(cameras_campo_df, cameras_memoria_df)
  obtained |> readr::write_csv("prueba.csv")
  it("assert structure", {
    expected_column_names <- c("Date", "ID", "camera_status", "Individuos_capturados", "Fotos_capturadas")
    obtained_column_names <- colnames(obtained)
    expect_true(all(expected_column_names %in% obtained_column_names))
    expected_rows <- 76
    expect_equal(nrow(obtained), expected_rows)
  })
  it("assert status", {
    expected_individuals_for_ct_zzz <- 2
    expect_equal(obtained[obtained$ID == "CT-01-zzz-CT" & obtained$Date == "2022-01-04", ]$Individuos_capturados, expected_individuals_for_ct_zzz)
    expected_status_for_ct_www <- c(rep("A", 2), rep("D", 2), "R")
    expect_equal(obtained[obtained$ID == "CT-01-www-CT", ]$camera_status, expected_status_for_ct_www)
    expected_status_for_ct_ad1 <- c(rep("A", 3), rep("D", 2))
    expect_equal(obtained[obtained$ID == "CT-01-ad1-CT", ]$camera_status, expected_status_for_ct_ad1)
    expected_status_for_ct_ad2 <- c(rep("A", 3), rep("D", 3))
    expect_equal(obtained[obtained$ID == "CT-01-ad2-CT", ]$camera_status, expected_status_for_ct_ad2)
    expected_status_for_ct_ad3 <- c(rep("D", 3))
    expect_equal(obtained[obtained$ID == "CT-01-ad3-CT", ]$camera_status, expected_status_for_ct_ad3)
    expected_status_for_ct_da1 <- c(rep("A", 3))
    expect_equal(obtained[obtained$ID == "CT-01-da1-CT", ]$camera_status, expected_status_for_ct_da1)
    expected_status_for_ct_dd1 <- c(rep("A", 2), rep("D", 2))
    expect_equal(obtained[obtained$ID == "CT-01-dd1-CT", ]$camera_status, expected_status_for_ct_dd1)
    expected_status_for_ct_dr1 <- c(rep("A", 2), "D", "R")
    expect_equal(obtained[obtained$ID == "CT-01-dr1-CT", ]$camera_status, expected_status_for_ct_dr1)
    expected_status_for_ct_xxx <- c(rep("R", 2), rep("A", 8))
    expect_equal(obtained[obtained$ID == "CT-01-xxx-CT", ]$camera_status, expected_status_for_ct_xxx)
    expected_status_for_ct_rad <- c(rep("R", 2), rep("A", 2), rep("D", 3))
    expect_equal(obtained[obtained$ID == "CT-01-rad-CT", ]$camera_status, expected_status_for_ct_rad)
    expected_status_for_ct_dad <- c(rep("A", 6), "D")
    expect_equal(obtained[obtained$ID == "CT-01-dad-CT", ]$camera_status, expected_status_for_ct_dad)
  })
  it("assert captures", {
    expected_individual_captures_for_ct_01_double <- 2
    obtained_individual_captures_for_ct_01_double <- sum(obtained[obtained$ID == "CT-01-double-CT", ]$Individuos_capturados, na.rm = TRUE)
    expect_equal(obtained_individual_captures_for_ct_01_double, expected_individual_captures_for_ct_01_double)
    obtained_total_photos_taken_for_ct_01_double <- obtained[obtained$ID == "CT-01-double-CT" & obtained$Date == "2022-01-03", ]$Fotos_capturadas
    expected_total_photos <- 72
    expect_equal(obtained_total_photos_taken_for_ct_01_double, expected_total_photos)

    obtained_individual_capture_for_ct_02_double_ene03 <- obtained[obtained$ID == "CT-02-double-CT" & obtained$Date == "2022-01-03", ]$Individuos_capturados
    expected_capture_for_ct_02_ene03 <- 1
    expect_equal(obtained_individual_capture_for_ct_02_double_ene03, expected_capture_for_ct_02_ene03)
  })
})
