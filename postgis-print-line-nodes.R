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

# Plot geom line in a route
# Plot geom in a route
library(ggmap)
source("convert_line_string_to_data_frame.R")
options(digits = 15)

route_index = 1
route <- convertLineStringToDataFrame(ds_linhas$id[route_index], ds_linhas$id[route_index], ds_linhas$st_astext[route_index])
route <- merge(route, ds_linhas[,c("id","source","target")], by = "id")

route_before <- ds_linhas[ds_linhas$source == route$target,]
route_before <- convertLineStringToDataFrame(route_before$id, route_before$id, route_before$st_astext)
route_before <- merge(route_before, ds_linhas[,c("id","source","target")], by = "id")

route_after <- ds_linhas[ds_linhas$target == route$source,]
route_after <- convertLineStringToDataFrame(route_after$id, route_after$id, route_after$st_astext)
route_after <- merge(route_after, ds_linhas[,c("id","source","target")], by = "id")

route <- rbind(route, route_before)
route <- rbind(route, route_after)
map_jille = get_map(location = c(lon = mean(route$lng), lat = mean(route$lat)), zoom = 18, maptype = 'roadmap')
map_jille_graph = ggmap(map_jille)
map_jille_graph <- map_jille_graph + geom_point(data = route, aes(x = lng, y = lat), size = 1)
map_jille_graph

