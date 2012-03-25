<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
		            exclude-result-prefixes="xs"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:cdx="http://www.codexdocs.com/">

  <xsl:import href="api.xsl" />
  
  <xsl:template match="node()|@*" mode="maml">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="maml"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="topic" mode="maml">
    <xsl:apply-templates mode="maml" />
  </xsl:template>
  
  <xsl:template match="maml:codeEntityReference" mode="maml">
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="data(.)" />
      <xsl:with-param name="qualify-hint" select="(@qualifyHint, false())[1]" />
      <xsl:with-param name="auto-upgrade" select="(@autoUpgrade, false())[1]" />
			<xsl:with-param name="target-version" select="@cdx:version"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
