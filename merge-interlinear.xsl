<?xml version="1.0" encoding="UTF-8"?>

<!-- merge-interlinear.xsl
This takes a flextext transcription file (usually the result of an export from ELAN), and combines it with the interlinear morphological analysis of the same transcript, produced in Flex. This is necessary because not all ELAN tiers survive the import-interlinearise-export journey through Flex. Custom tiers are simply removed by Flex. So we recombine Flex's morphological analysis with the origianl flextxt file exported from ELAN.-->

<!-- USAGE EXAMPLES:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t Magultje-test.flextext merge-interlinear.xsl interlin=Magultje-test.postFlex.flextext >output.xml

java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t Magultje-test.flextext merge-interlinear.xsl interlin=Magultje-test.postFlex.flextext >output.xml 

or

[from /scripts ... this is slightly easier]
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t ../translations/2014-10-01_Serina-Dulla_NAATI/_ merge-interlinear.xsl interlin=../translations/2014-10-01_Serina-Dulla_NAATI/_  >../translations/2014-10-01_Serina-Dulla_NAATI/_ 

*** NB the interlin file path is relative to the location of the XSL script

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exslt="http://exslt.org/common">

	<!--xsl:output indent="no" media-type="xml"/-->
	<xsl:output indent="yes" media-type="xml"/>

	<xsl:preserve-space elements="*"/>
	
	<!-- Do nothing with these elements -->
	<xsl:template match="item[@type = 'hn' or @type = 'variantTypes']"/>
	<xsl:template match="morph/@type"/>


	<!-- command line parameter for giving the name of the interlinearised file  -->
	<xsl:param name="interlin"/>

	<!-- And maybe let's add a parameter to say whether you want to overwrite previous transcript/translation tiers (default value set to "yes"). Because sometimes the interlin process will lead to editing of these. -->
	<xsl:param name="overwrite" select="yes"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- This merges in the interlinear content: word elements and their dependent nodes -->
	<xsl:template match="phrase">
		<!--xsl:text>HELLO</xsl:text-->
		<xsl:variable name="id" select="@guid"></xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:apply-templates select="document($interlin)//phrase[@guid = $id]/words"/>
		</xsl:copy>
	</xsl:template>


	<!-- this is to overwrite the original translation annotation-->
	<xsl:template match="phrase/item[@type = 'gls']">
		<xsl:variable name="id" select="parent::phrase/@guid"></xsl:variable>
		<xsl:choose>
			<xsl:when test="$overwrite = 'no'">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:value-of select="document($interlin)//phrase[@guid = $id]/item[@type = 'gls']"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- this is to overwrite the original transcript annotation, by joining together flex's "word" elements-->
	<xsl:template match="phrase/item[@type = 'txt']">
		<xsl:variable name="id" select="parent::phrase/@guid"></xsl:variable>
		<xsl:choose>
			<xsl:when test="$overwrite = 'no'">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:value-of select="string-join(document($interlin)//phrase[@guid = $id]/words/word/item[@type = 'txt' or @type = 'punct'], ' ')"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Flex's glsAppend does not automatically get appended! need to do it here -->
	<xsl:template match="morph/item[@type = 'gls']">
		<xsl:choose>
			<xsl:when test="following-sibling::item[@type = 'glsAppend']">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:value-of select="concat(node(), following-sibling::item[@type = 'glsAppend'])"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- And don't do anything when you get to the glsAppend -->
	<xsl:template match="morph/item[@type = 'glsAppend']"></xsl:template>

	<!-- Flex produces "punctuation" elements ?every time? it finds a punctuation mark in an annotation. In some cases they seem to be output with the following phrase, not the one they were marked in. Maybe will have to just destroy them, but for next export I will try to save them in the correct position.>
	<xsl:template match="phrase/item[@type = 'punct']"/-->
	
</xsl:stylesheet>