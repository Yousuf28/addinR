#!/usr/bin/env Rscript

# This code is for creating
# -----------------------------------------------------------------------------
# Date                     Programmer
#----------   --------------------------------------------------------------
# Nov-11-2025    Md Yousuf Ali (yousuf.pharma@gmail.com)

#' @import rstudioapi
#' @import clipr

replace_backslash_with_forwardslash <- function() {

  ctx <- rstudioapi::getActiveDocumentContext()
  sel <- ctx$selection[[1]]

  # Only proceed if there is selected text
  if (nzchar(sel$text)) {
    replaced <- gsub("\\\\", "/", sel$text)
    rstudioapi::modifyRange(sel$range, replaced)
  }
  # If no text is selected, do nothing (no else clause needed)
}

replace_forwardslash_with_backslash <- function() {
  if (!rstudioapi::isAvailable()) {
    message("RStudio API not available.")
    return(invisible(NULL))
  }

  context <- rstudioapi::getActiveDocumentContext()
  selected <- context$selection[[1]]$text

  if (nchar(selected) == 0) {
    message("Select text with forward slashes first.")
    return(invisible(NULL))
  }

  converted <- gsub("/", "\\\\", selected)
  rstudioapi::modifyRange(context$selection[[1]]$range, converted)
}


open_current_directory_in_file_explorer <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  path <- ctx$path

  dir <- if (nzchar(path)) dirname(path) else getwd()

  if (.Platform$OS.type == "windows") {
    shell.exec(normalizePath(dir))
  } else if (Sys.info()[["sysname"]] == "Darwin") {
    system2("open", shQuote(dir))
  } else if (.Platform$OS.type == "unix") {
    system2("xdg-open", shQuote(dir))
  } else {
    message("Unsupported system type")
  }
}


open_git_bash_here <- function(dir = getwd()) {
  candidates <- c(
    "C:\\Program Files\\Git\\git-bash.exe",
    "C:\\Program Files\\Git\\bin\\bash.exe",
    "C:\\Program Files (x86)\\Git\\git-bash.exe"
  )
  gitbash <- candidates[file.exists(candidates)][1]
  if (is.na(gitbash)) stop("git-bash.exe not found in standard locations.")

  dir     <- normalizePath(dir, winslash = "\\", mustWork = TRUE)
  gitbash <- normalizePath(gitbash, winslash = "\\", mustWork = TRUE)

  system2(
    "cmd",
    args = c(
      "/c", "start", "\"\"",
      shQuote(gitbash, type = "cmd"),
      paste0("--cd=", shQuote(dir, type = "cmd"))
    ),
    wait = FALSE, invisible = TRUE
  )
}



open_alacritty_here <- function() {

  dir <- tryCatch(getwd(), error = function(e) NULL)

  if (is.null(dir) || !dir.exists(dir)) {
    message("Could not determine working directory.")
    return(invisible(NULL))
  }

  dir <- normalizePath(dir, mustWork = TRUE)

  if (.Platform$OS.type == "windows") {
    system2("alacritty.exe", c("--working-directory", shQuote(dir)), wait = FALSE)
  ## } else if (Sys.info()[["sysname"]] == "Darwin") {
} else if (Sys.info()[["sysname"]] == "Darwin") {
  system2("/Applications/Alacritty.app/Contents/MacOS/alacritty",
          c("--working-directory", shQuote(dir)),
          wait = FALSE)
} else if (.Platform$OS.type == "unix") {
    system2("alacritty", c("--working-directory", shQuote(dir)), wait = FALSE)
  } else {
    message("Unsupported system type.")
  }

  message("Opened Alacritty in: ", dir)
}


copy_current_file_contents <- function() {

  ctx <- rstudioapi::getActiveDocumentContext()

  if (is.null(ctx$path) || ctx$path == "") {
    clipr::write_clip(paste(ctx$contents, collapse = "\n"))
  } else {
    text <- readLines(ctx$path, warn = FALSE)
    clipr::write_clip(paste(text, collapse = "\n"))
  }

  message("File contents copied to clipboard.")
}

copy_all_r_files_here <- function(max_files = 100) {
  dir <- getwd()

  files <- list.files(dir, pattern = "\\.[Rr]$", full.names = TRUE, recursive = TRUE)

  if (length(files) == 0) {
    message("No R files found in current working directory or subfolders.")
    return(invisible(NULL))
  }

  if (length(files) > max_files) {
    message(length(files), " R files found in this directory (more than the limit of ", max_files, ").")
    message("Aborting to prevent large clipboard copy. Consider filtering or increasing the limit via 'max_files' argument.")
    return(invisible(NULL))
  }

  content <- vapply(files, function(f) {
    tryCatch({
      header <- paste0("# ==== ", basename(f), " ====")
      body <- paste(readLines(f, warn = FALSE), collapse = "\n")
      paste(header, body, sep = "\n")
    }, error = function(e) paste0("# ==== ", basename(f), " ==== (Error reading file)"))
  }, character(1))

  combined <- paste(content, collapse = "\n\n")

  if (!clipr::clipr_available()) {
    stop("Clipboard not available. Try running inside RStudio or with system clipboard access.")
  }

  clipr::write_clip(combined)

  char_count <- nchar(combined)
  token_est <- ceiling(char_count / 4)

  rel_files <- gsub(paste0("^", normalizePath(dir, winslash = "/", mustWork = TRUE), "/?"), "",
                    normalizePath(files, winslash = "/", mustWork = TRUE))

  message(length(files), " R file(s) copied from: ", dir)
  message("Files copied:\n  - ", paste(rel_files, collapse = "\n  - "))
  message("Total characters: ", format(char_count, big.mark = ","),
          " | Approx. tokens: ", format(token_est, big.mark = ","))
}


