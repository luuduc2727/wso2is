<%--
  ~ Copyright (c) 2021-2025, WSO2 LLC. (https://www.wso2.com).
  ~
  ~ WSO2 LLC. licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file except
  ~ in compliance with the License.
  ~ You may obtain a copy of the License at
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

<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.AuthenticationEndpointUtil" %>
<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.Constants" %>
<%@ page import="org.wso2.carbon.identity.captcha.util.CaptchaUtil" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.Map" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" uri="org.wso2.identity.apps.taglibs.layout.controller" %>

<%@ include file="includes/localize.jsp" %>
<%@ include file="includes/init-url.jsp" %>

<%
    // Add the email-otp screen to the list to retrieve text branding customizations.
    screenNames.add("email-otp");
%>

<%-- Branding Preferences --%>
<jsp:directive.include file="includes/branding-preferences.jsp"/>

<%!
    private boolean isMultiAuthAvailable(String multiOptionURI) {

        boolean isMultiAuthAvailable = true;
        if (multiOptionURI == null || multiOptionURI.equals("null")) {
            isMultiAuthAvailable = false;
        } else {
            int authenticatorIndex = multiOptionURI.indexOf("authenticators=");
            if (authenticatorIndex == -1) {
                isMultiAuthAvailable = false;
            } else {
                String authenticators = multiOptionURI.substring(authenticatorIndex + 15);
                int authLastIndex = authenticators.indexOf("&") != -1 ? authenticators.indexOf("&") : authenticators.length();
                authenticators = authenticators.substring(0, authLastIndex);
                List<String> authList = Arrays.asList(authenticators.split("%3B"));
                if (authList.size() < 2) {
                    isMultiAuthAvailable = false;
                }
                else if (authList.size() == 2 && authList.contains("backup-code-authenticator%3ALOCAL")) {
                    isMultiAuthAvailable = false;
                }
            }
        }
        return isMultiAuthAvailable;
    }
%>

<%
    request.getSession().invalidate();
    String queryString = request.getQueryString();
    Map<String, String> idpAuthenticatorMapping = null;
    if (request.getAttribute(Constants.IDP_AUTHENTICATOR_MAP) != null) {
        idpAuthenticatorMapping = (Map<String, String>) request.getAttribute(Constants.IDP_AUTHENTICATOR_MAP);
    }

    String errorMessage = AuthenticationEndpointUtil.i18n(resourceBundle, "error.retry");
    String authenticationFailed = "false";

    if (Boolean.parseBoolean(request.getParameter(Constants.AUTH_FAILURE))) {
        authenticationFailed = "true";

        if (request.getParameter(Constants.AUTH_FAILURE_MSG) != null) {
            String error = request.getParameter(Constants.AUTH_FAILURE_MSG);

            if (error.equalsIgnoreCase("authentication.fail.message")) {
                errorMessage = AuthenticationEndpointUtil.i18n(resourceBundle, "error.retry.code.invalid");
            } else if (!error.equalsIgnoreCase(AuthenticationEndpointUtil.i18n(resourceBundle, error))) {
                errorMessage = AuthenticationEndpointUtil.i18n(resourceBundle, error);
            }
        }
    }
%>
<%
    boolean reCaptchaEnabled = false;
    if (request.getParameter("reCaptcha") != null && Boolean.parseBoolean(request.getParameter("reCaptcha"))) {
        reCaptchaEnabled = true;
    }
%>

<% request.setAttribute("pageName","email-otp"); %>

<html lang="en-US">
<head>
    <%-- header --%>
    <%
        File headerFile = new File(getServletContext().getRealPath("extensions/header.jsp"));
        if (headerFile.exists()) {
    %>
    <jsp:include page="extensions/header.jsp"/>
    <% } else { %>
    <jsp:include page="includes/header.jsp"/>
    <% } %>

    <%-- analytics --%>
    <%
        File analyticsFile = new File(getServletContext().getRealPath("extensions/analytics.jsp"));
        if (analyticsFile.exists()) {
    %>
        <jsp:include page="extensions/analytics.jsp"/>
    <% } else { %>
        <jsp:include page="includes/analytics.jsp"/>
    <% } %>

    <!--[if lt IE 9]>
    <script src="js/html5shiv.min.js"></script>
    <script src="js/respond.min.js"></script>
    <![endif]-->

    <%
        if (reCaptchaEnabled) {
            String reCaptchaAPI = CaptchaUtil.reCaptchaAPIURL();
    %>
        <script src='<%=(reCaptchaAPI)%>'></script>
    <%
        }
    %>
    <script type="text/javascript">
        function getOtpCodeFromBoxes() {
            var s = '';
            for (var i = 1; i <= 6; i++) {
                var el = document.getElementById('otp-' + i);
                if (el) s += (el.value || '').replace(/\D/g, '').slice(0, 1);
            }
            return s;
        }
        function setOtpCodeToBoxes(code) {
            var digits = (code || '').replace(/\D/g, '').slice(0, 6).split('');
            for (var i = 1; i <= 6; i++) {
                var el = document.getElementById('otp-' + i);
                if (el) el.value = digits[i - 1] || '';
            }
        }
        function submitForm() {
            var insightsTenantIdentifier = "<%=userTenant%>";
            var code = getOtpCodeFromBoxes();
            var hiddenOtp = document.getElementById("OTPCode");
            if (hiddenOtp) hiddenOtp.value = code;
            if (code.length < 6) {
                document.getElementById('alertDiv').innerHTML
                    = '<div id="error-msg" class="ui negative message"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "error.enter.code")%></div>'
                    +'<div class="ui divider hidden"></div>';
            } else {
                if ($('#codeForm').data("submitted") === true) {
                    console.warn("Prevented a possible double submit event");
                } else {
                    trackEvent("authentication-portal-email-otp-click-continue", {
                        "tenant": insightsTenantIdentifier !== "null" ? insightsTenantIdentifier : ""
                    });
                    $('#codeForm').data("submitted", true);
                    $('#codeForm').submit();
                }
            }
        }
    </script>
</head>

<body class="login-portal layout email-otp-portal-layout" data-page="<%= request.getAttribute("pageName") %>">
    <% if (new File(getServletContext().getRealPath("extensions/timeout.jsp")).exists()) { %>
        <jsp:include page="extensions/timeout.jsp"/>
    <% } else { %>
        <jsp:include page="util/timeout.jsp"/>
    <% } %>

    <%-- Header giống màn đăng nhập (TECHCOMBANK) --%>
    <%
        File appHeaderFile = new File(getServletContext().getRealPath("extensions/app-header.jsp"));
        if (appHeaderFile.exists()) {
    %>
        <jsp:include page="extensions/app-header.jsp"/>
    <% } else { %>
        <jsp:include page="includes/app-header.jsp"/>
    <% } %>

    <layout:main layoutName="<%= layout %>" layoutFileRelativePath="<%= layoutFileRelativePath %>" data="<%= layoutData %>" >
        <layout:component componentName="ProductHeader">
            <%-- Để trống khi đã render app-header ở trên --%>
        </layout:component>
        <layout:component componentName="MainSection">
            <div class="login-signup-cards-wrapper">
                <div id="alertDiv"></div>
                <div class="login-card ui-segment otp-card">
                    <h3><%=AuthenticationEndpointUtil.i18n(resourceBundle, "login.card.heading")%></h3>
                    <div class="otp-card-content">
                    <div class="segment-form">
                        <form class="ui large form" id="codeForm" name="codeForm" action="<%=commonauthURL%>" method="POST">
                            <%-- Div 1: chỉ p + field 6 ô OTP --%>
                            <div class="otp-part-1 otp-instruction-and-input">
                                <p class="otp-instruction"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "enter.code")%></p>
                                <div class="field field-label-input">
                                    <div class="ui fluid icon input addon-wrapper otp-input-wrapper otp-boxes-wrapper" id="otpBoxesWrapper">
                                        <input type="hidden" id="OTPCode" name="OTPCode" value=""/>
                                        <input type="text" id="otp-1" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="1"/>
                                        <input type="text" id="otp-2" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="2"/>
                                        <input type="text" id="otp-3" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="3"/>
                                        <input type="text" id="otp-4" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="4"/>
                                        <input type="text" id="otp-5" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="5"/>
                                        <input type="text" id="otp-6" class="otp-box-input" maxlength="1" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-describedby="OTPDescription" data-index="6"/>
                                    </div>
                                </div>
                            </div>
                            <%
                                if ("true".equals(authenticationFailed)) {
                            %>
                            <% } %>
                            <%
                                String resendCode = request.getParameter("resendCode");
                                if (resendCode != null && "true".equals(resendCode)) {
                            %>
                            <div id="resend-msg" class="ui positive message"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "resend.code.success")%></div>
                            <% } %>
                            <input type="hidden" name="sessionDataKey" value="<%=Encode.forHtmlAttribute(request.getParameter("sessionDataKey"))%>"/>
                            <input type="hidden" name="resendCode" id="resendCode" value="false"/>

                            <%-- Div riêng: expiry (countdown circle: đang chạy #000000, đã chạy qua #DEDEDE) --%>
                            <div class="otp-expiry-wrap">
                                <div class="otp-expiry-row">
                                    <span class="otp-expiry-text"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "otp.expire.in")%> <span class="otp-expiry-circle" id="otp-expiry-circle-wrap" aria-hidden="false"><svg class="otp-expiry-circle-svg" viewBox="0 0 36 36" aria-hidden="true"><circle class="otp-expiry-circle-bg" cx="18" cy="18" r="16" fill="none" stroke="#DEDEDE" stroke-width="3"/><circle class="otp-expiry-circle-progress" id="otp-expiry-circle-progress" cx="18" cy="18" r="16" fill="none" stroke="#000000" stroke-width="3" stroke-dasharray="100.53 999" stroke-linecap="round" transform="rotate(-90 18 18)"/></svg><span id="otp-expiry-seconds" class="otp-expiry-circle-value">100</span></span><%=AuthenticationEndpointUtil.i18n(resourceBundle, "otp.seconds")%></span>
                                </div>
                            </div>
                            <%-- Thông báo lỗi: dưới phần hết hiệu lực, cùng style + icon như basicauth --%>
                            <% if ("true".equals(authenticationFailed)) { %>
                            <div class="ui visible visible visible visible negative message" id="failed-msg" data-testid="otp-page-error-message">
                                <div class="error-message-content">
                                    <img src="images/_x-circle.svg" width="24" height="24" alt="" class="error-icon">
                                    <div><%=Encode.forHtmlContent(errorMessage)%></div>
                                </div>
                            </div>
                            <% } %>
                            <%
                                String loginFailed = request.getParameter("authFailure");
                                if (loginFailed != null && "true".equals(loginFailed)) {
                                    String authFailureMsg = request.getParameter("authFailureMsg");
                                    if (authFailureMsg != null && "login.fail.message".equals(authFailureMsg)) { %>
                            <div class="ui visible visible visible visible negative message" data-testid="otp-page-error-message">
                                <div class="error-message-content">
                                    <img src="images/_x-circle.svg" width="24" height="24" alt="" class="error-icon">
                                    <div><%=AuthenticationEndpointUtil.i18n(resourceBundle, "error.retry")%></div>
                                </div>
                            </div>
                            <%   }
                               } %>
                            <% if (request.getParameter("multiOptionURI") != null &&
                                AuthenticationEndpointUtil.isValidURL(request.getParameter("multiOptionURI")) &&
                                request.getParameter("multiOptionURI").contains("backup-code-authenticator")) { %>
                            <div class="field text-left">
                                <a onclick="window.location.href='<%=commonauthURL%>?idp=LOCAL&authenticator=backup-code-authenticator&sessionDataKey=<%=Encode.forUriComponent(request.getParameter("sessionDataKey"))%>&multiOptionURI=<%=Encode.forUriComponent(request.getParameter("multiOptionURI"))%>';" class="clickable-link" rel="noopener noreferrer" data-testid="login-page-backup-code-link">
                                    <%=AuthenticationEndpointUtil.i18n(resourceBundle, "use.backup.code")%>
                                </a>
                            </div>
                            <% } %>
                            <%-- Nút Login + Resend (resend ẩn tạm) --%>
                            <div class="otp-buttons-wrap">
                                <div class="buttons">
                                    <button type="button" name="authenticate" id="authenticate" class="btn-420x40" data-testid="login-page-continue-login-button" disabled>
                                        <%=AuthenticationEndpointUtil.i18n(resourceBundle, "login.button")%>
                                    </button>
                                    <a class="resend-otp-link" tabindex="0" id="resend" style="display: none;"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "resend.code")%></a>
                                </div>
                            </div>
                            <%-- Nút Back: history back --%>
                            <div class="otp-back-btn-wrap">
                                <a class="back-link btn-420x40 otp-back-button" id="goBackLink" href="javascript:void(0)" onclick="history.back(); return false;"><%=AuthenticationEndpointUtil.i18n(resourceBundle, "otp.back")%></a>
                            </div>

                            <input id="multiOptionURI" type="hidden" name="multiOptionURI" value="<%=Encode.forHtmlAttribute(request.getParameter("multiOptionURI"))%>" />
                            <% if (reCaptchaEnabled) {
                                String reCaptchaKey = CaptchaUtil.reCaptchaSiteKey();
                            %>
                            <div class="field mt-3">
                                <div class="g-recaptcha" data-sitekey="<%=Encode.forHtmlAttribute(reCaptchaKey)%>" data-testid="login-page-g-recaptcha" data-bind="authenticate" data-callback="submitForm" data-theme="light" data-tabindex="-1"></div>
                            </div>
                            <% } %>
                        </form>
                    </div>

                    </div><!-- .otp-card-content -->
                </div>
            </div>
        </layout:component>
    </layout:main>

    <%-- footer --%>
    <%
        File footerFile = new File(getServletContext().getRealPath("extensions/footer.jsp"));
        if (footerFile.exists()) {
    %>
        <jsp:include page="extensions/footer.jsp"/>
    <% } else { %>
        <jsp:include page="includes/footer.jsp"/>
    <% } %>

    <script type="text/javascript">

        $(document).ready(function () {
            var $btn = $('#authenticate');
            $btn.prop('disabled', true);
            $btn.click(function (e) {
                if ($(this).prop('disabled') || getOtpCodeFromBoxes().length < 6) {
                    e.preventDefault();
                    return false;
                }
                <% if (!reCaptchaEnabled) { %>
                    submitForm();
                <% } %>
            });
        });

        $(document).ready(function () {
            $('#resend').click(function () {
                document.getElementById("resendCode").value = "true";
                $('#codeForm').submit();
            });
        });

        // Show OTP code function (toggle text/password for all 6 boxes).
        function showOTPCode() {
            var inputs = document.querySelectorAll('.otp-box-input');
            var eye = document.getElementById("password-eye");
            if (!inputs.length || !eye) return;
            var isText = inputs[0].type === 'text';
            for (var i = 0; i < inputs.length; i++) {
                inputs[i].type = isText ? 'password' : 'text';
            }
            eye.classList.toggle('slash', isText);
        }

        (function initOtpBoxes() {
            var OTP_LEN = 6;
            function getBox(i) { return document.getElementById('otp-' + i); }
            function isOtpComplete() {
                var code = '';
                for (var i = 1; i <= OTP_LEN; i++) {
                    var el = getBox(i);
                    if (el) code += (el.value || '').replace(/\D/g, '').slice(0, 1);
                }
                return code.length === OTP_LEN;
            }
            function updateSubmitButton() {
                var btn = document.getElementById('authenticate');
                if (btn) {
                    btn.disabled = !isOtpComplete();
                    if (typeof $ !== 'undefined') $(btn).prop('disabled', !isOtpComplete());
                }
            }
            function onInput(e) {
                var el = e.target;
                var idx = parseInt(el.getAttribute('data-index'), 10);
                var v = el.value.replace(/\D/g, '');
                el.value = v.slice(0, 1);
                if (v.length >= 1 && idx < OTP_LEN) {
                    var next = getBox(idx + 1);
                    if (next) next.focus();
                }
                updateSubmitButton();
            }
            function onKeyDown(e) {
                var el = e.target;
                var idx = parseInt(el.getAttribute('data-index'), 10);
                if (e.key === 'Backspace' && !el.value && idx > 1) {
                    var prev = getBox(idx - 1);
                    if (prev) { prev.focus(); prev.value = ''; }
                }
                setTimeout(updateSubmitButton, 0);
            }
            function onPaste(e) {
                e.preventDefault();
                var paste = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '').slice(0, OTP_LEN);
                for (var i = 1; i <= OTP_LEN; i++) {
                    var box = getBox(i);
                    if (box) box.value = paste[i - 1] || '';
                }
                if (paste.length > 0) {
                    var nextIdx = Math.min(paste.length + 1, OTP_LEN);
                    var next = getBox(nextIdx);
                    if (next) next.focus();
                }
                updateSubmitButton();
            }
            $(document).ready(function () {
                for (var i = 1; i <= OTP_LEN; i++) {
                    var box = getBox(i);
                    if (box) {
                        box.addEventListener('input', onInput);
                        box.addEventListener('keydown', onKeyDown);
                        box.addEventListener('paste', onPaste);
                    }
                }
                updateSubmitButton();
            });
        })();

        $(document).ready(handleWaitBeforeResendOTP);

        function handleWaitBeforeResendOTP() {
            const WAIT_TIME_SECONDS = 100;
            const CIRCLE_CIRCUMFERENCE = 2 * Math.PI * 16;
            const resendButton = document.getElementById("resend");
            const expiryEl = document.getElementById("otp-expiry-seconds");
            const progressCircle = document.getElementById("otp-expiry-circle-progress");
            if (!resendButton) return;

            function setCircleProgress(remainingSec) {
                if (!progressCircle) return;
                var ratio = Math.max(0, remainingSec) / WAIT_TIME_SECONDS;
                var dashLength = CIRCLE_CIRCUMFERENCE * ratio;
                progressCircle.setAttribute("stroke-dasharray", dashLength.toFixed(2) + " 999");
            }

            resendButton.classList.add("disabled");

            const resendButtonText = resendButton.innerText;
            resendButton.innerHTML = Math.floor(WAIT_TIME_SECONDS / 60).toString().padStart(2, '0') + " : " + (WAIT_TIME_SECONDS % 60).toString().padStart(2, '0');

            const countdown = new Countdown(
                Countdown.seconds(WAIT_TIME_SECONDS),
                () => {
                    resendButton.innerHTML = resendButtonText;
                    resendButton.classList.remove("disabled");
                    if (expiryEl) expiryEl.textContent = "0";
                    setCircleProgress(0);
                },
                (time) => {
                    var totalSec = time.minutes * 60 + time.seconds;
                    resendButton.innerHTML = time.minutes.toString().padStart(2, '0') + " : " + time.seconds.toString().padStart(2, '0');
                    if (expiryEl) expiryEl.textContent = String(totalSec);
                    setCircleProgress(totalSec);
                },
                "EMAIL_OTP_TIMER"
            ).start();
            if (expiryEl) expiryEl.textContent = String(WAIT_TIME_SECONDS);
            setCircleProgress(WAIT_TIME_SECONDS);
        }
    </script>
</body>
</html>
