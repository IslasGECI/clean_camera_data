describe("compute daily summary", {
  cameras_daily_status_df <- readr::read_csv("/workdir/tests/data/cameras_daily_status.csv", show_col_types = FALSE)
  obtained <- compute_daily_summary(cameras_daily_status_df)
  obtained_column_names <- colnames(obtained)
  expected_column_names <- c("Date", "Number_of_camera_traps", "Effort", "Total_photos", "Total_individuals")
  expect_true(all(expected_column_names %in% obtained_column_names))
})

describe("Create cameras daily status", {
  cameras_campo_df <- tibble::tibble(
    "Fecha_revision_campo" = c(rep("2022-01-02", 4), rep("2022-01-04", 3)),
    "ID_camara_trampa" = c("CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT", "CT-01-www-CT", "CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT"),
    "Revision" = rep("si", 7),
    "Estado_camara" = c("R", rep("A", 6))
  )
  cameras_memoria_df <- tibble::tibble(
    "Fecha_captura_foto" = c(rep(NA, 4), NA, "2022-01-03", "2022-01-04"),
    "ID_camara" = c("CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT", "CT-01-www-CT", "CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT"),
    "Individuos_capturados" = c(rep(NA, 2), rep(0, 3), 1, 2),
    "Fotos_capturadas" = c(rep(NA, 5), 100, 1900)
  )
  it("compute_daily_status", {
    obtained <- compute_daily_status(cameras_campo_df, cameras_memoria_df)
    dplyr::glimpse(obtained)
    expected_column_names <- c("Date", "ID", "camera_status", "Individuos_capturados", "Fotos_capturadas")
    obtained_column_names <- colnames(obtained)
    expect_true(all(expected_column_names %in% obtained_column_names))
    expected_rows <- 10
    expect_equal(nrow(obtained), expected_rows)
    expected_individuals_for_ct_zzz <- 2
    expect_equal(obtained$Individuos_capturados[10], expected_individuals_for_ct_zzz)
  })
})
