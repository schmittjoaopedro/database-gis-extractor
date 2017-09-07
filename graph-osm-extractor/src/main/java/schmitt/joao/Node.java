package schmitt.joao;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class Node implements Serializable {

    private Map<Integer, Node> nodes;

    private Double distance;

    private Double lat;

    private Double lng;

    public Node() {
        super();
    }

    public Map<Integer, Node> getNodes() {
        if(this.nodes == null) this.nodes = new HashMap<Integer, Node>();
        return nodes;
    }

    public void setNodes(Map<Integer, Node> nodes) {
        this.nodes = nodes;
    }

    public Double getDistance() {
        return distance;
    }

    public void setDistance(Double distance) {
        this.distance = distance;
    }

    public Double getLat() {
        return lat;
    }

    public void setLat(Double lat) {
        this.lat = lat;
    }

    public Double getLng() {
        return lng;
    }

    public void setLng(Double lng) {
        this.lng = lng;
    }
}
