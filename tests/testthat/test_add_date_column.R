describe("Get fecha de envio from name file", {
  it("File: IG_CAMARA_TRAMPA_EXTRA_19NOV2023", {
    file_name <- "IG_CAMARA_TRAMPA_EXTRA_19NOV2023.csv"
    expected <- "19/Nov/2023"
    obtained <- extract_date_from_filename(file_name)
    expect_equal(obtained, expected)

    file_name <- "IG_CAMARA_TRAMPA_EXTRA_05NOV2023.csv"
    expected <- "05/Nov/2023"
    obtained <- extract_date_from_filename(file_name)
    expect_equal(obtained, expected)

    file_name <- "IG_CAMARA_TRAMPA_EXTRA_05NOV2023.xlsx"
    expected <- "05/Nov/2023"
    obtained <- extract_date_from_filename(file_name)
    expect_equal(obtained, expected)
  })
})

describe("Add column 'Fecha_envio_datos' after columns ''", {
  it("Add column to Revision Campo", {
    raw_data <- tibble::tibble("Ultima_revision" = "fecha", "Fecha_revision" = 1:3, "Responsable" = letters[1:3], "Lineas" = 4:6)
    expected <- tibble::tibble("Fecha_revision" = 1:3, Fecha_envio_datos = rep("22/Nov/2023", 3), "Responsable" = letters[1:3])
    obtained <- add_column_fecha_envio_revision_campo(raw_data, "22/Nov/2023")
    expect_equal(obtained, expected)
  })
  it("Add column to Revision Memoria", {
    raw_data <- tibble::tibble("Fotos capturadas" = 1:3, "Fecha_captura_foto" = letters[1:3], "Lineas" = 4:6)
    expected <- tibble::tibble("Fotos capturadas" = 1:3, Fecha_envio_datos = rep("25/Dic/2023", 3), "Fecha_captura_foto" = letters[1:3])
    obtained <- add_column_fecha_envio_revision_memoria(raw_data, "25/Dic/2023")
    expect_equal(obtained, expected)
  })
})
