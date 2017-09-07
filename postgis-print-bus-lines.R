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
library(ggmap)
source("convert_line_string_to_data_frame.R")
options(digits = 10)
route_index = 400
route <- convertLineStringToDataFrame(ds_linhas$id[route_index], ds_linhas$name[route_index], ds_linhas$st_astext[route_index])
map_jille = get_map(location = c(lon = mean(route$lng), lat = mean(route$lat)), zoom = 13, maptype = 'roadmap')
map_jille_graph = ggmap(map_jille)
map_jille_graph <- map_jille_graph + geom_point(data = route, aes(x = lng, y = lat), size = 1)
map_jille_graph