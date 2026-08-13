compute_daily_summary <- function(cameras_daily_status_df) {
  cameras_daily_status_df |>
    dplyr::filter(camera_status == "A") |>
    dplyr::group_by(Date) |>
    dplyr::summarise(
      Number_of_camera_traps = dplyr::n_distinct(ID),
      Total_photos = sum(Fotos_capturadas, na.rm = TRUE),
      Total_individuals = sum(Individuos_capturados, na.rm = TRUE),
      Effort = dplyr::n_distinct(ID),
    ) |>
    dplyr::ungroup()
}

compute_daily_status <- function(cameras_campo_df, cameras_memoria_df) {
  daily_status_grid <- rename_camera_field_check_columns(cameras_campo_df) |>
    fill_daily_camera_status(cameras_memoria_df) |>
    add_taken_photos_and_individuals_to_daily_status_grid(cameras_memoria_df)
}

add_taken_photos_and_individuals_to_daily_status_grid <- function(daily_status_grid, cameras_memoria_df) {
  daily_status_grid |>
    dplyr::left_join(cameras_memoria_df, by = dplyr::join_by(ID == ID_camara, Date == Fecha_captura_foto))
}

fill_daily_camera_status <- function(field_check_records, cameras_memoria_df) {
  photo_info <- get_photo_info_by_camera(cameras_memoria_df)
  field_check_records |>
    dplyr::group_by(ID) |>
    dplyr::group_modify(~ fill_camera_daily_status(.x, .y$ID, photo_info)) |>
    dplyr::ungroup()
}

rename_camera_field_check_columns <- function(cameras_campo_df) {
  cameras_campo_df |>
    dplyr::rename(Date = Fecha_revision_campo, ID = ID_camara_trampa, camera_status = Estado_camara)
}

get_photo_info_by_camera <- function(cameras_memoria_df) {
  cameras_memoria_df |>
    dplyr::group_by(ID_camara) |>
    dplyr::summarise(
      photo_dates = list(sort(unique(Fecha_captura_foto[!is.na(Fecha_captura_foto)]))),
      has_photos = any(Fotos_capturadas > 0, na.rm = TRUE),
      .groups = "drop"
    )
}

fill_camera_daily_status <- function(checks, camera_id, photo_info) {
  checks <- dplyr::arrange(checks, Date)
  if (nrow(checks) == 1L) {
    return(tibble::tibble(Date = checks$Date, camera_status = checks$camera_status))
  }
  dates <- seq(min(checks$Date), max(checks$Date), by = "day")
  status <- rep(NA_character_, length(dates))
  for (i in seq_len(nrow(checks) - 1L)) {
    in_period <- dates >= checks$Date[i] & dates <= checks$Date[i + 1L]
    status[in_period] <- fill_period(
      dates[in_period],
      checks$camera_status[i],
      checks$camera_status[i + 1L],
      camera_id,
      photo_info
    )
  }
  tibble::tibble(Date = dates, camera_status = status)
}

fill_period <- function(days, from, to, camera_id, photo_info) {
  n <- length(days)
  if (from == "A" && to == "A") {
    return(rep("A", n))
  }
  if (from == "D" && to == "A") {
    return(rep("A", n))
  }
  if (from == "R" && to == "A") {
    return(c(rep("R", n - 1L), "A"))
  }
  status <- fill_a_to_d_criterion(days, camera_id, photo_info)
  if (to == "R") {
    status[n] <- "R"
  }
  status
}

fill_a_to_d_criterion <- function(days, camera_id, photo_info) {
  camera_photo_info <- photo_info_for_camera(photo_info, camera_id)
  if (is.null(camera_photo_info)) {
    return(fill_all_days_down(days))
  }
  evidence_in_period <- photo_evidence_in_period(days, camera_photo_info$photo_dates)
  if (!is.null(evidence_in_period)) {
    return(fill_active_down_until_last_evidence(days, max(evidence_in_period)))
  }
  if (camera_photo_info$has_photos) {
    return(fill_pessimistic_midpoint(days))
  }
  fill_all_days_down(days)
}

photo_info_for_camera <- function(photo_info, camera_id) {
  info <- photo_info[photo_info$ID_camara == camera_id, ]
  if (nrow(info) == 0L) {
    return(NULL)
  }
  list(
    photo_dates = info$photo_dates[[1L]],
    has_photos = info$has_photos
  )
}

photo_evidence_in_period <- function(days, photo_dates) {
  within_period <- photo_dates[photo_dates >= min(days) & photo_dates <= max(days)]
  if (length(within_period) == 0L) NULL else within_period
}

fill_active_down_until_last_evidence <- function(days, last_evidence) {
  ifelse(days <= last_evidence, "A", "D")
}

fill_pessimistic_midpoint <- function(days) {
  active_days <- floor(length(days) / 2)
  c(rep("A", active_days), rep("D", length(days) - active_days))
}

fill_all_days_down <- function(days) {
  rep("D", length(days))
}
