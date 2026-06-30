describe("Create cameras daily status", {
  cameras_campo_df <- tibble::tibble(
    "Fecha_revision_campo" = c(rep("2022-01-02", 4), rep("2022-01-03", 3)),
    "ID_camara_trampa" = c("CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT", "CT-01-www-CT", "CT-01-xxx-CT", "CT-01-yyy-CT", "CT-01-zzz-CT"),
    "Revision" = rep("si", 7),
    "Estado_camara" = rep("A", 7)
  )
  it("compute_daily_status", {
    obtained <- compute_daily_status(cameras_campo_df)
    expected_column_names <- c("Date,ID,camera_status")
    obtained_column_names <- colnames(obtained)
    expect_true(all(expected_column_names %in% obtained_column_names))
  })
})
