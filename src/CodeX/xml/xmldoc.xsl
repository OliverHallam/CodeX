<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:local="http://www.w3.org/local"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xs local">

	<xsl:variable name="mref" select="collection('urn:mref')" />

	<xsl:key name="api-by-id"
	         match="api"
	         use="@id" />

	<xsl:output method="xml" indent="yes"/>

	<xsl:function name="local:visible" as="xs:boolean">
		<xsl:param name="api-name" as="xs:string" />
		<xsl:sequence select="exists($mref/key('api-by-id', $api-name))" />
	</xsl:function>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="member">
		<xsl:if test="local:visible(@name)">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*" />
			</xsl:copy>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
