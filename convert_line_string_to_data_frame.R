convertLineStringToDataFrame <- function (key, desc, str) {
    str <- gsub("LINESTRING\\(|\\)", "", str)
    str_split_positions <- strsplit(str, ",")
    df_coordinates <- data.frame(id = numeric(), name = character(), seq = numeric(), lat = numeric(), lng = numeric())
    for(pos in 1:length(str_split_positions[[1]])) {
        str_split_coord <- strsplit(str_split_positions[[1]][pos], "\\s")
        for(coord in 1:length(str_split_coord)) {
            df_coordinates <- rbind(df_coordinates, data.frame(
                id = key,
                name = desc,
                seq = pos, 
                lat = str_split_coord[[coord]][2], 
                lng = str_split_coord[[coord]][1]))
        }
    }
    df_coordinates$lat <- as.numeric(as.character(df_coordinates$lat))
    df_coordinates$lng <- as.numeric(as.character(df_coordinates$lng))
    return(df_coordinates)
}