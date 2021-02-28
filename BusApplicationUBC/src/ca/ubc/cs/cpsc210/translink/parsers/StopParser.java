package ca.ubc.cs.cpsc210.translink.parsers;

import ca.ubc.cs.cpsc210.translink.model.Route;
import ca.ubc.cs.cpsc210.translink.model.RouteManager;
import ca.ubc.cs.cpsc210.translink.model.Stop;
import ca.ubc.cs.cpsc210.translink.model.StopManager;
import ca.ubc.cs.cpsc210.translink.parsers.exception.StopDataMissingException;
import ca.ubc.cs.cpsc210.translink.providers.DataProvider;
import ca.ubc.cs.cpsc210.translink.providers.FileDataProvider;
import ca.ubc.cs.cpsc210.translink.util.LatLon;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * A parser for the data returned by Translink stops query
 */
public class StopParser {

    private String filename;

    public StopParser(String filename) {
        this.filename = filename;
    }
    /**
     * Parse stop data from the file and add all stops to stop manager.
     *
     */
    public void parse() throws IOException, StopDataMissingException, JSONException {
        DataProvider dataProvider = new FileDataProvider(filename);

        parseStops(dataProvider.dataSourceToString());
    }
    /**
     * Parse stop information from JSON response produced by Translink.
     * Stores all stops and routes found in the StopManager and RouteManager.
     *
     * @param  jsonResponse    string encoding JSON data to be parsed
     * @throws JSONException   when JSON data does not have expected format
     * @throws StopDataMissingException when
     * <ul>
     *  <li> JSON data is not an array </li>
     *  <li> JSON data is missing Name, StopNo, Routes or location (Latitude or Longitude) elements for any stop</li>
     * </ul>
     */

    public void parseStops(String jsonResponse)
            throws JSONException, StopDataMissingException {
        // TODO: Task 4: Implement this method
        JSONArray stops = new JSONArray(jsonResponse);

        for(int i = 0; i<stops.length(); i++){
            JSONObject stop = stops.getJSONObject(i);
            parseStop(stop);
        }

    }

    private void parseStop(JSONObject stop) throws JSONException, StopDataMissingException{
        String name;
        int stopNo;
        Double lat;
        Double lon;
        String[] routeField;
        try {
            name = stop.getString("Name");
            stopNo = stop.getInt("StopNo");
            lat = stop.getDouble("Latitude");
            lon = stop.getDouble("Longitude");
            routeField = stop.getString("Routes").split(",");
        } catch (JSONException e){
            throw new StopDataMissingException();
        }


        Stop s = StopManager.getInstance().getStopWithId(stopNo,name,new LatLon(lat,lon));
        for (String a: routeField) {
            if (!a.equals("")) {
                Route r = RouteManager.getInstance().getRouteWithNumber(a.trim());
                s.addRoute(r);

            }
        }
    }
}
