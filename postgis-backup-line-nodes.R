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

# Retrieving geom lines from Postgreesetwd("/home/joao/projects/master-degree/database-gis-extractor")
require(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "udesc", password = "udesc", dbname = "udesc")
if(dbExistsTable(con, "linhas")) {
    ds_linhas <- dbGetQuery(con, "select id, source, target, ST_AsText(geom) from linhas_linhas_noded")
}
dbDisconnect(con)
dbUnloadDriver(drv)

# Make backup
library(ggmap)
source("convert_line_string_to_data_frame.R")
options(digits = 15)

route <- data.frame(id = numeric(), name = numeric(), seq = numeric(), lat = numeric(), lng = numeric())
for(route_index in 1:dim(ds_linhas)[1]) {
    route <- rbind(route, convertLineStringToDataFrame(ds_linhas$id[route_index], ds_linhas$id[route_index], ds_linhas$st_astext[route_index]))
}
write.csv(x = route, file = "line_noded.csv", row.names = FALSE)