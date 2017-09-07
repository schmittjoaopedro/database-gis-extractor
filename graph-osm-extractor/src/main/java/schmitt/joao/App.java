package schmitt.joao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.graphhopper.GraphHopper;
import com.graphhopper.routing.util.AllEdgesIterator;
import com.graphhopper.routing.util.DataFlagEncoder;
import com.graphhopper.routing.util.EncodingManager;
import com.graphhopper.storage.GraphHopperStorage;
import com.graphhopper.util.EdgeIterator;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class App {

    private static final String file = "/home/joao/Downloads/map.osm.xml";

    public static void main(String[] args) throws Exception {

        GraphHopperFacade facade = new GraphHopperFacade(file);
        GraphHopper hopper = facade;
        DataFlagEncoder dataFlagEncoder = (new DataFlagEncoder()).setStoreHeight(true).setStoreWeight(true).setStoreWidth(true);
        hopper.setEncodingManager(new EncodingManager(Arrays.asList(dataFlagEncoder), 8));
        hopper.importOrLoad();
        GraphHopperStorage graph = hopper.getGraphHopperStorage();
        DataFlagEncoder encoder = (DataFlagEncoder) hopper.getEncodingManager().getEncoder("generic");

        List<Node> nodes = getNodeMatrix(graph, encoder);

        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        FileWriter file = new FileWriter(System.getProperty("user.dir") + "/map-viewer/joinville.json");
        String json = gson.toJson(nodes);
        file.write(json);
        file.flush();
        file.close();
    }

    public static List<Node> getNodeMatrix(GraphHopperStorage graph, DataFlagEncoder encoder) {
        List<Node> nodes = new ArrayList<Node>();
        NodeManager nodeManager = new NodeManager();
        AllEdgesIterator edges = graph.getAllEdges();
        do {
            Integer baseId = edges.getBaseNode();
            Integer adjId = edges.getAdjNode();
            Node baseNode = nodeManager.getNodes().get(baseId);
            if (baseNode == null) {
                baseNode = new Node();
                baseNode.setLat(graph.getNodeAccess().getLat(baseId));
                baseNode.setLng(graph.getNodeAccess().getLon(baseId));
                nodeManager.getNodes().put(baseId, baseNode);
            }
            if (!baseNode.getNodes().containsKey(adjId)) {
                Node adjNode = new Node();
                adjNode.setLat(graph.getNodeAccess().getLat(adjId));
                adjNode.setLng(graph.getNodeAccess().getLon(adjId));
                adjNode.setDistance(edges.getDistance());
                baseNode.getNodes().put(adjId, adjNode);
            }
            if (!nodeManager.getNodes().containsKey(adjId)) {
                Node adjNode = new Node();
                adjNode.setLat(graph.getNodeAccess().getLat(adjId));
                adjNode.setLng(graph.getNodeAccess().getLon(adjId));
                nodeManager.getNodes().put(adjId, adjNode);
            }
        } while (edges.next());
        nodes.addAll(nodeManager.getNodes().values());
        return nodes;
    }

    public static void printAllEdgesInformation(GraphHopperStorage graph, DataFlagEncoder encoder) {
        AllEdgesIterator edges = graph.getAllEdges();
        do {
            String info = "\n";
            info += edges.getName();
            info += "\n\t" + encoder.getSurfaceAsString(edges);
            info += "\n\t" + encoder.getTransportModeAsString(edges);
            info += "\n\t" + encoder.getHighwayAsString(edges);
            info += "\n\t" + encoder.getHeight(edges);
            info += "\n\t" + encoder.getWeight(edges);
            info += "\n\t" + encoder.getWidth(edges);
            info += "\n\tBase Lat/Lng: (" + graph.getNodeAccess().getLat(edges.getBaseNode()) + "," + graph.getNodeAccess().getLon(edges.getBaseNode()) + ")";
            info += "\n\tAdj Lat/Lng: (" + graph.getNodeAccess().getLat(edges.getAdjNode()) + "," + graph.getNodeAccess().getLon(edges.getAdjNode()) + ")";
            info += "\n\tDist: " + edges.getDistance();
            System.out.println(info);
        } while (edges.next());
    }
}
