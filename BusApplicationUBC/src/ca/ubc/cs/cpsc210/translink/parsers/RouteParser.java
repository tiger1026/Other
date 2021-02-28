package ca.ubc.cs.cpsc210.translink.parsers;

import ca.ubc.cs.cpsc210.translink.model.Route;
import ca.ubc.cs.cpsc210.translink.model.RouteManager;
import ca.ubc.cs.cpsc210.translink.model.RoutePattern;
import ca.ubc.cs.cpsc210.translink.parsers.exception.RouteDataMissingException;
import ca.ubc.cs.cpsc210.translink.providers.DataProvider;
import ca.ubc.cs.cpsc210.translink.providers.FileDataProvider;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Parse route information in JSON format.
 */
public class RouteParser {
    private String filename;

    public RouteParser(String filename) {
        this.filename = filename;
    }
    /**
     * Parse route data from the file and add all route to the route manager.
     *
     */
    public void parse() throws IOException, RouteDataMissingException, JSONException {
        DataProvider dataProvider = new FileDataProvider(filename);

        parseRoutes(dataProvider.dataSourceToString());
    }
    /**
     * Parse route information from JSON response produced by Translink.
     * Stores all routes and route patterns found in the RouteManager.
     *
     * @param  jsonResponse    string encoding JSON data to be parsed
     * @throws JSONException   when JSON data does not have expected format
     * @throws RouteDataMissingException when
     * <ul>
     *  <li> JSON data is not an array </li>
     *  <li> JSON data is missing Name, StopNo, Routes or location elements for any stop</li>
     * </ul>
     */

    public void parseRoutes(String jsonResponse)
            throws JSONException, RouteDataMissingException {
        // TODO: Task 4: Implement this method
        JSONArray routes = new JSONArray(jsonResponse);

        for(int i = 0; i<routes.length(); i++){
            JSONObject route = routes.getJSONObject(i);
            parseRoute(route);
        }
    }


    private void parseRoute(JSONObject route) throws JSONException, RouteDataMissingException {
        String routeNo;
        String name;
        String patternNo;
        String destination;
        String direction;
        try {
            routeNo = route.getString("RouteNo");
            name = route.getString("Name");

        } catch (JSONException e){
            throw new RouteDataMissingException();
        }
        JSONArray patterns = route.getJSONArray("Patterns");
        for (int i = 0; i < patterns.length(); i++) {
            JSONObject pattern = patterns.getJSONObject(i);
            try {
                patternNo = pattern.getString("PatternNo");
                destination = pattern.getString("Destination");
                direction = pattern.getString("Direction");
            } catch (JSONException e){
                throw new RouteDataMissingException();
            }
            Route r = RouteManager.getInstance().getRouteWithNumber(routeNo);
            r.setName(name);
            RoutePattern rp = r.getPattern(patternNo,destination,direction);
        }
    }


}

