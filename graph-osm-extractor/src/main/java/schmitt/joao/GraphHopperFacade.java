package schmitt.joao;

import com.graphhopper.reader.DataReader;
import com.graphhopper.reader.osm.GraphHopperOSM;
import com.graphhopper.reader.osm.OSMReader;
import com.graphhopper.routing.util.*;
import com.graphhopper.storage.GraphExtension;
import com.graphhopper.storage.GraphHopperStorage;
import com.graphhopper.storage.RAMDirectory;
import com.graphhopper.storage.TurnCostExtension;
import com.graphhopper.util.EdgeExplorer;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;

class GraphHopperFacade extends GraphHopperOSM {

    private CarFlagEncoder carEncoder;
    private BikeFlagEncoder bikeEncoder;
    private FlagEncoder footEncoder;
    private EdgeExplorer carOutExplorer;
    private EdgeExplorer carAllExplorer;
    private final String dir = "/home/joao/Downloads";

    public GraphHopperFacade(String osmFile) {
        this(osmFile, false);
    }

    public GraphHopperFacade(String osmFile, boolean turnCosts) {
        setStoreOnFlush(false);
        setOSMFile(osmFile);
        setGraphHopperLocation(dir);
        setEncodingManager(new EncodingManager("car,foot"));
        setCHEnabled(false);

        if (turnCosts) {
            carEncoder = new CarFlagEncoder(5, 5, 1);
            bikeEncoder = new BikeFlagEncoder(4, 2, 1);
        } else {
            carEncoder = new CarFlagEncoder();
            bikeEncoder = new BikeFlagEncoder();
        }

        footEncoder = new FootFlagEncoder();

        setEncodingManager(new EncodingManager(footEncoder, carEncoder, bikeEncoder));
    }

    @Override
    protected DataReader createReader(GraphHopperStorage tmpGraph) {
        return initDataReader(new OSMReader(tmpGraph));
    }

    @Override
    protected DataReader importData() throws IOException {
        getEncodingManager().setPreferredLanguage(getPreferredLanguage());
        GraphHopperStorage tmpGraph = newGraph(dir, getEncodingManager(), hasElevation(),
                getEncodingManager().needsTurnCostsSupport());
        setGraphHopperStorage(tmpGraph);

        DataReader osmReader = createReader(tmpGraph);
        try {
            osmReader.setFile(new File(getOSMFile()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        osmReader.readGraph();
        carOutExplorer = getGraphHopperStorage().createEdgeExplorer(new DefaultEdgeFilter(carEncoder, false, true));
        carAllExplorer = getGraphHopperStorage().createEdgeExplorer(new DefaultEdgeFilter(carEncoder, true, true));
        return osmReader;
    }

    public GraphHopperStorage newGraph(String directory, EncodingManager encodingManager, boolean is3D, boolean turnRestrictionsImport) {
        return new GraphHopperStorage(new RAMDirectory(directory, false), encodingManager, is3D,
                turnRestrictionsImport ? new TurnCostExtension() : new GraphExtension.NoOpExtension());
    }

    public EdgeExplorer getCarOutExplorer() {
        return carOutExplorer;
    }

    public EdgeExplorer getCarAllExplorer() {
        return carAllExplorer;
    }

}