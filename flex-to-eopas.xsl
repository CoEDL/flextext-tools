<?xml version="1.0" encoding="UTF-8"?>

<!-- Transforms flextext xml into eopas xml 
By John Mansfield, University of Melbourne, 10 August 2015-->

<!-- USAGE EXAMPLES:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t SOURCEPATH/SOURCE.flextext scripts/flex-to-eopas.xsl >TARGETPATH/SOURCE_eopas.xml

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/">

	<!--xsl:output indent="no" media-type="xml"/-->
	<xsl:output indent="yes" media-type="xml"/>

	<xsl:preserve-space elements="*"/>

	<xsl:template match="document">
		<eopas>
			<xsl:element name="header">
				<xsl:element name="meta">
					<xsl:attribute name="name">
						<xsl:text>dc:type</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="value">
						<xsl:text>text/xml</xsl:text>
					</xsl:attribute>
				</xsl:element>
				<xsl:element name="meta">
					<xsl:attribute name="name">
						<xsl:text>dc:language</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="value">
						<xsl:apply-templates select="interlinear-text/paragraphs/paragraph[1]/phrases[1]/phrase[1]/item[@type = 'txt']/@lang"/>
					</xsl:attribute>
				</xsl:element>
				<!-- there are more potential meta elements, but not clear how to populate them-->
			</xsl:element>
			<xsl:element name="interlinear">
				<xsl:apply-templates select="interlinear-text/paragraphs/paragraph"/>
			</xsl:element>
		</eopas>
	</xsl:template>

	<xsl:template match="paragraph">
		<xsl:element name="phrase">
			<xsl:attribute name="id">
				<xsl:value-of select="phrases/phrase/@guid"/>
			</xsl:attribute>
			<xsl:attribute name="startTime">
				<xsl:value-of select="phrases/phrase/@begin-time-offset"/>
			</xsl:attribute>
			<xsl:attribute name="endTime">
				<xsl:value-of select="phrases/phrase/@end-time-offset"/>
			</xsl:attribute>
			<!-- This speaker attribute will have to be blocked if eopas can't handle it... though that will mean throwing away good info. -->
			<!--xsl:attribute name="speaker">
				<xsl:value-of select="phrases/phrase/@speaker"/>
			</xsl:attribute-->
			<xsl:element name="transcription">
				<xsl:value-of select="phrases/phrase/item[@type = 'txt']"/>
			</xsl:element>
			<xsl:element name="wordlist">
				<xsl:apply-templates select="phrases/phrase/words/word"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="word">
		<xsl:element name="word">
			<xsl:element name="text">
				<xsl:value-of select="item[@type = 'txt']"/>
			</xsl:element>
			<xsl:element name="morphemelist">
				<xsl:apply-templates select="morphemes/morph"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="morph">
		<xsl:element name="morpheme">
			<xsl:element name="text">
				<xsl:attribute name="kind">morpheme</xsl:attribute>
				<xsl:value-of select="item[@type = 'txt']"/>
			</xsl:element>
			<xsl:element name="text">
				<xsl:attribute name="kind">gloss</xsl:attribute>
				<xsl:value-of select="item[@type = 'gls']"/>
			</xsl:element>
			<!-- These next two will have to be blocked if eopas can't handle them... though that will mean throwing away morphological information. -->
			<!--xsl:element name="text">
				<xsl:attribute name="kind">cf</xsl:attribute>
				<xsl:value-of select="item[@type = 'cf']"/>
			</xsl:element>
			<xsl:element name="text">
				<xsl:attribute name="kind">msa</xsl:attribute>
				<xsl:value-of select="item[@type = 'msa']"/>
			</xsl:element-->
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>