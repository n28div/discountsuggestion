install.packages("install.load")
library(install.load)
install_load("lsa")
install_load("tm")
install_load("scales")
install_load("readxl")
install_load("dplyr")
install_load("plumber")

preprocessDescriptions <- function(descriptions) {
  corpus <- Corpus(VectorSource(descriptions))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  corpus <- tm_map(corpus, removeNumbers)
  
  # remove consecutive spaces
  consecutiveSpacesRe <- "\\s+"
  corpus <- tm_map(corpus, function(d) { gsub(consecutiveSpacesRe, " ", d) })
  
  # trim spaces
  trimRe <- "^\\s+|\\s+$"
  corpus <- tm_map(corpus, function(d) { gsub(trimRe, "", d) })
  
  return(corpus)
}

top <- function(n, ...) order(..., decreasing = T)[1:n]

data <- data.frame(read_excel("./GlobalSuperstore.xls"))
corpus <- preprocessDescriptions(data$Product.Name)

# Document TM
# ------------------------------
tdm <- TermDocumentMatrix(corpus)
maxSparsity <- 1 - 2/tdm$nrow
tdm <- removeSparseTerms(tdm, maxSparsity)

# TF-IDF application
tdm.terms <- rownames(tdm)
tdm.m <- as.matrix(tdm)
tdm.m <- lw_logtf(tdm.m) * ( 1 - entropy(tdm.m))

tdm.makequery <- function(text) {
  q <- query(text, tdm.terms)
  return(as.vector(lw_logtf(q) * ( 1-entropy(tdm.m))))
}


# LSA computation
tdm.lsa <- lsa(tdm.m)

# Client TM
# -------------------------------
clientDescriptions <- sapply(unique(data$Customer.ID ), function(c) {
  paste(data[data$Customer.ID == c,]$Product.Name, collapse = " ")
})

clientCorpus <- preprocessDescriptions(clientDescriptions)

tcm <- TermDocumentMatrix(clientCorpus)
maxSparsity <- 1 - 2/tcm$nrow
tcm <- removeSparseTerms(tcm, maxSparsity)

tcm.terms <- rownames(tcm)
tcm.m <- as.matrix(tcm)
tcm.m <- lw_logtf(tcm.m) * ( 1 - entropy(tcm.m))

tcm.lsa <- lsa(tcm.m)
tcm.lsa.t <- tcm.lsa$tk %*% diag( tcm.lsa$sk )
tcm.lsa.t.norm <- apply(tcm.lsa.t, 1, norm, type = "2")
tcm.lsa.t.normalized <- tcm.lsa.t / tcm.lsa.t.norm
tcm.lsa.c <- tcm.lsa$dk %*% diag( tcm.lsa$sk )
tcm.lsa.c.norm <- apply(tcm.lsa.c, 1, norm, type = "2")
tcm.lsa.c.normalized <- tcm.lsa.c / tcm.lsa.c.norm

# Routing API
r <- plumb("backend.R")
r$run(port = 5555, docs = F)
