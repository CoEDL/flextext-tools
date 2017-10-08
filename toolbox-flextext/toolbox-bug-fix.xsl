<?xml version="1.0" encoding="UTF-8"?>

<!-- java saxon usage:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exslt="http://exslt.org/common">

	<!--XML formatting controls-->
	<xsl:output indent="yes" media-type="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="mb">
		<xsl:choose>
			<!-- special condition for some buggy input where a set of morphs are all in one mb element -->
			<xsl:when test="matches(., ' -.+ ')">
				<xsl:for-each select="tokenize(., ' +')">
					<xsl:element name="mb">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ge">
		<xsl:choose>
			<!-- special condition for some buggy input where a set of morphs are all in one mb element -->
			<xsl:when test="matches(., ' -.+ ')">
				<xsl:for-each select="tokenize(., ' +')">
					<xsl:element name="ge">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ps">
		<xsl:choose>
			<!-- special condition for some buggy input where a set of morphs are all in one mb element -->
			<xsl:when test="matches(., ' -.+ ')">
				<xsl:for-each select="tokenize(., ' +')">
					<xsl:element name="ps">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- By default just copy elements -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>