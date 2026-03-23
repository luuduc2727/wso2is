<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.AuthenticationEndpointUtil" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="javax.servlet.http.Cookie" %>
<jsp:directive.include file="localize.jsp" />
<%
    // Ensure env is loaded (extensions/header.jsp may not include env.jsp)
    if (request.getAttribute("devPortalUrl") == null && application.getResource("/extensions/env.jsp") != null) {
        %><jsp:include page="/extensions/env.jsp"/><%
    }
    String devPortalUrl = (String) request.getAttribute("devPortalUrl");
    if (devPortalUrl == null) {
        devPortalUrl = "";
    }

    // Decide language segment from ui_lang cookie (e.g. vi_VN -> vi, en_US -> en).
    String langFromCookie = null;
    Cookie[] headerCookies = request.getCookies();
    if (headerCookies != null) {
        for (Cookie c : headerCookies) {
            if ("ui_lang".equals(c.getName())) {
                langFromCookie = c.getValue();
                break;
            }
        }
    }
    String langSegment = "en";
    if (langFromCookie != null) {
        if (langFromCookie.startsWith("vi_VN")) {
            langSegment = "vi";
        } else if (langFromCookie.startsWith("en_US")) {
            langSegment = "en";
        }
    }

    // Build nav paths from a single base path + language segment.
    String navBase = devPortalUrl;
    if (navBase.endsWith("/")) {
        navBase = navBase.substring(0, navBase.length() - 1);
    }
    String localizedBase = navBase + "/" + langSegment;
    String apiProductsPath = localizedBase + "/api-products";
    String newsPath = localizedBase + "/news";
    String supportPath = localizedBase + "/support";
%>
<div class="app-header-bar">
    <div class="app-header-main">
        <a href="<%= Encode.forHtmlAttribute(apiProductsPath) %>" class="app-header-logo" id="app-header-logo-link" aria-label="<%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.logo.alt")%>">
            <img src="images/techcombank_TCBM.svg" alt="<%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.logo.alt")%>" class="app-header-logo-img app-header-logo-img-default"/>
            <img src="images/Logomark.svg" alt="<%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.logo.alt")%>" class="app-header-logo-img app-header-logo-img-logomark"/>
        </a>
        <nav class="app-header-nav" aria-label="Main">
            <ul class="app-header-nav-list">
                <li><a href="<%= Encode.forHtmlAttribute(apiProductsPath) %>" class="app-header-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.api.products")%></a></li>
                <li><a href="<%= Encode.forHtmlAttribute(newsPath) %>" class="app-header-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.news")%></a></li>
                <li><a href="<%= Encode.forHtmlAttribute(supportPath) %>" class="app-header-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.support")%></a></li>
            </ul>
        </nav>
        <div class="app-header-right">
            <div class="app-header-lang-wrap">
                <jsp:include page="language-switcher.jsp"/>
            </div>
            <button type="button" class="app-header-login-btn app-header-login-btn-desktop" onclick="window.location.reload();" aria-label="<%= AuthenticationEndpointUtil.i18n(resourceBundle, "login.button")%>"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "login.button")%> <img src="images/nextpage.svg" alt="" class="app-header-arrow-icon" aria-hidden="true"/></button>
        </div>
        <div class="app-header-mobile-actions">
            <button type="button" class="app-header-login-btn app-header-login-btn-responsive" onclick="window.location.reload();" aria-label="<%= AuthenticationEndpointUtil.i18n(resourceBundle, "login.button")%>"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "login.button")%></button>
            <span class="app-header-mobile-actions-sep" aria-hidden="true"></span>
            <button type="button" class="app-header-hamburger" id="app-header-hamburger" aria-label="Menu" aria-expanded="false" aria-controls="app-header-drawer">
                <img src="images/Menu.svg" alt="" class="app-header-hamburger-icon" width="24" height="24" aria-hidden="true"/>
            </button>
        </div>
    </div>
</div>
<%-- Drawer cho mobile: chỉ nav + language (nút Login giữ trên header) --%>
<div class="app-header-drawer" id="app-header-drawer" aria-hidden="true">
    <div class="app-header-drawer-backdrop" id="app-header-drawer-backdrop"></div>
    <div class="app-header-drawer-panel">
        <nav class="app-header-drawer-nav" aria-label="Main">
            <ul class="app-header-drawer-nav-list">
                <li><a href="<%= Encode.forHtmlAttribute(apiProductsPath) %>" class="app-header-drawer-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.api.products")%></a></li>
                <li><a href="<%= Encode.forHtmlAttribute(newsPath) %>" class="app-header-drawer-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.news")%></a></li>
                <li><a href="<%= Encode.forHtmlAttribute(supportPath) %>" class="app-header-drawer-nav-link"><%= AuthenticationEndpointUtil.i18n(resourceBundle, "header.nav.support")%></a></li>
            </ul>
        </nav>
        <div class="app-header-drawer-right">
            <div class="app-header-drawer-lang-wrap">
                <jsp:include page="language-switcher-drawer.jsp"/>
            </div>
        </div>
    </div>
</div>
<script>
(function() {
    var hamburger = document.getElementById('app-header-hamburger');
    var drawer = document.getElementById('app-header-drawer');
    var backdrop = document.getElementById('app-header-drawer-backdrop');
    if (!hamburger || !drawer) return;
    function openDrawer() {
        drawer.classList.add('app-header-drawer-open');
        drawer.setAttribute('aria-hidden', 'false');
        hamburger.setAttribute('aria-expanded', 'true');
        document.body.style.overflow = 'hidden';
    }
    function closeDrawer() {
        drawer.classList.remove('app-header-drawer-open');
        drawer.setAttribute('aria-hidden', 'true');
        hamburger.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
    }
    hamburger.addEventListener('click', function() {
        if (drawer.classList.contains('app-header-drawer-open')) closeDrawer(); else openDrawer();
    });
    if (backdrop) backdrop.addEventListener('click', closeDrawer);
})();
</script>
