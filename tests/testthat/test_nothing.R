describe("Test all is ready", {
  it("Return one", {
    expected <- 1
    obtained <- return_one()
    expect_equal(expected, obtained)
  })
})

describe("Get version of the module", {
  it("The version is 0.1.0", {
    expected_version <- c("0.1.0")
    obtained_version <- packageVersion("cameraData")
    version_are_equal <- expected_version == obtained_version
    expect_true(version_are_equal)
  })
})

describe("Get fecha de envio from name file", {
  it("File: IG_CAMARA_TRAMPA_EXTRA_19NOV2023", {
    file_name <- "IG_CAMARA_TRAMPA_EXTRA_19NOV2023.csv"
    expected <- "19/Nov/2023"
    obtained <- extract_date_from_filename(file_name)
    expect_equal(obtained, expected)
  })
})