###
copy_selected_r_files_here <- function() {
  dir <- getwd()
  files <- list.files(dir, pattern = "\\.[Rr]$", full.names = TRUE, recursive = TRUE)

  if (length(files) == 0) {
    message("No R files found in current working directory or subfolders.")
    return(invisible(NULL))
  }

  rel_files <- normalizePath(files, winslash = "/", mustWork = TRUE)
  rel_files <- gsub(paste0("^", normalizePath(dir, winslash = "/", mustWork = TRUE), "/?"), "", rel_files)

  # Console-based file selection
  cat("Available R files:\n")
  for (i in seq_along(rel_files)) {
    cat(sprintf("%3d: %s\n", i, rel_files[i]))
  }

  input <- readline("Enter indices (comma separated, or 'all' for all files): ")

  if (tolower(trimws(input)) == "all") {
    selected <- files
  } else {
    idx <- as.integer(unlist(strsplit(gsub("\\s", "", input), ",")))
    valid_idx <- idx[!is.na(idx) & idx > 0 & idx <= length(files)]

    if (length(valid_idx) == 0) {
      message("No valid indices selected.")
      return(invisible(NULL))
    }

    selected <- files[valid_idx]
  }

  if (length(selected) == 0) {
    message("No files selected.")
    return(invisible(NULL))
  }

  # Read and combine file contents
  content <- vapply(selected, function(f) {
    tryCatch({
      header <- paste0("# ==== ", basename(f), " ====")
      body <- paste(readLines(f, warn = FALSE), collapse = "\n")
      paste(header, body, sep = "\n")
    }, error = function(e) {
      paste0("# ==== ", basename(f), " ==== (Error reading file)")
    })
  }, character(1))

  # Copy to clipboard
  if (!clipr::clipr_available()) {
    stop("Clipboard not available. Try running inside RStudio or enable system clipboard access.")
  }

  combined <- paste(content, collapse = "\n\n")
  clipr::write_clip(combined)

  # Display summary
  char_count <- nchar(combined)
  token_est <- ceiling(char_count / 4)

  selected_rel <- gsub(paste0("^", normalizePath(dir, winslash = "/", mustWork = TRUE), "/?"), "",
                       normalizePath(selected, winslash = "/", mustWork = TRUE))

  message(length(selected), " file(s) copied to clipboard from: ", dir)
  message("Files copied:\n  - ", paste(selected_rel, collapse = "\n  - "))
  message("Total characters: ", format(char_count, big.mark = ","),
          " | Approx. tokens: ", format(token_est, big.mark = ","))
}


#

# File: R/session_directory_memory.R

.session_dirs <- new.env(parent = emptyenv())

remember_current_directory <- function() {

  ctx <- tryCatch(rstudioapi::getActiveDocumentContext(), error = function(e) NULL)
  dir <- if (!is.null(ctx) && nzchar(ctx$path)) dirname(ctx$path) else getwd()

  existing <- unlist(as.list(.session_dirs), use.names = FALSE)
  if (!(dir %in% existing)) {
    id <- paste0("dir", length(existing) + 1)
    assign(id, dir, envir = .session_dirs)
    message("Remembered directory: ", dir)
  } else {
    message("Directory already remembered: ", dir)
  }
}

return_to_remembered_directory <- function() {
  dirs <- as.list(.session_dirs)

  if (length(dirs) == 0) {
    message("No directories remembered in this session.")
    return(invisible(NULL))
  }

  choices <- unname(unlist(dirs))

  # Console-based directory selection
  cat("Available remembered directories:\n")
  for (i in seq_along(choices)) {
    cat(sprintf("%3d: %s\n", i, choices[i]))
  }

  input <- readline("Enter the number of the directory: ")
  idx <- as.integer(trimws(input))

  if (is.na(idx) || idx < 1 || idx > length(choices)) {
    message("Invalid selection. No directory changed.")
    return(invisible(NULL))
  }

  selected <- choices[idx]

  if (length(selected) == 0 || selected == "") {
    message("No selection made.")
    return(invisible(NULL))
  }

  # Change working directory
  setwd(selected)

  # Try to navigate Files pane in RStudio if available
  tryCatch({
    if (rstudioapi::isAvailable()) {
      rstudioapi::filesPaneNavigate(selected)
    }
  }, error = function(e) {
    message("Changed working directory, but could not open Files pane.")
  })

  message("Working directory changed to: ", selected)
}
