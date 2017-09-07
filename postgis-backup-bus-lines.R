# Installig dependencies
#
# Postgis dependencies
#
# > install.packages("devtools")
# > devtools::install_github("RcppCore/Rcpp")
# > devtools::install_github("rstats-db/DBI")
# > sudo apt-get install libpq-dev
# > install.packages("RPostgreSQL")
#
# Google Maps dependencies
#
# > install.packages("ggmap")

# Retrieving lines from Postgree
setwd("/home/joao/projects/master-degree/database-gis-extractor")
require(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "udesc", password = "udesc", dbname = "udesc")
if(dbExistsTable(con, "linhas")) {
    ds_linhas <- dbGetQuery(con, "select id, name, ST_AsText(geom) from linhas")
}
dbDisconnect(con)
dbUnloadDriver(drv)

# Plot a route
source("convert_line_string_to_data_frame.R")
options(digits = 10)
for(route_index in 1:dim(ds_linhas)[1]) {
    route_id <- ds_linhas$id[route_index]
    route_name <- gsub("/", "to", ds_linhas$name[route_index])
    route <- convertLineStringToDataFrame(route_id, route_name, ds_linhas$st_astext[route_index])
    write.csv(x = route, file = paste("bus_lines/", route_id, " - ", route_name, ".csv", sep = ""), row.names = FALSE)    
}