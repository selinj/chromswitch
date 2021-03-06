# ---------------------------------------------------------------------------- #
#
# Functions which implement external cluster validation metrics
#
# ---------------------------------------------------------------------------- #


# contingencyTable
#
# For each assigned cluster, stores the number of samples which belong
# to each known class. Used for evaluating the clustering solution. This
# function exists to create the contingencyTable from the metadata, to
# ensure that the clusters & conditions for the classes are associated
# correctly based on sample IDs.
#
# @param clusters A vector where values are the cluster assignments for each
# sample
# @param metadata Data frame with at least two columns: "Sample" storing
# sample IDs and "Condition" storing biological conditions of each samples
#
# @return table
contingencyTable <- function(clusters, metadata) {

    # For one cluster, how many samples in each class?
    df <- dplyr::inner_join(data.frame(Sample = as.character(names(clusters)),
                                        Cluster = clusters,
                                        stringsAsFactors = FALSE),
                            metadata[, c("Sample", "Condition")],
                            by = "Sample")

    contingency <- table(df$Condition, df$Cluster)
    return(contingency)

}


#' purity
#'
#' Computes the purity of a partition as defined in
#' https://www.ncbi.nlm.nih.gov/pubmed/17483501
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' purity(contingency = ct)
#'
#' @export
#' @return Numeric
purity <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    maxes  <- matrixStats::colMaxs(contingency)
    purity <- sum(maxes) / sum(contingency)

    return(purity)

}


#' classEntropy
#'
#' Computes the entropy of a set of classes, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' classEntropy(contingency = ct)
#'
#' @return Numeric
#' @export
classEntropy <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    n_c <- rowSums(contingency)
    n   <- sum(contingency)
    H   <- - sum( n_c/n * log(n_c/n) )

    return(H)

}


#' clusterEntropy
#'
#' Computes the entropy of a set of clusters, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' clusterEntropy(contingency = ct)
#'
#' @export
#' @return Numeric
clusterEntropy <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    n_k <- colSums(contingency)
    n   <- sum(contingency)
    H   <- - sum( n_k/n * log(n_k/n) )

    return(H)

}


#' classEntropyGivenClusters
#'
#' Computes the conditional entropy of a set of classes, given the
#' cluster assignments, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' conditionalClassEntropy(contingency = ct)
#'
#' @export
#' @return Numeric
conditionalClassEntropy <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    inner <- apply(contingency, 1, function(c_i) {
        k_i <- c_i/sum(contingency) * log( c_i/colSums(contingency) )
        k_i[is.nan(k_i)] <- 0
        return(k_i)
    })

    H <- - sum(inner)

    return(H)

}


#' clusterEntropyGivenClasses
#'
#' Computes the conditional entropy of a set of clusters, given the
#' true classes, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' conditionalClusterEntropy(contingency = ct)
#'
#' @export
#' @return Numeric
conditionalClusterEntropy <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    inner <- apply(contingency, 2, function(k_i) {
        c_i <- k_i/sum(contingency) * log( k_i/rowSums(contingency) )
        c_i[is.nan(c_i)] <- 0
        return(c_i)
    })

    H <- - sum(inner)

    return(H)

}


#' homogeneity
#'
#' Computes the homogeneity of a set of clusters given ground-truth
#' classes, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' homogeneity(contingency = ct)
#'
#' @export
#' @return Numeric
homogeneity <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    H_C_K       <- conditionalClassEntropy(contingency)
    H_C         <- classEntropy(contingency)
    homogeneity <- ifelse(H_C == 0, 1, 1 -  H_C_K/H_C)

    return(homogeneity)

}


#' completeness
#'
#' Computes the completeness of a set of clusters given ground-truth
#' classes, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' completeness(contingency = ct)
#'
#' @export
#' @return Numeric
completeness <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    H_K_C        <- conditionalClusterEntropy(contingency)
    H_K          <- clusterEntropy(contingency)
    completeness <- ifelse(H_K == 0, 1, 1 - H_K_C/H_K)

    return(completeness)

}


#' vMeasure
#'
#' Computes the V measure of a set of clusters given ground-truth
#' classes, as defined in
#' https://aclweb.org/anthology/D/D07/D07-1043.pdf
#'
#' @param contingency Table, contingency table between clusters and
#' conditions as returned by the \code{table} function
#' @param c Vector of classes
#' @param k Vector of clusters
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' ct <- table(classes, clusters)
#' vMeasure(contingency = ct)
#'
#' @export
#' @return Numeric
vMeasure <- function(contingency, c, k) {

    if(missing(contingency)) contingency <- table(c, k)

    h <- homogeneity(contingency)
    c <- completeness(contingency)
    v <- ifelse(h + c == 0, 0, 2 * (h * c) / (h + c))

    return(v)

}


#' NMI
#'
#' Computes the Normalized Mutual Information betwen two partitions
#'
#' This code comes directly from the package `clue`:
#' \url{https://github.com/cran/clue/blob/098da43010f3803294b4e
#' 8403328ee5c0216abf7/R/agreement.R#L161}
#'
#' Hornik K (2017). _clue: Cluster ensembles_. R package version
#' 0.3-53, <URL: https://CRAN.R-project.org/package=clue>.
#'
#' Hornik K (2005). “A CLUE for CLUster Ensembles.” _Journal of
#' Statistical Software_, *14*(12). doi: 10.18637/jss.v014.i12 (URL:
#' http://doi.org/10.18637/jss.v014.i12).
#'
#' @param clusters A vector of cluster assignments
#' @param classes A vector giving the true classes of the objects
#'
#' @examples
#'
#' clusters <- c(0, 0, 2, 1, 1, 0, 1)
#' classes <- c("A", "A", "A", "B", "B", "A", "B")
#' NMI(clusters, classes)
#'
#' @export
#' @return Numeric
NMI <- function(clusters, classes) {

    x <- table(clusters, classes)
    x <- x / sum(x)

    m_x <- rowSums(x)
    m_y <- colSums(x)
    y <- outer(m_x, m_y)

    i <- which((x > 0) & (y > 0))
    out <- sum(x[i] * log(x[i] / y[i]))
    e_x <- sum(m_x * log(ifelse(m_x > 0, m_x, 1)))
    e_y <- sum(m_y * log(ifelse(m_y > 0, m_y, 1)))

    nmi <- out / sqrt(e_x * e_y)
    return(nmi)

}

