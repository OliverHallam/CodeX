<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="maml cdx xlink xs xsl"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cdx="http://www.codex-docs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="languages.xsl" />
  
  <xsl:key name="topics-by-id" match="cdx:topic" use="@id"/>
  
  <xsl:function name="cdx:lookup-topic" as="node()">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="version" as="xs:string?" />
    <xsl:param name="topic" as="node()" />
    
    <xsl:variable name="resolved-version" select="if (exists($version)) then $version else xs:string($topic/(ancestor-or-self::cdx:product[1]/@version))[1]" />
    
    <xsl:variable name="resolved-topic" select="key('topics-by-id', $id, root($topic))[deep-equal($resolved-version, xs:string(ancestor-or-self::cdx:product[1]/@version))]" />
    
    <xsl:if test="empty($resolved-topic)">
      <xsl:message terminate="yes">Error resolving link to version <xsl:value-of select="$resolved-version" /> of <xsl:value-of select="$id" />.  No topic found.</xsl:message>
    </xsl:if>
    
    <xsl:if test="count($resolved-topic) gt 1">
      <xsl:message terminate="yes">Error resolving link to version <xsl:value-of select="$resolved-version" /> of <xsl:value-of select="$id" />.  Multiple topics found.</xsl:message>
    </xsl:if>
    
    <xsl:sequence select="$resolved-topic" />
  </xsl:function>
  
  <xsl:output
    media-type="text/html"
    method="xhtml"
    encoding = "utf-8"
    omit-xml-declaration = "yes"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    indent="no" />
  
  <xsl:function name="cdx:language-class" as="xs:string?">
    <xsl:param name="language" />
    <xsl:choose>
      <xsl:when test="$language = 'C#'">
        <xsl:text>cs</xsl:text>
      </xsl:when>
      <xsl:when test="$language = 'VB.NET'">
        <xsl:text>vb</xsl:text>
      </xsl:when>
      <xsl:when test="$language = 'C++'">
        <xsl:text>cpp</xsl:text>
      </xsl:when>
      <xsl:when test="$language = 'F#'">
        <xsl:text>fs</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Language <xsl:value-of select="$language" /> not supported.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="cdx:is-member" as="xs:boolean">
    <xsl:param name="category" />
    
    <xsl:value-of select="$category='constructor' or 
                          $category='event' or 
                          $category='field' or 
                          $category='method' or 
                          $category='operator' or 
                          $category='property' or
                          $category='member'" />
  </xsl:function>
  
  <xsl:template match="cdx:topic" mode="page-title">
    <xsl:apply-templates select="." mode="name">
      <xsl:with-param name="qualify-hint" select="@api-name and cdx:is-member(@api-category)" />
      <xsl:with-param name="title" select="true()" />
      <xsl:with-param name="lang" select="'default'" tunnel="yes" />
    </xsl:apply-templates>
    <xsl:variable name="namespace" select="ancestor::cdx:topic[@api-category='namespace'][1]/@api-name" />
    <xsl:if test="$namespace">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$namespace" />
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="styles">
    <link rel="stylesheet" type="text/css" href="style/doc.css" />
  </xsl:template>
  
  <xsl:template name="scripts">
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" />
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js" type="text/javascript" />
    <script type="text/javascript" src="http://jqueryui.com/external/jquery.cookie.js"></script>
    <script src="script/doc.js" type="text/javascript" />
  </xsl:template>
  
  <xsl:template name="head">
    <xsl:param name="topic" tunnel="yes" />
    
    <title>
      <xsl:apply-templates select="$topic" mode="page-title" />
    </title>
    
    <xsl:call-template name="styles" />
    <xsl:call-template name="scripts" />
  </xsl:template>
  
  <xsl:template name="body">
    <xsl:param name="topic" tunnel="yes" />
    
    <div id="navigation">
      <div id="navigation-content">
        <xsl:apply-templates select="$topic" mode="navigation" />
      </div>
    </div>
    <div id="topic">
      <div id="topic-content">
        <h1>
          <xsl:apply-templates select="$topic" mode="name-all-languages">
            <xsl:with-param name="qualify-hint" select="$topic/@api-name and cdx:is-member($topic/@api-category)" />
            <xsl:with-param name="title" select="true()" />
          </xsl:apply-templates>
        </h1>
        <xsl:apply-templates select="$topic" mode="versions" />
        <xsl:apply-templates mode="content" />
      </div>
    </div>
    <xsl:call-template name="footer" />
  </xsl:template>
  
  <xsl:template match="/">
    <html>
      <head>
        <xsl:call-template name="head" />
      </head>
      <body>
        <xsl:call-template name="body" />
      </body>
    </html>
  </xsl:template>

  <xsl:template name="footer">
    <div id="footer">Documentation generated by <a href="http://www.xqsharp.com">XQSharp</a>.</div>
  </xsl:template>
  
  <!-- topic pages -->
  <xsl:template match="topic" mode="content">
    <xsl:apply-templates mode="content" />
  </xsl:template>

  <xsl:template match="maml:developerConceptualDocument |
                       maml:developerErrorMessageDocument |
                       maml:developerGlossaryDocument |
                       maml:developerOrientationDocument |
                       maml:developerSDKTechnologyOverviewArchitectureDocument |
                       maml:developerSDKTechnologyOverviewCodeDirectoryDocument |
                       maml:developerSDKTechnologyOverviewOrientationDocument |
                       maml:developerSDKTechnologyOverviewScenariosDocument |
                       maml:developerSDKTechnologyOverviewTechnologySummaryDocument |
                       maml:developerTroubleshootingDocument |
                       maml:developerUIReferenceDocument |
                       maml:developerWalkthroughDocument |
                       maml:developerWhitePaperDocument |
                       maml:developerReferenceWithoutSyntaxDocument |
                       maml:developerReferenceWithSyntaxDocument"
                mode="content">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="maml:codeEntityDocument">
    <xsl:message terminate="yes">maml:codeEntityDocument is not supported.</xsl:message>
  </xsl:template>

  <!-- SECTIONS -->
  <xsl:template match="maml:sections">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="maml:section">
    <div class="section">
      <xsl:apply-templates select="@* | node()" />
    </div>
  </xsl:template>

  <xsl:template match="maml:section[@cdx:class='members']">
    <div class="section">
      <xsl:apply-templates select="@* | node()" />
      <p>
        <a href="#">Top</a>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="maml:sectionSimple">
    <div class="section">
      <xsl:apply-templates select="@* | node()" />
    </div>
  </xsl:template>

  <xsl:template match="maml:summary">
    <div class="summary">
      <xsl:apply-templates select="@*|node()" />
    </div>
  </xsl:template>

  <xsl:template match="maml:introduction">
    <div class="introduction">
      <xsl:apply-templates select="@*|node()" />
    </div>
  </xsl:template>

  <xsl:template match="maml:title">
    <!-- TODO: should depth be a tunnel param, to include named sections too? -->
    <xsl:variable name="depth"
                  select="count(ancestor::maml:section)" />
    <xsl:variable name="h"
		  select="min(($depth+1, 6))" />
    <xsl:element name="h{$h}"
                 namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>


  <xsl:template match="maml:content">
    <div>
      <xsl:apply-templates select="@*|node()" />
    </div>
  </xsl:template>

  <!-- related topics -->
  <xsl:template match="maml:relatedTopics" />

  <xsl:template match="maml:relatedTopics[*]">
    <div id="related-topics" class="section">
      <xsl:apply-templates select="@*" />

      <h2>See Also</h2>
      <xsl:if test="maml:codeEntityReference|maml:link">
        <div>
          <h3>Reference</h3>
          <ul class="nobullet">
            <xsl:for-each select="maml:codeEntityReference">
              <li>
                <xsl:apply-templates select="." />
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:if>

      <xsl:if test="cdx:externalCodeEntityReference|maml:externalLink">
        <div>
          <h3>Other Resources</h3>
          <ul class="nobullet">
            <xsl:for-each select="cdx:externalCodeEntityReference|maml:externalLink">
              <li>
                <xsl:apply-templates select="." />
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- remarks -->
  <xsl:template match="maml:languageReferenceRemarks" >
    <div id="remarks" class="section">
      <xsl:apply-templates select="@*" />

      <h2>Remarks</h2>
      <xsl:apply-templates select="node()" />
    </div>
  </xsl:template>

  <!-- parameters -->
  <xsl:template match="maml:parameters">
    <div id="parameters" class="section">
      <xsl:apply-templates select="@*" />

      <h3>Parameters</h3>

      <dl class="parameters">
        <xsl:apply-templates select="node()" />
      </dl>
    </div>
  </xsl:template>

  <xsl:template match="maml:parameter">
    <dt>
      <xsl:apply-templates select="maml:parameterReference" />
    </dt>
    <dd>
      <xsl:apply-templates select="maml:content/node()" />
    </dd>
  </xsl:template>
  
  <xsl:template match="maml:genericParameters">
    <div id="type-parameters" class="section">
      <xsl:apply-templates select="@*" />

      <h3>Type Parameters</h3>

      <dl class="parameters">
        <xsl:apply-templates select="node()" />
      </dl>
    </div>
  </xsl:template>

  <xsl:template match="maml:genericParameter">
    <dt>
      <span class="typeParameterReference">
        <xsl:apply-templates select="maml:parameterReference/node()" />
      </span>
    </dt>
    <dd>
      <xsl:apply-templates select="maml:content/node()" />
    </dd>
  </xsl:template>
  
  <!-- return value -->
  <xsl:template match="maml:returnValue">
    <div id="returnValue" class="section">
      <h3>
        <xsl:apply-templates select="maml:title/node()" />
      </h3>
      <xsl:apply-templates select="maml:content/node()" />
    </div>
  </xsl:template>

  <!-- syntax -->
  <xsl:template match="maml:syntax">
    <div id="syntax">
      <xsl:apply-templates select="@*|node()" />
    </div>
  </xsl:template>

  <xsl:template match="maml:syntax//maml:content">
		<xsl:if test="count(maml:code) > 1">
			<ul class="tabs">
				<li id="vbtab">
					<a href="javascript:setLanguage('vb');">VB</a>
				</li>
				<li id="cstab" class="active">
					<a href="javascript:setLanguage('cs');">C#</a>
				</li>
				<li id="cpptab">
					<a href="javascript:setLanguage('cpp');">C++</a>
				</li>
			</ul>
		</xsl:if>
    <div class="syntax">
      <xsl:apply-templates select="maml:code" mode="syntax" />
    </div>
  </xsl:template>

  <xsl:template match="maml:code" mode="syntax">
		<xsl:variable name="lang-class" select="cdx:language-class(@language)"/>
		
    <div>
			<xsl:if test="exists($lang-class)">
				<xsl:attribute name="class">
					<xsl:value-of select="$lang-class" />
				</xsl:attribute>
			</xsl:if>
      <div class="code">
        <pre>
          <xsl:apply-templates select="node()">
            <xsl:with-param name="lang" as="xs:string?" tunnel="yes" select="cdx:language-class(@language)" />
          </xsl:apply-templates>
        </pre>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="maml:syntax//maml:languageKeyword">
    <span class="keyword">
      <xsl:apply-templates select="node()|@*" />
    </span>
  </xsl:template>
  
  <xsl:template match="maml:exceptions">
    <div id="exceptions" class="section">
      <h3>Exceptions</h3>
      <table>
        <thead>
          <tr>
            <td>Exception</td>
            <td>Condition</td>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="maml:exception">
            <tr>
              <td><xsl:apply-templates select="@*|*[1]" /></td>
              <td><xsl:apply-templates select="maml:content/(@*|node())" /></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- BLOCK LEVEL ELEMENTS -->

  <!-- alert block -->
  <xsl:template match="maml:alert">
    <div class="alert">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="." mode="alert-title"/>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="maml:alert" mode="alert-title">
    <div class="note-title">Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='note']" mode="alert-title">
    <div class="note-title">Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='tip']" mode="alert-title">
    <div class="note-title">Tip</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='implement']" mode="alert-title">
    <div class="note-title">Note for Implementors</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='caller']" mode="alert-title">
    <div class="note-title">Note for Callers</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='inherit']" mode="alert-title">
    <div class="note-title">Note for Inheritors</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='caution']" mode="alert-title">
    <div class="caution-title">Caution</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='warning']" mode="alert-title">
    <div class="caution-title">Warning</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='important']" mode="alert-title">
    <div class="caution-title">Important</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='security'] |
                       maml:alert[@class='security note']"
                mode="alert-title">
    <div class="security-title">Security Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='cs'] |
                       maml:alert[@class='CSharp'] |
                       maml:alert[@class='c#'] |
                       maml:alert[@class='C#'] |
                       maml:alert[@class='visual c# note']"
                mode="alert-title">
    <div class="language-title">C# Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='fs'] |
                       maml:alert[@class='FSharp'] |
                       maml:alert[@class='f#'] |
                       maml:alert[@class='F#'] |
                       maml:alert[@class='visual f# note']"
                mode="alert-title">
    <div class="language-title">F# Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='cpp'] |
                       maml:alert[@class='CPP'] |
                       maml:alert[@class='c++'] |
                       maml:alert[@class='C++'] |
                       maml:alert[@class='visual c++ note']"
                mode="alert-title">
    <div class="language-title">C++ Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='vb'] |
                       maml:alert[@class='VB'] |
                       maml:alert[@class='VisualBasic'] |
                       maml:alert[@class='visual basic note']"
                mode="alert-title">
    <div class="language-title">Visual Basic Note</div>
  </xsl:template>

  <xsl:template match="maml:alert[@class='JSharp'] |
                       maml:alert[@class='j#'] |
                       maml:alert[@class='J#'] |
                       maml:alert[@class='visual j# note']"
                mode="alert-title">
    <div class="language-title">J# Note</div>
  </xsl:template>

  <!-- code block-->
  <xsl:template match="maml:code">
    <div class="code">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="." mode="code-title"/>
      <pre>
        <xsl:apply-templates />
      </pre>
    </div>
  </xsl:template>

  <xsl:template match="maml:code" mode="code-title" />

  <xsl:template match="maml:code[@class]" priority="10" mode="code-title">
    <xsl:message>Unrecognised code language '<xsl:value-of select="@class"/>'</xsl:message>
  </xsl:template>

  <xsl:template match="maml:code[@class='cpp'] |
                       maml:code[@class='cpp#']"
                mode="code-title">
    <div class="code-title">C++</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='vb'] |
                       maml:code[@class='vb#'] |
                       maml:code[@class='VB.NET']"
                mode="alert-title">
    <div class="code-title">Visual Basic</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='C#'] |
                       maml:code[@class='c#']"
                mode="code-title">
    <div class="code-title">C#</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='vb/c#']"
                mode="code-title">
    <div class="code-title">Visual Basic/C#</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='vbs']" mode="code-title">
    <div class="code-title">VBScript</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='js']" mode="code-title">
    <div class="code-title">Javascript</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='jscript'] |
                       maml:code[@class='jscript#']">
    <div class="code-title">JScript</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='xml']" mode="code-title">
    <div class="code-title">XML</div>
  </xsl:template>

  <xsl:template match="maml:code[@class='html']" mode="code-title">
    <div class="code-title">HTML</div>
  </xsl:template>

  <!-- code reference -->
  <xsl:template match="maml:codeReference">
    <xsl:message terminate="yes">maml:codeReference elements are not supported.</xsl:message>
  </xsl:template>

  <!-- definition tables -->
  <xsl:template match="maml:definitionTable">
    <dl>
      <xsl:apply-templates select="@*|node()" />
    </dl>
  </xsl:template>

  <xsl:template match="maml:definedTerm">
    <dt>
      <xsl:apply-templates select="@*|node()" />
    </dt>
  </xsl:template>

  <xsl:template match="maml:definition">
    <dd>
      <xsl:apply-templates select="@*|node()" />
    </dd>
  </xsl:template>

  <!-- containers table -->
  <xsl:template match="maml:definitionTable[@cdx:class='containers']">
    <ul class="containers">
      <xsl:apply-templates select="@*" />
      <xsl:for-each select="maml:definedTerm">
        <li>
          <xsl:apply-templates select="@*" />
          <strong><xsl:apply-templates select="node()"/>:</strong>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="following-sibling::*[1]/self::maml:definition/node()" />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- lists -->
  <xsl:template match="maml:list[@class='bullet']">
    <ul>
      <xsl:apply-templates select="@*|node()" />
    </ul>
  </xsl:template>

  <xsl:template match="maml:list[@class='ordered']">
    <ol>
      <xsl:apply-templates select="@*|node()" />
    </ol>
  </xsl:template>

  <xsl:template match="maml:list[@class='nobullet']">
    <ul class="nobullet">
      <xsl:apply-templates select="@*|node()" />
    </ul>
  </xsl:template>

  <xsl:template match="maml:list">
    <xsl:message>Unrecognised list class '<xsl:value-of select="@class"/>'</xsl:message>
    <ul class="nobullet">
      <xsl:apply-templates select="@*|node()" />
    </ul>
  </xsl:template>

  <xsl:template match="maml:listItem">
    <li>
      <xsl:apply-templates select="@*|node()"/>
    </li>
  </xsl:template>

  <!-- inheritance hierarchy -->
  <xsl:template match="maml:list[@cdx:class='inheritance']">
    <ul class="inheritance">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="node()" mode="inheritence-list"/>
    </ul>
  </xsl:template>

  <xsl:template match="maml:listItem" mode="inheritence-list">
    <li style="margin-left: {count(preceding-sibling::maml:listItem[not(@cdx:class='child')])}em">
      <xsl:apply-templates select="@*|node()" />
    </li>
  </xsl:template>

  <!-- paragraphs -->
  <xsl:template match="maml:para">
    <p>
      <xsl:if test="@cdx:class = 'parameterType'">
        <xsl:attribute name="class">
          <xsl:text>parameter-type</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@* | node()" />
    </p>
  </xsl:template>

  <!-- quotes -->
  <xsl:template match="maml:quote">
    <blockquote>
      <xsl:apply-templates select="@*|node()" />
    </blockquote>
  </xsl:template>

  <!-- tables -->
  <xsl:template match="maml:table">
    <div class="table">
      <xsl:apply-templates select="@* | maml:title" />
      <table>
        <xsl:apply-templates select="maml:tableHeader" />
        <tbody>
          <xsl:apply-templates select="maml:row" />
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="maml:tableHeader">
    <thead>
      <xsl:apply-templates select="@* | maml:row" />
    </thead>
  </xsl:template>

  <xsl:template match="maml:row">
    <tr>
      <xsl:apply-templates select="@* | maml:entry" />
    </tr>
  </xsl:template>

  <xsl:template match="maml:entry">
    <td>
      <xsl:apply-templates select="@* | node()" />
    </td>
  </xsl:template>

  <xsl:template match="maml:tableHeader//maml:entry">
    <th>
      <xsl:apply-templates select="@* | node()" />
    </th>
  </xsl:template>

  <!-- member table -->
  <xsl:template match="maml:table[@cdx:class='members']">
    <div class="members">
      <xsl:apply-templates select="@* | maml:title" />
      <table>
        <xsl:apply-templates select="maml:tableHeader" />
        <tbody>
          <xsl:apply-templates select="maml:row" />
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="maml:table[@cdx:class='members']/maml:tableHeader/maml:row">
    <tr>
      <xsl:apply-templates select="@*" />
      <th class="icon-column">&#160;</th>
      <th class="name-column">
        <xsl:apply-templates select="maml:entry[1]/node()" />
      </th>
      <th class="description-column">
        <xsl:apply-templates select="maml:entry[2]/node()" />
      </th>
      <xsl:apply-templates select="maml:entry[position() > 2]" />
    </tr>
  </xsl:template>

  <xsl:template match="maml:table[@cdx:class='members']/maml:row">
    <tr>
      <xsl:apply-templates select="@*" />
      <td>
        <xsl:apply-templates select="." mode="member-icons" />
      </td>
      <td>
        <xsl:apply-templates select="maml:entry[1]/node()" />
      </td>
      <td>
        <xsl:apply-templates select="maml:entry[2]/node()" />
      </td>
      <xsl:apply-templates select="maml:entry[position() > 2]" />
    </tr>
  </xsl:template>

	<xsl:template match="maml:row" mode="member-icons">
		<xsl:param name="explicit" select="@cdx:explicit" />
	  <xsl:variable name="visibility" select="@cdx:visibility" />
    <xsl:variable name="category" select="../@cdx:category" />
    <xsl:variable name="subgroup" select="@cdx:subgroup" />
    <xsl:variable name="static" select="@cdx:static" />

    <xsl:variable name="visibility-name">
      <xsl:choose>
        <xsl:when test="$visibility = 'public'">Public</xsl:when>
        <xsl:when test="$visibility = 'private'">Private</xsl:when>
        <xsl:when test="$visibility = 'family'">Protected</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="abbr">
      <xsl:choose>
        <xsl:when test="$visibility = 'public'">pub</xsl:when>
        <xsl:when test="$visibility = 'private'">priv</xsl:when>
        <xsl:when test="$visibility = 'family'">prot</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$category='explicit'">
      <img title="Explicit interface implementation"
           src="icons/pubinterface.gif"
           alt="Explicit interface implementation"
           class="icon"/>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="$category = 'member'">
        <img title="Member"
             src="icons/enummember.gif"
             alt="Member"
             class="icon"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="subgroup" select="if ($subgroup='constructor') then 'method' else $subgroup" />

        <img title="{$visibility-name} {$subgroup}"
             src="icons/{$abbr}{$subgroup}.gif"
             alt="{$visibility-name} {$subgroup}"
             class="icon"/>

        <xsl:if test="$static = 'true'">
          <img title="Static member"
               alt="static"
               src="icons/static.gif"
               class="icon"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <!-- inline elements -->
  <xsl:template match="maml:application">
    <span class="application">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:codeInline">
    <code class="codeInline">
      <xsl:apply-templates />
    </code>
  </xsl:template>

  <xsl:template match="maml:languageKeyword">
    <xsl:variable name="current" select="." />
    <xsl:apply-templates select="$current" mode="apply-all-languages" />
  </xsl:template>

  <xsl:template match="maml:command">
    <span class="command">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:computerOutputInline">
    <span class="computerOutputInline">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:database">
    <span class="database">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:environmentVariable">
    <span class="environmentVariable">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:errorInline">
    <span class="errorInline">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:fictitiousUri">
    <span class="fictitiousUri">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:foreignPhrase">
    <span class="foreignPhrase">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:hardware">
    <span class="hardware">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:legacyBold">
    <b>
      <xsl:apply-templates />
    </b>
  </xsl:template>

  <xsl:template match="maml:legacyItalic">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="maml:legacyUnderline">
    <u>
      <xsl:apply-templates />
    </u>
  </xsl:template>

  <xsl:template match="maml:literal">
    <span class="literal">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:localUri">
    <span class="localUri">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:markup">
    <xsl:copy-of select="node()" />
  </xsl:template>

  <xsl:template match="maml:math">
    <span class="math">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:newTerm">
    <span class="newTerm">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:phrase">
    <span class="phrase">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:placeholder">
    <span class="placeholder">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:quoteInline">
    <span class="quoteInline">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:replaceable">
    <span class="replaceable">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:subscript">
    <sub>
      <xsl:apply-templates />
    </sub>
  </xsl:template>

  <xsl:template match="maml:superscript">
    <sup>
      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <xsl:template match="maml:system">
    <span class="system">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:ui">
    <span class="ui">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:unmanagedCodeEntityReference">
    <span class="unmanagedCodeEntityReference">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:parameterReference">
    <span class="parameterReference">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:parameterReference[@type-parameter='true']">
    <span class="typeParameterReference">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="maml:userInput">
    <span class="userInput">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="cdx:languageToken">
    <span class="{cdx:language-class(@language)}">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- media -->
  <xsl:template match="maml:mediaLink">
    <xsl:message>maml:mediaLink not supported</xsl:message>
  </xsl:template>

  <xsl:template match="maml:mediaLinkInline">
    <xsl:message>maml:mediaLinkInline not supported</xsl:message>
  </xsl:template>

  <!-- links -->
  <xsl:template match="maml:codeEntityReference|cdx:externalCodeEntityReference">
    <!-- TODO: autoUpgrade -->
    
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="exists($lang)">
        <xsl:apply-templates select="." mode="generate-link">
          <xsl:with-param name="lang-class" select="false()" />
        </xsl:apply-templates>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:variable name="current" select="." />
        <xsl:for-each select="$languages">
          <xsl:apply-templates select="$current" mode="generate-link">
            <xsl:with-param name="lang" select="." tunnel="yes" />
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="maml:codeEntityReference" mode="generate-link">
    <xsl:param name="lang" as="xs:string()?" tunnel="yes" />
    <xsl:param name="lang-class" as="xs:boolean" select="true()" />
    
    <xsl:param name="topic" tunnel="yes" />

    <!-- the topics represented by this page -->
    <xsl:variable name="topics" select="$topic|$topic/cdx:topic[@fragment]" />
    <xsl:variable name="id" select="data(.)" />
    <xsl:variable name="auto-upgrade" select="@autoUpgrade = 'true'" />
    
    <xsl:choose>
      <xsl:when test="$id = $topics/@id and not($auto-upgrade)">
        <span class="self-link{if ($lang-class) then concat(' ', $lang) else ()}">
          <xsl:choose>
            <xsl:when test="@cdx:text">
              <xsl:value-of select="@cdx:text" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$topics[@id = $id]" mode="name">
                <xsl:with-param name="qualify-hint" select="@qualifyHint" />
                <xsl:with-param name="type-params" select="@cdx:typeParams != 'false'" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="referenced" select="cdx:lookup-topic($id, @cdx:version, $topic)" />
        <xsl:variable name="upgraded" select="$referenced/(parent::cdx:topic[$auto-upgrade and @api-list='overloads'], .)[1]" />
        <xsl:variable name="related-topics" select="exists(ancestor::maml:relatedTopics)" />
        <xsl:variable name="topic-uri">
          <xsl:apply-templates select="$upgraded" mode="topic-uri" />
        </xsl:variable>
        
        <a href="{$topic-uri}" class="code-entity{concat(' ',$lang)[$lang-class]}">
          <xsl:attribute name="title">
            <xsl:apply-templates select="$upgraded" mode="name">
              <xsl:with-param name="qualify-hint" select="true()" />
              <xsl:with-param name="title" select="true()" />
              <xsl:with-param name="text-only" select="true()" tunnel="yes" />
            </xsl:apply-templates>
          </xsl:attribute>

          <xsl:choose>
            <xsl:when test="@cdx:text">
              <xsl:value-of select="@cdx:text" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$upgraded" mode="name">
                <xsl:with-param name="qualify-hint" select="@qualifyHint" />
                <xsl:with-param name="related-topics" select="$related-topics" />
                <xsl:with-param name="title" select="$related-topics" />
                <xsl:with-param name="type-params" select="@cdx:typeParams!='false'" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cdx:externalCodeEntityReference" mode="generate-link">
    <xsl:param name="lang" as="xs:string()?" tunnel="yes" />
    <xsl:param name="lang-class" as="xs:boolean" select="true()" />
    
    <xsl:variable name="uri" select="xs:anyURI(concat('http://msdn.microsoft.com/en-us/library/', @msdn-id, '.aspx'))" />
    
    <a href="{$uri}" class="code-entity{concat(' ',$lang)[$lang-class]}">
      <xsl:attribute name="title">
        <xsl:apply-templates select="." mode="name">
          <xsl:with-param name="lang" select="$lang" tunnel="yes" />
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="title" select="true()" />
          <xsl:with-param name="text-only" select="true()" tunnel="yes" />
        </xsl:apply-templates>
      </xsl:attribute>

			<xsl:choose>
				<xsl:when test="@cdx:text">
					<xsl:value-of select="@cdx:text" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="name">
						<xsl:with-param name="lang" select="$lang"  tunnel="yes"/>
						<xsl:with-param name="qualify-hint" select="@qualifyHint" />
						<xsl:with-param name="title" select="exists(ancestor::maml:relatedTopics)" />
						<xsl:with-param name="type-params" select="@cdx:typeParams!='false'" />
      </xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
    </a>
  </xsl:template>
  
  <xsl:template match="cdx:externalCodeEntityReference" mode="name">
    <xsl:param name="qualify-hint" select="false()" as="xs:boolean" />
    <xsl:param name="title" select="false()" as="xs:boolean" />
    <xsl:param name="type-params" select="true()" as="xs:boolean" />

    <xsl:choose>
      <xsl:when test="@api-name='.ctor'">
        <xsl:value-of select="@container-name"/>
      </xsl:when>
      <xsl:when test="$qualify-hint and @container-name">
        <xsl:value-of select="@container-name" />
        <xsl:call-template name="token-type-seperator" />
        <xsl:value-of select="@api-name" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="apply-language" />
      </xsl:otherwise>                
    </xsl:choose>
        
    <xsl:if test="$type-params and cdx:template-parameter">
      <xsl:apply-templates select="." mode="template-parameters" />
    </xsl:if>
    
    <xsl:if test="$title">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="." mode="category-title" />
    </xsl:if>
    
    <xsl:if test="../@api-list='overloads'">
      <!-- overloaded-->
      <xsl:apply-templates select="." mode="parameters" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="maml:externalLink">
    <a href="{maml:linkUri}" title="{maml:linkText}">
      <xsl:apply-templates select="maml:linkText/node()"/>
    </a>
  </xsl:template>
  
  <xsl:template match="maml:link">
    <xsl:param name="topic" tunnel="yes" />
    
    <xsl:variable name="tokens" select="tokenize(@xlink:href, '#')" />
    <xsl:variable name="id" select="$tokens[1]" />
    <xsl:variable name="fragment" select="$tokens[2]" />
    
    <xsl:choose>
      <xsl:when test="$id=''">
        <a href="#{$fragment}">
          <xsl:apply-templates />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="referenced" select="cdx:lookup-topic($id, @cdx:version, $topic)" />
        
        <xsl:variable name="topic-uri">
          <xsl:apply-templates select="$referenced" mode="topic-uri" />
        </xsl:variable>
        
        <a href="{$topic-uri}{if ($fragment) then concat('#',$fragment) else ()}">
          <xsl:attribute name="title">
            <xsl:apply-templates select="$referenced" mode="name">
              <xsl:with-param name="qualify-hint" select="true()" />
              <xsl:with-param name="title" select="true()" />
              <xsl:with-param name="text-only" select="true()" tunnel="yes" />
            </xsl:apply-templates>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="node()">
              <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$referenced" mode="name">
                <xsl:with-param name="qualify-hint" select="true()" />
                <xsl:with-param name="title" select="true()" />
                <xsl:with-param name="text-only" select="false()" tunnel="yes" />
              </xsl:apply-templates>  
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
    <!-- language specific syntax -->
  <xsl:template match="cdx:referenceTo|cdx:pointerTo|cdx:arrayOf|cdx:type|cdx:refType">
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    
    <xsl:variable name="current" select="." />
    
    <xsl:choose>
      <xsl:when test="empty($lang)">
        <xsl:for-each select="$languages">
          <span class="{.}">
            <xsl:apply-templates select="$current" mode="apply-language">
              <xsl:with-param name="lang" select="." tunnel="yes" />
            </xsl:apply-templates>
          </span>
        </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="$current" mode="apply-language" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- misc -->
  <xsl:template match="maml:autoOutline">
    <p>This topic contains the following sections.</p>
    <ul class="autoOutline">
      <xsl:for-each select="../../maml:section">
        <li>
          <a href="#{@address}">
            <xsl:apply-templates select="maml:title/node()" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="@address">
    <xsl:attribute name="id" select="." />
  </xsl:template>

  <xsl:template match="@*" />
</xsl:stylesheet>
