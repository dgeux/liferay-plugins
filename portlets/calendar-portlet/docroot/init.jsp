<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %><%@
taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %><%@
taglib uri="http://liferay.com/tld/security" prefix="liferay-security" %><%@
taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %><%@
taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %><%@
taglib uri="http://liferay.com/tld/util" prefix="liferay-util" %>

<%@ page import="com.liferay.calendar.CalendarResourceCodeException" %><%@
page import="com.liferay.calendar.DuplicateCalendarResourceException" %><%@
page import="com.liferay.calendar.model.Calendar" %><%@
page import="com.liferay.calendar.model.CalendarBooking" %><%@
page import="com.liferay.calendar.model.CalendarResource" %><%@
page import="com.liferay.calendar.notification.NotificationTemplateType" %><%@
page import="com.liferay.calendar.notification.NotificationType" %><%@
page import="com.liferay.calendar.search.CalendarResourceDisplayTerms" %><%@
page import="com.liferay.calendar.search.CalendarResourceSearch" %><%@
page import="com.liferay.calendar.search.CalendarResourceSearchTerms" %><%@
page import="com.liferay.calendar.service.CalendarBookingLocalServiceUtil" %><%@
page import="com.liferay.calendar.service.CalendarBookingServiceUtil" %><%@
page import="com.liferay.calendar.service.CalendarLocalServiceUtil" %><%@
page import="com.liferay.calendar.service.CalendarResourceServiceUtil" %><%@
page import="com.liferay.calendar.service.CalendarServiceUtil" %><%@
page import="com.liferay.calendar.service.permission.CalendarPermission" %><%@
page import="com.liferay.calendar.service.permission.CalendarPortletPermission" %><%@
page import="com.liferay.calendar.service.permission.CalendarResourcePermission" %><%@
page import="com.liferay.calendar.util.ActionKeys" %><%@
page import="com.liferay.calendar.util.CalendarResourceUtil" %><%@
page import="com.liferay.calendar.util.CalendarUtil" %><%@
page import="com.liferay.calendar.util.ColorUtil" %><%@
page import="com.liferay.calendar.util.JCalendarUtil" %><%@
page import="com.liferay.calendar.util.NotificationUtil" %><%@
page import="com.liferay.calendar.util.PortletPropsKeys" %><%@
page import="com.liferay.calendar.util.PortletPropsValues" %><%@
page import="com.liferay.calendar.util.WebKeys" %><%@
page import="com.liferay.calendar.util.comparator.CalendarNameComparator" %><%@
page import="com.liferay.calendar.workflow.CalendarBookingWorkflowConstants" %><%@
page import="com.liferay.portal.kernel.bean.BeanParamUtil" %><%@
page import="com.liferay.portal.kernel.dao.orm.QueryUtil" %><%@
page import="com.liferay.portal.kernel.dao.search.ResultRow" %><%@
page import="com.liferay.portal.kernel.json.JSONArray" %><%@
page import="com.liferay.portal.kernel.json.JSONFactoryUtil" %><%@
page import="com.liferay.portal.kernel.json.JSONObject" %><%@
page import="com.liferay.portal.kernel.language.LanguageUtil" %><%@
page import="com.liferay.portal.kernel.util.CalendarFactoryUtil" %><%@
page import="com.liferay.portal.kernel.util.Constants" %><%@
page import="com.liferay.portal.kernel.util.GetterUtil" %><%@
page import="com.liferay.portal.kernel.util.HtmlUtil" %><%@
page import="com.liferay.portal.kernel.util.HttpUtil" %><%@
page import="com.liferay.portal.kernel.util.OrderByComparator" %><%@
page import="com.liferay.portal.kernel.util.ParamUtil" %><%@
page import="com.liferay.portal.kernel.util.PrefsParamUtil" %><%@
page import="com.liferay.portal.kernel.util.StringPool" %><%@
page import="com.liferay.portal.kernel.util.StringUtil" %><%@
page import="com.liferay.portal.kernel.util.UnicodeFormatter" %><%@
page import="com.liferay.portal.kernel.util.Validator" %><%@
page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %><%@
page import="com.liferay.portal.model.Group" %><%@
page import="com.liferay.portal.model.User" %><%@
page import="com.liferay.portal.service.GroupServiceUtil" %><%@
page import="com.liferay.portal.service.UserLocalServiceUtil" %><%@
page import="com.liferay.portal.util.PortalUtil" %><%@
page import="com.liferay.portal.util.SessionClicks" %><%@
page import="com.liferay.portal.util.comparator.UserScreenNameComparator" %><%@
page import="com.liferay.portlet.PortletPreferencesFactoryUtil" %>

<%@ page import="java.util.ArrayList" %><%@
page import="java.util.List" %><%@
page import="java.util.TimeZone" %>

<%@ page import="javax.portlet.PortletPreferences" %><%@
page import="javax.portlet.PortletURL" %>

<portlet:defineObjects />

<liferay-theme:defineObjects />

<%
String currentURL = PortalUtil.getCurrentURL(request);

PortletPreferences preferences = renderRequest.getPreferences();

String portletResource = ParamUtil.getString(request, "portletResource");

if (Validator.isNotNull(portletResource)) {
	preferences = PortletPreferencesFactoryUtil.getPortletSetup(request, portletResource);
}

CalendarResource groupCalendarResource = CalendarResourceUtil.getGroupCalendarResource(liferayPortletRequest, scopeGroupId);

CalendarResource userCalendarResource = null;
Calendar userDefaultCalendar = null;

if (themeDisplay.isSignedIn()) {
	userCalendarResource = CalendarResourceUtil.getUserCalendarResource(liferayPortletRequest, themeDisplay.getUserId());

	if (userCalendarResource != null) {
		userDefaultCalendar = CalendarServiceUtil.getCalendar(userCalendarResource.getDefaultCalendarId());
	}
}

String dayViewHeaderDateFormat = preferences.getValue("dayViewHeaderDateFormat", "%d %A");
String navigationHeaderDateFormat = preferences.getValue("navigationHeaderDateFormat", "%A - %d %b %Y");
boolean isoTimeFormat = GetterUtil.getBoolean(preferences.getValue("isoTimeFormat", null));

TimeZone utcTimeZone = TimeZone.getTimeZone(StringPool.UTC);

java.util.Calendar now = CalendarFactoryUtil.getCalendar(timeZone);
%>