package ca.ubc.cs.cpsc210.translink.util;

/**
 * Compute relationships between points, lines, and rectangles represented by LatLon objects
 */
public class Geometry {
    /**
     * Return true if the point is inside of, or on the boundary of, the rectangle formed by northWest and southeast
     * @param northWest         the coordinate of the north west corner of the rectangle
     * @param southEast         the coordinate of the south east corner of the rectangle
     * @param point             the point in question
     * @return                  true if the point is on the boundary or inside the rectangle
     */
    public static boolean rectangleContainsPoint(LatLon northWest, LatLon southEast, LatLon point) {
        // TODO: Task 5: Implement this method
        double y1 = northWest.getLatitude();
        double x1 = northWest.getLongitude();
        double y2 = southEast.getLatitude();
        double x2 = southEast.getLongitude();
        double a,b,c,d;
        if (x1>=x2){
            c = x2;
            d = x1;
        } else {
            c = x1;
            d = x2;
        }

        if (y1>=y2){
            a = y2;
            b = y1;
        } else{
            a = y1;
            b = y2;
        }
        return between(a,b,point.getLatitude()) && between(c,d,point.getLongitude());
    }


    /**
     * Return true if the rectangle intersects the line
     * @param northWest         the coordinate of the north west corner of the rectangle
     * @param southEast         the coordinate of the south east corner of the rectangle
     * @param src               one end of the line in question
     * @param dst               the other end of the line in question
     * @return                  true if any point on the line is on the boundary or inside the rectangle
     */
    public static boolean rectangleIntersectsLine(LatLon northWest, LatLon southEast, LatLon src, LatLon dst) {
        // TODO: Tasks 5: Implement this method


        LatLon northEast = new LatLon(northWest.getLatitude(), southEast.getLongitude());
        LatLon southWest = new LatLon(southEast.getLatitude(), northWest.getLongitude());

        return LineIntersectsLine(src, dst, northWest, northEast) ||
                LineIntersectsLine(src, dst, northEast, southEast) ||
                LineIntersectsLine(src, dst, southEast, southWest) ||
                LineIntersectsLine(src, dst, southWest, northWest) ||
                rectangleContainsPoint(northWest, southEast, src) ||
                rectangleContainsPoint(northWest, southEast, dst);
    }


    public static boolean LineIntersectsLine (LatLon l1s, LatLon l1d, LatLon l2s, LatLon l2d){
        // get all vallues of 4 points
        double x1 = l1s.getLatitude();
        double y1 = l1s.getLongitude();
        double x2 = l1d.getLatitude();
        double y2 = l1d.getLongitude();
        double x3 = l2s.getLatitude();
        double y3 = l2s.getLongitude();
        double x4 = l2d.getLatitude();
        double y4 = l2d.getLongitude();

        double denom = (y2 - y1) * (x4 - x3) - (x2 - x1) * (y4 - y3);
        double numeA = (x1 - x3 * (y4 - y3) - (y1 - y3) * (x4 - x3));
        double numeB = (x1 - x3) * (y3 - y1) - (y1 - y3) * (x2 - x1);

        if(denom == 0)
        {
            return false;
        }

        double r = numeA / denom;
        double s = numeB / denom;

        if( r < 0 || r > 1 || s < 0 || s > 1 )
        {
            return false;
        }

        return true;
        /*
        double i1s;
        double i1d;
        double i2s;
        double i2d;

        if (xy1.getLatitude() > xy2.getLatitude()){
            i1s = xy1.getLatitude();
            i1d = xy2.getLatitude();
        } else {
            i1s = xy2.getLatitude();
            i1d = xy1.getLatitude();
        }

        if (xy3.getLatitude() > xy4.getLatitude()){
            i2s = xy3.getLatitude();
            i2d = xy4.getLatitude();
        } else {
            i2s = xy4.getLatitude();
            i2d = xy3.getLatitude();
        }*/
    }

    /**
     * A utility method that you might find helpful in implementing the two previous methods
     * Return true if x is >= lwb and <= upb
     * @param lwb      the lower boundary
     * @param upb      the upper boundary
     * @param x         the value in question
     * @return          true if x is >= lwb and <= upb
     */
    private static boolean between(double lwb, double upb, double x) {
        return lwb <= x && x <= upb;
    }
}
