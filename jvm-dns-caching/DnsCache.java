import java.net.InetAddress;
import java.security.Security;

/** Shows the JVM DNS cache TTL: the JVM caches lookups per networkaddress.cache.ttl, independent of DNS TTL. */
public class DnsCache {
    public static void main(String[] args) throws Exception {
        String host = args.length > 0 ? args[0] : "localhost";
        System.out.println("networkaddress.cache.ttl = " + Security.getProperty("networkaddress.cache.ttl"));
        System.out.println("networkaddress.cache.negative.ttl = " + Security.getProperty("networkaddress.cache.negative.ttl"));
        for (int i = 0; i < 3; i++) {
            long t0 = System.nanoTime();
            InetAddress a = InetAddress.getByName(host);
            System.out.printf("lookup %d: %s in %d us%n", i, a.getHostAddress(), (System.nanoTime() - t0) / 1000);
        }
    }
}
