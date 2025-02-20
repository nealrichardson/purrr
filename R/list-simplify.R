#' Simplify a list to an atomic or S3 vector
#'
#' Simplification maintains a one-to-one correspondence between the input
#' and output, implying that each element of `x` must contain a vector of
#' length 1. If you don't want to maintain this correspondence, then you
#' probably want either [list_c()] or [list_flatten()].
#'
#' @param x A list.
#' @param strict What should happen if simplification fails? If `TRUE`,
#'   it will error. If `FALSE` and `ptype` is not supplied, it will return `x`
#'   unchanged.
#' @param ptype An optional prototype to ensure that the output type is always
#'   the same.
#' @returns A vector the same length as `x`.
#' @export
#' @examples
#' list_simplify(list(1, 2, 3))
#'
#' try(list_simplify(list(1, 2, "x")))
#' try(list_simplify(list(1, 2, 1:3)))
list_simplify <- function(x, strict = TRUE, ptype = NULL) {
  if (!is_bool(strict)) {
    cli::cli_abort(
      "{.arg strict} must be `TRUE` or `FALSE`, not {.obj_type_friendly {strict}}.",
      arg = "strict"
    )
  }

  simplify_impl(x, strict = strict, ptype = ptype)
}

# Wrapper used by purrr functions that do automatic simplification
list_simplify_internal <- function(x,
                                   simplify = NA,
                                   ptype = NULL,
                                   error_call = caller_env()) {
  if (length(simplify) > 1 || !is.logical(simplify)) {
    cli::cli_abort(
      "{.arg simplify} must be `TRUE`, `FALSE`, or `NA`.",
      arg = "simplify",
      call = error_call
    )
  }
  if (!is.null(ptype) && isFALSE(simplify)) {
    cli::cli_abort(
      "Can't specify {.arg ptype} when `simplify = FALSE`.",
      arg = "ptype",
      call = error_call
    )
  }

  if (isFALSE(simplify)) {
    return(x)
  }

  simplify_impl(
    x,
    strict = !is.na(simplify),
    ptype = ptype,
    error_call = error_call
  )
}

simplify_impl <- function(x,
                          strict = TRUE,
                          ptype = NULL,
                          error_call = caller_env()) {
  vec_check_list(x, call = error_call)

  can_simplify <- every(x, vec_is, size = 1)

  if (can_simplify) {
    tryCatch(
      # TODO: use `error_call` when available
      list_unchop(x, ptype = ptype),
      vctrs_error_incompatible_type = function(err) {
        if (strict || !is.null(ptype)) {
          cnd_signal(err)
        } else {
          x
        }
      }
    )
  } else {
    if (strict) {
      cli::cli_abort(
        "All elements must be length-1 vectors.",
        call = error_call
      )
    } else {
      x
    }
  }
}
