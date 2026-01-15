describe("join into one table the info from camera traps", {
  revision_campo_df <- readr::read_csv("/workdir/tests/data/camaras_revision_campo.csv", show_col_types = FALSE)
  revision_memoria_df <- readr::read_csv("/workdir/tests/data/camaras_revision_memoria.csv", show_col_types = FALSE)
  it("preprocess memory check data", {
    obtained <- get_weekly_pictures_summary(revision_memoria_df)
    obtained_first_row <- obtained[1, ]
    expect_equal(obtained_first_row$Fotos_capturadas, 5504)
    expect_equal(obtained_first_row$Individuos_capturados, 3)
  })
  it("assert columns of joined", {
    obtained <- join_cameras_info(revision_campo_df, revision_memoria_df)
    expected_columns <- c("ID_camara_trampa", "Fotos_capturadas", "Fecha_envio_datos", "Fecha_revision_campo", "Individuos_capturados", "Estado_camara")
    obtained_colnames <- colnames(obtained)
    expect_true(all(expected_columns %in% obtained_colnames))
    expect_equal(length(expected_columns), length(obtained_colnames))
    expected_nrows <- 3
    expect_equal(nrow(obtained), expected_nrows)
  })
  it("calculate effort from joined table", {
    joined_cameras_info <- tibble::tibble(
      ID_camara_trampa = rep("CA-03-012-CA", 3),
      Fotos_capturadas = c(5504, 760, 1210),
      Fecha_envio_datos = c("02/Nov/2025", "09/Nov/2025", "30/Nov/2025"),
      Fecha_revision_campo = c("28/Oct/2025", "07/Nov/2025", "24/Nov/2025"),
      Individuos_capturados = c(3, 0, 4),
      Estado_camara = c("A", "A", "D")
    )
    obtained <- get_cameras_effort(joined_cameras_info)
    print(obtained)
    obtained_colnames <- colnames(obtained)
    expect_true("effort" %in% obtained_colnames)
    obtained_second_row <- obtained[2, ]
    expected_second_row_effort <- 7
    expect_equal(obtained_second_row$effort, expected_second_row_effort)
    obtained_third_row <- obtained[3, ]
    expected_third_row_effort <- 15
    expect_equal(obtained_third_row$effort, expected_third_row_effort)
  })
})
