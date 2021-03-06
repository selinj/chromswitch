% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary_matrix.R
\name{summarizePeaks}
\alias{summarizePeaks}
\title{summarizePeaks}
\usage{
summarizePeaks(localpeaks, mark, cols, fraction = TRUE, n = FALSE)
}
\arguments{
\item{localpeaks}{LocalPeaks object}

\item{mark}{String specifying the name of the mark for which the LocalPeaks
object is given}

\item{cols}{Character vector of column names on which to compute summary
statistics}

\item{fraction}{Loogical: compute the fraction of the region overlapped by
peaks?}

\item{n}{Logical: compute the number of peaks in the region?}
}
\value{
A matrix where rows are samples and columns are features
}
\description{
Given peaks for a set of samples in a query region, construct a sample-by-
feature matrix where each row is a vector of summary statistics computed from
peaks in the region.
}
\examples{
samples <- c("E068", "E071", "E074", "E101", "E102", "E110")
bedfiles <- system.file("extdata", paste0(samples, ".H3K4me3.bed"),
package = "chromswitch")

metadata <- data.frame(Sample = samples,
    H3K4me3 = bedfiles,
    stringsAsFactors = FALSE)

lpk <- retrievePeaks(H3K4me3,
    metadata = metadata,
    region = GRanges(seqnames = "chr19",
    ranges = IRanges(start = 54924104, end = 54929104)))

summarizePeaks(lpk, mark = "H3K4me3", cols = c("qValue", "signalValue"))

}
