<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx xs xsl"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="member" mode="returns">
    <xsl:if test="returns">
      <returnValue>
        <xsl:apply-templates select="returns/node()" mode="api-doc" />
      </returnValue>
    </xsl:if>
  </xsl:template>

  <xsl:template match="member" mode="exceptions">
    <xsl:comment>MEMBER EXCEPTIONS</xsl:comment>
    <xsl:if test="exception">
      <exceptions>
        <xsl:apply-templates select="exception" mode="api-doc" />
      </exceptions>
    </xsl:if>
  </xsl:template>

  <xsl:template match="exception" mode="api-doc">
    <exception>
      <xsl:call-template name="api-link">
        <xsl:with-param name="id" select="@cref" />
      </xsl:call-template>

      <content>
        <xsl:apply-templates mode="api-doc" />
      </content>
    </exception>
  </xsl:template>

  <xsl:template match="member" mode="remarks">
    <xsl:if test="remarks">
      <languageReferenceRemarks>
        <xsl:apply-templates select="remarks/node()" mode="api-doc" />
      </languageReferenceRemarks>
    </xsl:if>
  </xsl:template>

  <xsl:template match="member" mode="thread-safety">
    <xsl:if test="threadsafety">
      <threadSafety>
        <xsl:apply-templates select="threadsafety/node()" mode="api-doc" />
      </threadSafety>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node()|@*" mode="api-doc">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="api-doc"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="api-doc">
    <xsl:message>
      Unrecognised code-documentation element <xsl:value-of select="name()"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="api-doc"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="see[@cref]" mode="api-doc">
    <xsl:param name="current" tunnel="yes" />
    <xsl:choose>
      <xsl:when test="starts-with(@cref, 'Overloads.')">
        <!-- TODO: roll this into get-api-->
        <xsl:variable name="type-id" select="replace(@cref, 'Overloads\.(.+)\.', 'T:\1')" />
        <xsl:variable name="method-name" select="replace(@cref, '.+\.(.+)', '\1')" />
        <xsl:variable name="type-api" select="$apis/key('api-by-id', $type-id)" />
        <xsl:variable name="method-apis" select="for $api in $type-api/elements/element/@api return $api/key('api-by-id', @id)[apidata/@name = $method-name]" />
        <xsl:variable name="api" select="$method-apis[1]" />

        <!-- TODO: customize list of excempted namespaces-->

        <xsl:apply-templates select="$api" mode="api-link">
          <xsl:with-param name="id" select="@cref" />
          <xsl:with-param name="qualify-hint" select="not(($current/(@id,containers/*/@api),'N:System') =
                                                               $api/(@id,containers/*[last()]/@api))" />
          <xsl:with-param name="auto-upgrade" select="true()" />
        </xsl:apply-templates>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="api-link">
          <xsl:with-param name="id" select="@cref" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="see[@href]" mode="api-doc">
    <externalLink>
      <linkUri>
        <xsl:value-of select="@href"/>
      </linkUri>
      <linkText>
        <xsl:apply-templates mode="api-doc" />
      </linkText>
    </externalLink>
  </xsl:template>

  <xsl:template match="see[@langword]" mode="api-doc">
    <languageKeyword>
      <xsl:value-of select="@langword"/>
    </languageKeyword>
  </xsl:template>

  <xsl:template match="seealso[@cref]" mode="api-doc">
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@cref" />
      <xsl:with-param name="qualify-hint" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="seealso[@href]" mode="api-doc">
    <externalLink>
      <linkUri>
        <xsl:value-of select="@href"/>
      </linkUri>
      <linkText>
        <xsl:apply-templates mode="api-doc" />
      </linkText>
    </externalLink>
  </xsl:template>

  <xsl:template match="para[@class='warning']" mode="api-doc">
    <alert class="warning">
      <xsl:apply-templates select="node()|@*" mode="api-doc" />
    </alert>
  </xsl:template>

  <xsl:template match="para[@class='note']" mode="api-doc">
    <alert class="note">
      <xsl:apply-templates select="node()|@*" mode="api-doc" />
    </alert>
  </xsl:template>

  <xsl:template match="para" mode="api-doc">
    <para>
      <xsl:apply-templates select="node()|@*" mode="api-doc" />
    </para>
  </xsl:template>

  <xsl:template match="c" mode="api-doc">
    <codeInline>
      <xsl:apply-templates select="node()|@*" mode="api-doc" />
    </codeInline>
  </xsl:template>

  <xsl:template match="paramref" mode="api-doc">
    <parameterReference>
      <xsl:value-of select="@name" />
    </parameterReference>
  </xsl:template>

  <xsl:template match="list[@type='bullet']" mode="api-doc">
    <list class="bullet">
      <xsl:apply-templates mode="list" />
    </list>
  </xsl:template>

  <xsl:template match="list[@type='number']" mode="api-doc">
    <list class="ordered">
      <xsl:apply-templates mode="list" />
    </list>
  </xsl:template>

  <xsl:template match="list[@type='table']" mode="api-doc">
    <table>
      <xsl:apply-templates select="node()" mode="table" />
    </table>
  </xsl:template>

  <xsl:template match="list" mode="api-doc">
    <xsl:message>Unrecognised list type</xsl:message>
    <list class="bullet">
      <xsl:apply-templates mode="list" />
    </list>
  </xsl:template>

  <xsl:template match="item[definition]" mode="list">
    <listItem>
      <xsl:apply-templates select="definition/node()" mode="api-doc"/>
    </listItem>
  </xsl:template>

  <xsl:template match="item" mode="list">
    <!--xsl:message>list item is missing definition</xsl:message-->
    <listItem>
      <xsl:apply-templates mode="api-doc" />
    </listItem>
  </xsl:template>

  <xsl:template match="listheader" mode="table">
    <tableHeader>
      <row>
        <entry>
          <xsl:apply-templates select="term/node()" mode="api-doc"/>
        </entry>
        <entry>
          <xsl:apply-templates select="description/node()" mode="api-doc" />
        </entry>
      </row>
    </tableHeader>
  </xsl:template>

  <xsl:template match="item" mode="table">
    <row>
      <entry>
        <xsl:apply-templates select="term/node()" mode="api-doc" />
      </entry>
      <entry>
        <xsl:apply-templates select="description/node()" mode="api-doc" />
      </entry>
    </row>
  </xsl:template>

  <xsl:template match="typeparamref" mode="api-doc">
    <parameterReference cdx:type-param="true">
      <xsl:value-of select="@name" />
    </parameterReference>
  </xsl:template>

  <xsl:template match="c" mode="api-doc">
    <codeInline>
      <xsl:value-of select="node()|@*" />
    </codeInline>
  </xsl:template>

  <xsl:template match="code" mode="api-doc">
    <code>
      <xsl:value-of select="node()"/>
    </code>
  </xsl:template>

  <xsl:template match="example" mode="api-doc">
    <section>
      <title>Example</title>
      <content>
        <xsl:apply-templates mode="api-doc" />
      </content>
    </section>
  </xsl:template>

  <!-- custom extension -->
  <xsl:template match="section" mode="api-doc">
    <section>
      <title>
        <xsl:value-of select="@title"/>
      </title>
      <content>
        <xsl:apply-templates mode="api-doc" />
      </content>
    </section>
  </xsl:template>

  <xsl:template match="list[@type='nobullet']" mode="api-doc">
    <list class="nobullet">
      <xsl:apply-templates mode="list" />
    </list>
  </xsl:template>

</xsl:stylesheet>
