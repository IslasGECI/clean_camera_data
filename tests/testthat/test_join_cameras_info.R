describe("join into one table the info from camera traps", {
  revision_campo_df <- readr::read_csv("/workdir/tests/data/camaras_revision_campo.csv", show_col_types = FALSE)
  revision_memoria_df <- readr::read_csv("/workdir/tests/data/camaras_revision_memoria.csv", show_col_types = FALSE)
  it("assert columns of joined", {
    obtained <- join_cameras_info(revision_campo_df, revision_memoria_df)
    expected_columns <- c("ID_camara_trampa", "Fotos_capturadas", "Fecha_envio_datos", "Fecha_revision_campo", "Individuos_capturados", "Estado_camara")
    obtained_colnames <- colnames(obtained)
    expect_true(all(expected_columns %in% obtained_colnames))
    expect_equal(length(expected_columns), length(obtained_colnames))
  })
})
