<%--
  ~ Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org).
  ~
  ~  WSO2 Inc. licenses this file to you under the Apache License,
  ~  Version 2.0 (the "License"); you may not use this file except
  ~  in compliance with the License.
  ~  You may obtain a copy of the License at
  ~
  ~    http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
--%>

<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.AuthenticationEndpointUtil" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>

<%-- Localization --%>
<jsp:directive.include file="localize.jsp" />

<%
    String filePath = application.getRealPath("/") + "/WEB-INF/classes/LanguageOptions.properties";
    List<String[]> languageList = new ArrayList<>();
    try (BufferedReader bufferedReader = new BufferedReader(new FileReader(filePath))) {
        String line;
        while ((line = bufferedReader.readLine()) != null) {
            if (!line.trim().startsWith("#") && !line.trim().isEmpty()) {
                String[] keyValue = line.split("=");
                String[] parts = keyValue[0].split("\\.");
                String languageCode = parts[parts.length - 1];
                String[] values = keyValue[1].split(",");
                String displayName = values[1];
                languageList.add(new String[]{languageCode, values[0], displayName});
            }
        }
    } catch (Exception e) {
        throw e;
    }
%>

<div id="language-selector-dropdown-drawer" class="ui fluid selection dropdown language-selector-dropdown" data-testid="language-selector-dropdown-drawer">
    <input type="hidden" id="language-selector-input-drawer" onChange="onLangChange(this)" name="language-select-drawer" />
    <img src="images/public.svg" alt="" class="language-selector-globe-icon" aria-hidden="true" />
    <div id="language-selector-selected-text-drawer" class="default text">
        <%=AuthenticationEndpointUtil.i18n(resourceBundle, "select.language")%>
    </div>
    <img src="images/icon-arrow-chevron-down.svg" alt="" class="language-selector-chevron-icon" aria-hidden="true" />

    <div class="menu">
        <% for (String[] language : languageList) { %>
            <div class="item"
                 data-value="<%= language[0] %>"
            >
                <%= AuthenticationEndpointUtil.i18n(resourceBundle, language[2]) %>
            </div>
        <% } %>
    </div>
</div>
