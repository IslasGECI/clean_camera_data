describe("calculate cameras summary", {
  revision_campo_df <- readr::read_csv("/workdir/tests/data/camaras_revision_campo.csv", show_col_types = FALSE)
  revision_memoria_df <- readr::read_csv("/workdir/tests/data/camaras_revision_memoria.csv", show_col_types = FALSE)
  it("assert columns of summary", {
    expected_columns <- c("Date", "Number_of_camera_traps", "Effort", "Total_photos", "Total_individuals")
    obtained <- calculate_cameras_summary(revision_campo_df, revision_memoria_df)
    obtained_colnames <- colnames(obtained)
    expect_true(all(expected_columns %in% obtained_colnames))

    expected_nrow <- 5
    expect_equal(nrow(obtained), expected_nrow)
    expected_number_of_cameras <- 2
    expect_equal(obtained$Number_of_camera_traps[4], expected_number_of_cameras)
    expected_effort <- 59
    expect_equal(obtained$Effort[2], expected_effort)
    expected_total_photos <- 378
    expect_equal(obtained$Total_photos[2], expected_total_photos)
    expected_total_individuals <- 2
    expect_equal(obtained$Total_individuals[2], expected_total_individuals)
  })
})
revision_campo_one_id <- tibble::tibble(
  ID_camara_trampa = c("CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA"),
  Fecha_revision_campo = c("28/Oct/2025", "07/Nov/2025", "24/Nov/2025"),
  Fecha_envio_datos = c("02/Nov/2025", "09/Nov/2025", "30/Nov/2025"),
  Revision = c("si", "si", "si"),
  Estado_camara = c("A", "A", "D"),
  Estado_memoria = c("MF", "MF", "MF"),
)

describe("fill missing weeks with sunday date", {
  obtained <- fill_missing_sundays(revision_campo_one_id)
  it("check there is all sunday", {
    expected_number_of_weeks <- 5
    expect_equal(nrow(obtained), expected_number_of_weeks)
  })
})

describe("join into one table the info from camera traps", {
  revision_memoria_df <- tibble::tibble(
    ID_camara = c("CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA", "CA-03-012-CA"),
    Fotos_capturadas = c(5504.0, 5505.0, 5506.0, 760.0, 1210.0, 1210.0, 1210.0),
    Fecha_envio_datos = c("2025-11-02", "2025-11-02", "2025-11-02", "2025-11-09", "2025-11-30", "2025-11-30", "2025-11-30"),
    Fecha_captura_foto = c("2025-08-09", "2025-10-23", "2025-10-27", "08/Oct/2025-10-08", "2025-11-24", "2025-11-24", "2025-11-22"),
    Individuos_capturados = c(1.0, 1.0, 1.0, NA, 2.0, 1.0, 1.0),
  )
  it("preprocess memory check data", {
    obtained <- get_weekly_pictures_summary(revision_memoria_df)
    obtained_first_row <- obtained[1, ]
    expect_equal(obtained_first_row$Fotos_capturadas, 5504)
    expect_equal(obtained_first_row$Individuos_capturados, 3)
  })
  it("assert columns of joined", {
    filled_revision_campo_one_id <- tibble::tibble(
      ID_camara_trampa = rep("CA-03-012-CA", 5),
      Fecha_revision_campo = c("2025-10-28", "2025-11-07", NA, NA, "2025-11-24"),
      Fecha_envio_datos = c("2025-11-02", "2025-11-09", "2025-11-16", "2025-11-23", "2025-11-30"),
      Revision = c("si", "si", NA, NA, "si"),
      Estado_camara = c("A", "A", NA, NA, "D"),
      Estado_memoria = c("MF", "MF", NA, NA, "MF"),
    )
    obtained <- join_cameras_info(filled_revision_campo_one_id, revision_memoria_df)
    expected_columns <- c("ID_camara_trampa", "Fotos_capturadas", "Fecha_envio_datos", "Fecha_revision_campo", "Individuos_capturados", "Estado_camara")
    obtained_colnames <- colnames(obtained)
    expect_true(all(expected_columns %in% obtained_colnames))
    expect_equal(length(expected_columns), length(obtained_colnames))
    expected_nrows <- 5
    expect_equal(nrow(obtained), expected_nrows)
    print(obtained)
  })
  it("calculate effort from joined table", {
    joined_cameras_info <- tibble::tibble(
      ID_camara_trampa = rep("CA-03-012-CA", 3),
      Fotos_capturadas = c(760, 5504, 1210),
      Fecha_envio_datos = lubridate::ymd(c("2025-11-02", "2025-11-09", "2025-11-30")),
      Fecha_revision_campo = lubridate::ymd(c("2025-10-28", "2025-11-07", "2025-11-24")),
      Individuos_capturados = c(0, 3, 4),
      Estado_camara = c("A", "A", "D")
    )
    obtained <- xxget_cameras_effort(joined_cameras_info)
    obtained_colnames <- colnames(obtained)
    expect_true("effort" %in% obtained_colnames)
    obtained_second_row <- obtained[2, ]
    expected_second_row_effort <- 7
    expect_equal(obtained_second_row$effort, expected_second_row_effort)
    obtained_third_row <- obtained[3, ]
    expected_third_row_effort <- 15
    expect_equal(obtained_third_row$effort, expected_third_row_effort)

    joined_cameras_info_with_two_ids <- tibble::tibble(
      ID_camara_trampa = c("CA-03-013-CA", rep("CA-03-012-CA", 5)),
      Fotos_capturadas = c(123, 5504, 760, 1210, NA, NA),
      Fecha_envio_datos = c("30/Nov/2025", "09/Nov/2025", "02/Nov/2025", "30/Nov/2025", "16/Nov/2025", "23/Nov/2025"),
      Fecha_revision_campo = c("24/Nov/2025", "07/Nov/2025", "28/Oct/2025", "24/Nov/2025", NA, NA),
      Individuos_capturados = c(5, 3, 0, 4, NA, NA),
      Estado_camara = c("A", "A", "A", "D", "A", "A")
    )
    obtained <- get_cameras_effort(joined_cameras_info_with_two_ids)
    obtained_number_of_weeks <- nrow(obtained)
    expected_number_of_weeks <- 6
    expect_equal(obtained_number_of_weeks, expected_number_of_weeks)
    obtained_second_row <- obtained[2, ]
    expected_second_row_effort <- 7
    expect_equal(obtained_second_row$effort, expected_second_row_effort)
    obtained_third_row <- obtained[3, ]
    expected_third_row_effort <- 7
    expect_equal(obtained_third_row$effort, expected_third_row_effort)
    obtained_fifth_row <- obtained[5, ]
    expected_fifth_row_effort <- 1
    expect_equal(obtained_fifth_row$effort, expected_fifth_row_effort)
  })
})
