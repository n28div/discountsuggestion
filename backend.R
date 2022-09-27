#' @filter cors
cors <- function(req, res) {
  
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }
  
}

#* Retrieve the list of clients
#* @serializer unboxedJSON
#* @get /clients
function(){
  customers <- distinct_at(data, vars(Customer.ID, Customer.Name, City))
  names(customers) <- c("id", "name", "city")
  return(customers)
}

#* Perform search by using both document and client indexing
#* @serializer unboxedJSON
#* @param text Description to query
#* @param client Client to query for similarity
#* @param num Number of results to retrieve
#* @get /query
function(text, client, num = 5){
  clientIdx <- which(data$Customer.ID == client)[[1]]
  client <- data$Customer.ID[clientIdx]
  
  clients.sim <- apply(tcm.lsa.c, 1, cosine, as.vector(tcm.lsa.c[client,]))
  # exclude self
  clients.sim <- clients.sim[order(clients.sim, decreasing = T)][-1]
  clients.sim.df <- data.frame(clients.sim, client=names(similarClients))
  
  # make query and turn it into ls
  query <- tdm.makequery(text)
  query.ls <- as.vector(diag(tdm.lsa$sk^-1) %*% t(tdm.lsa$tk) %*% query)
  
  # compute similarity between query and documents
  docs.sim <- apply(tdm.lsa$dk, 1, cosine, query.ls)
  docs.sim.df <- data.frame(docs.sim, 
                            client=data$Customer.ID, 
                            doc.index=names(docs.sim), 
                            description=data$Product.Name,
                            discount=data$Discount)
  
  df <- merge(clients.sim.df, docs.sim.df, by="client")
  topX <- top(num, df$docs.sim, df$clients.sim)
  
  res <- df[topX,]
  names(res) <- c("clientId", "clientSim", "docSim", "docIndex", "description", "discount")
  return(res)
}

