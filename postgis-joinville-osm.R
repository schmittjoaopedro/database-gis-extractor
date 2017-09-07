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
    ds_linhas <- dbGetQuery(con, "select id, name, ST_AsText(geom), highway,  osm_id, oneway, surface, target, source from osmjoinville;")
}
dbDisconnect(con)
dbUnloadDriver(drv)

# Plot geom line in a route
# Plot geom in a route
library(ggmap)
source("convert_line_string_to_data_frame.R")
options(digits = 15)

route_ds <- data.frame(id = numeric(), name = character(), seq = numeric(), lat = numeric(), lng = numeric(), source = numeric(), target = numeric(), highway = character(), osm_id = numeric(), oneway = character(), surface = character())
for(route_index in 1:dim(ds_linhas)[1]) {
    route <- ds_linhas[route_index,]
    route <- convertMultiLineStringToDataFrame(route$id, route$name, route$st_astext)
    route <- merge(route, ds_linhas[,c("id","source","target","highway","osm_id","oneway","surface")], by = "id")
    route_ds <- rbind(route_ds, route)
}

map_jille = get_map(location = c(lon = mean(route_ds$lng), lat = mean(route_ds$lat)), zoom = 9, maptype = 'roadmap')
map_jille_graph = ggmap(map_jille)
map_jille_graph <- map_jille_graph + geom_point(data = route_ds, aes(x = lng, y = lat), size = 1)
map_jille_graph

write.csv(x = route_ds, file = "jille_osm.csv", row.names = FALSE)

