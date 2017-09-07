package schmitt.joao;

import java.util.HashMap;
import java.util.Map;

public class NodeManager {

    private Map<Integer, Node> nodes;

    public NodeManager() {
        super();
    }

    public Map<Integer, Node> getNodes() {
        if(this.nodes == null) this.nodes = new HashMap<Integer, Node>();
        return nodes;
    }

    public void setNodes(Map<Integer, Node> nodes) {
        this.nodes = nodes;
    }
}
