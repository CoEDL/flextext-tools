<?xml version="1.0" encoding="UTF-8"?>

<!-- SAXON java usage:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exslt="http://exslt.org/common">

	<!--XML formatting controls-->
	<xsl:output indent="yes" media-type="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:variable name="wavSrc" select="substring-before(descendant::aud[1], ' ')"/>

	<!-- A parameter to say whether you want to include the morphological analysis (default value set to "morphs"). If you don't want them, add parameter "nomorphs", or in fact anything else you add will stop them from being copied. -->
	<!--xsl:param name="morphology" select="morphs"/-->

	<!--Source document root, in examples seen so far is an empty wrapper for idGroup-->
	<xsl:template match="database">
		<xsl:apply-templates select="idGroup"/>
	</xsl:template>

	<!--Output document root-->
	<xsl:template match="idGroup">
		<xsl:element name="document">
			<xsl:element name="interlinear-text">
				<xsl:element name="paragraphs">
					<xsl:apply-templates select="refGroup"/>
				</xsl:element>
				<xsl:element name="media-files">
					<xsl:element name="media">
						<xsl:attribute name="location">
							<xsl:value-of select="$wavSrc"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Phrase-level element -->
	<xsl:template match="refGroup">
		<xsl:element name="paragraph">
			<xsl:element name="phrases">
				<xsl:element name="phrase">
					<xsl:attribute name="begin-time-offset">
						<xsl:value-of select="substring-before(substring-after(following-sibling::aud[1], ' '), ' ')"/>
					</xsl:attribute>
					<xsl:attribute name="end-time-offset">
						<xsl:value-of select="substring-after(substring-after(following-sibling::aud[1], ' '), ' ')"/>
					</xsl:attribute>
					<xsl:attribute name="speaker">unknown</xsl:attribute>
					<xsl:element name="item">
						<xsl:attribute name="lang">mwf</xsl:attribute>
						<xsl:attribute name="type">txt</xsl:attribute>
						<xsl:value-of select="string-join(txGroup/tx, ' ')"/>
					</xsl:element>
					<xsl:element name="item">
						<xsl:attribute name="lang">en</xsl:attribute>
						<xsl:attribute name="type">gls</xsl:attribute>
						<xsl:value-of select="ftGroup"/>
					</xsl:element>
					<!-- For the first phrase, insert session note as a comment if present -->
					<xsl:if test="position()=1">
						<xsl:element name="item">
							<xsl:attribute name="lang">en</xsl:attribute>
							<xsl:attribute name="type">comment</xsl:attribute>
							<xsl:value-of select="parent::idGroup/nt"/>
					</xsl:element>
					</xsl:if>
					<xsl:element name="words">
						<xsl:apply-templates select="txGroup"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Word-level element -->
	<xsl:template match="txGroup">
		<xsl:element name="word">
			<xsl:element name="item">
				<xsl:attribute name="lang">mwf</xsl:attribute>
				<xsl:attribute name="type">txt</xsl:attribute>
				<xsl:value-of select="tx"/>
			</xsl:element>
			<!--xsl:if test="$morphology = 'morphs'"-->
				<xsl:element name="morphemes">
					<xsl:for-each select="mb">
						<xsl:variable name="counter" select="position()"/>
								<xsl:element name="morph">
									<xsl:element name="item">
										<xsl:attribute name="lang">mwf</xsl:attribute>
										<xsl:attribute name="type">cf</xsl:attribute>
										<xsl:value-of select="."/>
									</xsl:element>
									<xsl:element name="item">
										<xsl:attribute name="lang">en</xsl:attribute>
										<xsl:attribute name="type">gls</xsl:attribute>
										<xsl:value-of select="parent::txGroup/ge[$counter]"/>
									</xsl:element>
									<xsl:element name="item">
										<xsl:attribute name="lang">en</xsl:attribute>
										<xsl:attribute name="type">msa</xsl:attribute>
										<xsl:value-of select="parent::txGroup/ps[$counter]"/>
									</xsl:element>
								</xsl:element>
					</xsl:for-each>
				</xsl:element>
			<!--/xsl:if-->
		</xsl:element>
	</xsl:template>

	<!-- By default just copy elements -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>