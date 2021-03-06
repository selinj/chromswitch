% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coordinates.R
\name{GRangesToCoord}
\alias{GRangesToCoord}
\title{GRangesToCoord}
\usage{
GRangesToCoord(gr)
}
\arguments{
\item{gr}{GRanges object specifying region to convert to a string}
}
\value{
String
}
\description{
Convert a GRanges object for one region to a genome browser-friendly string
}
\examples{
gr <- GRanges(seqnames = "chr1",
              ranges = IRanges(start = 1000, end = 2000))

GRangesToCoord(gr)

}
