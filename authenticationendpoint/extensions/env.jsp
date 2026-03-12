<%@ page import="java.util.Properties" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.InputStream" %>
<%
    // --- Read from environment / system properties first ---
    String devPortalClientId = System.getenv("DEV_PORTAL_CLIENT_ID");
    if (devPortalClientId == null || devPortalClientId.trim().isEmpty()) {
        devPortalClientId = System.getProperty("DEV_PORTAL_CLIENT_ID");
    }

    String devPortalUrl = System.getenv("DEV_PORTAL_URL");
    if (devPortalUrl == null || devPortalUrl.trim().isEmpty()) {
        devPortalUrl = System.getProperty("DEV_PORTAL_URL");
    }

    String apiProductsUrl = System.getenv("API_PRODUCTS_URL");
    if (apiProductsUrl == null || apiProductsUrl.trim().isEmpty()) {
        apiProductsUrl = System.getProperty("API_PRODUCTS_URL");
    }
    String newsUrl = System.getenv("NEWS_URL");
    if (newsUrl == null || newsUrl.trim().isEmpty()) {
        newsUrl = System.getProperty("NEWS_URL");
    }
    String supportUrl = System.getenv("SUPPORT_URL");
    if (supportUrl == null || supportUrl.trim().isEmpty()) {
        supportUrl = System.getProperty("SUPPORT_URL");
    }

    // --- Then fall back to extensions/env.properties ---
    Properties props = new Properties();
    File propsFile = new File(application.getRealPath("extensions/env.properties"));
    if (propsFile.exists() && propsFile.isFile()) {
        try (InputStream in = new FileInputStream(propsFile)) {
            props.load(in);
        } catch (Exception ignore) {
            // Ignore, we will fall back to defaults below.
        }
    }

    if (devPortalClientId == null || devPortalClientId.trim().isEmpty()) {
        String fromProps = props.getProperty("DEV_PORTAL_CLIENT_ID");
        if (fromProps != null) {
            devPortalClientId = fromProps.trim();
        }
    }
    if (devPortalClientId == null) {
        devPortalClientId = "";
    }

    if (devPortalUrl == null || devPortalUrl.trim().isEmpty()) {
        String fromPropsUrl = props.getProperty("DEV_PORTAL_URL");
        if (fromPropsUrl != null) {
            devPortalUrl = fromPropsUrl.trim();
        }
    }
    if (devPortalUrl == null) {
        devPortalUrl = "";
    }

    if (apiProductsUrl == null || apiProductsUrl.trim().isEmpty()) {
        String v = props.getProperty("API_PRODUCTS_URL");
        apiProductsUrl = (v != null) ? v.trim() : "#";
    }
    if (newsUrl == null || newsUrl.trim().isEmpty()) {
        String v = props.getProperty("NEWS_URL");
        newsUrl = (v != null) ? v.trim() : "#";
    }
    if (supportUrl == null || supportUrl.trim().isEmpty()) {
        String v = props.getProperty("SUPPORT_URL");
        supportUrl = (v != null) ? v.trim() : "#";
    }

    // Store in request scope for use in header/nav and other JSPs
    request.setAttribute("devPortalClientId", devPortalClientId);
    request.setAttribute("devPortalUrl", devPortalUrl);
    request.setAttribute("apiProductsUrl", apiProductsUrl);
    request.setAttribute("newsUrl", newsUrl);
    request.setAttribute("supportUrl", supportUrl);
%>
