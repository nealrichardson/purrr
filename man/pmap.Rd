% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pmap.R
\name{pmap}
\alias{pmap}
\alias{pmap_lgl}
\alias{pmap_int}
\alias{pmap_dbl}
\alias{pmap_chr}
\alias{pwalk}
\title{Map over multiple input simultaneously (in "parallel")}
\usage{
pmap(.l, .f, ..., .progress = NULL)

pmap_lgl(.l, .f, ..., .progress = NULL)

pmap_int(.l, .f, ..., .progress = NULL)

pmap_dbl(.l, .f, ..., .progress = NULL)

pmap_chr(.l, .f, ..., .progress = NULL)

pwalk(.l, .f, ...)
}
\arguments{
\item{.l}{A list of vectors. The length of \code{.l} determines the number of
arguments that \code{.f} will be called with. Arguments will be supply by
position if unnamed, and by name if named.

Vectors of length 1 will be recycled to any length; all other elements
must be have the same length.

A data frame is an important special case of \code{.l}. It will cause \code{.f}
to be called once for each row.}

\item{.f}{A function, specified in one of the following ways:
\itemize{
\item A named function.
\item An anonymous function, e.g. \verb{\\(x, y, z) x + y / z} or
\code{function(x, y, z) x + y / z}
\item A formula, e.g. \code{~ ..1 + ..2 / ..3}. This syntax is not recommended as
you can only refer to arguments by position.
}}

\item{...}{Additional arguments passed on to the mapped function.

Note that the arguments that differ in each call come before \code{.f},
and the arguments that are the same come after \code{.f}.}

\item{.progress}{Whether to show a progress bar. See \link{progress_bars}
for details.}
}
\value{
The output length is determined by the length of the input.
The output type is determined by the suffix:
\itemize{
\item No suffix: a list.
\item \verb{_lgl}, \verb{_int}, \verb{_dbl}, \verb{_chr} return a logical, integer, double,
or character vector respectively. It will be named if the input was named.
\item \code{walk()} returns the input \code{.x} (invisibly). This makes it easy to
use in a pipe.
}
}
\description{
These functions are variants of \code{\link[=map]{map()}} that iterate over multiple arguments
simultaneously. They are parallel in the sense that each input is processed
in parallel with the others, not in the sense of multicore computing, i.e.
they share the same notion of "parallel" as \code{\link[base:Extremes]{base::pmax()}} and \code{\link[base:Extremes]{base::pmin()}}.
}
\examples{
x <- list(1, 1, 1)
y <- list(10, 20, 30)
z <- list(100, 200, 300)
pmap(list(x, y, z), sum)

# Matching arguments by position
pmap(list(x, y, z), function(first, second, third) (first + third) * second)

# Matching arguments by name
l <- list(a = x, b = y, c = z)
pmap(l, function(c, b, a) (a + c) * b)

# Vectorizing a function over multiple arguments
df <- data.frame(
  x = c("apple", "banana", "cherry"),
  pattern = c("p", "n", "h"),
  replacement = c("P", "N", "H"),
  stringsAsFactors = FALSE
  )
pmap(df, gsub)
pmap_chr(df, gsub)

# Use `...` to absorb unused components of input list .l
df <- data.frame(
  x = 1:3,
  y = 10:12,
  z = letters[1:3]
)
plus <- function(x, y) x + y
\dontrun{
# this won't work
pmap(df, plus)
}
# but this will
plus2 <- function(x, y, ...) x + y
pmap_dbl(df, plus2)

# The "p" for "parallel" in pmap() is the same as in base::pmin()
# and base::pmax()
df <- data.frame(
  x = c(1, 2, 5),
  y = c(5, 4, 8)
)
# all produce the same result
pmin(df$x, df$y)
map2_dbl(df$x, df$y, min)
pmap_dbl(df, min)
}
\seealso{
Other map variants: 
\code{\link{imap}()},
\code{\link{lmap}()},
\code{\link{map2}()},
\code{\link{map_if}()},
\code{\link{map}()},
\code{\link{modify}()}
}
\concept{map variants}
