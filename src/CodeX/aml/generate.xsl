<?xml version="1.0"?>

<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx xs xsl"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="syntax.xsl" />
  <xsl:template name="category-list-name">
    <xsl:param name="category" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$category = 'overload'">
        <xsl:text>Overload List</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'explicit'">
        <xsl:text>
					Explicit Interface Implementations
				</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'member'">
        <xsl:text>Members</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'constructor'">
        <xsl:text>Constructors</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'class'">
        <xsl:text>Classes</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'delegate'">
        <xsl:text>Delegates</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'enumeration'">
        <xsl:text>Enumerations</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'event'">
        <xsl:text>Events</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'field'">
        <xsl:text>Fields</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'interface'">
        <xsl:text>Interfaces</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'method'">
        <xsl:text>Methods</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'operator'">
        <xsl:text>Operators</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'property'">
        <xsl:text>Properties</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'structure'">
        <xsl:text>Structures</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="category-name">
    <xsl:param name="category" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$category = ('overload','explicit')">
        <xsl:text>Name</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'member'">
        <xsl:text>Member</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'constructor'">
        <xsl:text>Constructor</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'class'">
        <xsl:text>Class</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'delegate'">
        <xsl:text>Delegate</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'enumeration'">
        <xsl:text>Enumeration</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'event'">
        <xsl:text>Event</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'field'">
        <xsl:text>Field</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'interface'">
        <xsl:text>Interface</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'method'">
        <xsl:text>Method</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'operator'">
        <xsl:text>Operator</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'property'">
        <xsl:text>Property</xsl:text>
      </xsl:when>
      <xsl:when test="$category = 'structure'">
        <xsl:text>Structure</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate-namespace">
    <xsl:param name="namespace-apis" tunnel="no" />
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="product-documentation" tunnel="yes" />
    <xsl:param name="product" tunnel="yes" />
    <xsl:variable name="namespace-documentation" select="cdx:lookup-documentation($namespace-apis[1]/@id, 
                                                                                  $product-apis,
                                                                                  $documentation)" />
    <xsl:if test="empty($namespace-documentation)">
      <xsl:message terminate="yes">
        <xsl:text>
					Missing documentation for
				</xsl:text>
        <xsl:value-of select="@id" />
      </xsl:message>
    </xsl:if>
    <developerReferenceWithoutSyntaxDocument xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5">
      <introduction>
        <xsl:for-each select="$namespace-documentation/summary">
          <xsl:apply-templates mode="api-doc">
            <xsl:with-param name="current" tunnel="yes" select="$namespace-apis[1]" />
          </xsl:apply-templates>
        </xsl:for-each>
      </introduction>
      <xsl:for-each-group select="$namespace-apis/elements/element/cdx:get-api(@api, $apis)" group-by="cdx:api-subgroup(.)">

        <!-- do classes first, then interfaces, then delegates, then enums. -->
        <xsl:sort select="index-of(('class', 'structure', 'interface', 'delegate', 'enumeration'), current-grouping-key())" />
        <section>
          <title>
            <xsl:call-template name="category-list-name">
              <xsl:with-param name="category" select="current-grouping-key()" />
            </xsl:call-template>
          </title>
          <content>
            <table cdx:class="members" cdx:category="{current-grouping-key()}">
              <tableHeader>
                <row>
                  <entry>
                    <xsl:call-template name="category-name">
                      <xsl:with-param name="category" select="current-grouping-key()" />
                    </xsl:call-template>
                  </entry>
                  <entry>Description</entry>
                </row>
              </tableHeader>
              <xsl:for-each select="current-group()">
                <xsl:sort select="@id" />
                <xsl:variable name="current" select="." />
                <xsl:apply-templates select="." mode="entry">
                  <xsl:with-param name="current" select="$namespace-apis[root(.) is root($current)]" tunnel="yes" />
                </xsl:apply-templates>
              </xsl:for-each>
            </table>
          </content>
        </section>
      </xsl:for-each-group>
      <xsl:apply-templates select="$namespace-documentation" mode="remarks" />
      <xsl:apply-templates select="$namespace-documentation/example" mode="api-doc" />
      <relatedTopics>
        <xsl:apply-templates select="$namespace-documentation/seealso" mode="api-doc" />
      </relatedTopics>
    </developerReferenceWithoutSyntaxDocument>
  </xsl:template>

  <xsl:template name="generate-members">
    <xsl:param name="members" />
    <xsl:param name="current-type" tunnel="yes" />
    <xsl:param name="category" tunnel="yes" />
    <developerReferenceWithoutSyntaxDocument>
      <introduction>
        <xsl:call-template name="members-introduction" />
      </introduction>
      <xsl:variable name="explicit" select="$members[proceduredata/@eii = 'true']" />
      <xsl:variable name="non-explicit" select="$members[not(proceduredata/@eii = 'true')]" />
      <xsl:if test="$non-explicit">
        <xsl:call-template name="generate-members-list">
          <xsl:with-param name="members" select="$non-explicit" />
          <xsl:with-param name="category" select="$category" />
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$explicit">
        <xsl:call-template name="generate-members-list">
          <xsl:with-param name="members" select="$explicit" />
          <xsl:with-param name="category" select="'explicit'" />
        </xsl:call-template>
      </xsl:if>
      <relatedTopics>
        <!-- containing class -->
        <xsl:call-template name="api-link">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="id" select="$current-type/@id" />
        </xsl:call-template>

        <!-- containing namespace -->
        <xsl:call-template name="api-link">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="id" select="$current-type/containers/namespace/@api" />
        </xsl:call-template>
      </relatedTopics>
    </developerReferenceWithoutSyntaxDocument>
  </xsl:template>

  <xsl:template name="generate-overloads">
    <xsl:param name="members" />
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="product-documentation" tunnel="yes" />
    <xsl:param name="current-type" tunnel="yes" />
    <xsl:param name="category" tunnel="yes" />
    <developerReferenceWithoutSyntaxDocument>
      <introduction>
        <xsl:apply-templates select="$members/cdx:lookup-documentation(@id, $product-apis, $documentation)/overloads/node()" mode="api-doc" />
      </introduction>
      <xsl:call-template name="generate-members-list">
        <xsl:with-param name="category" select="'overload'" />
        <xsl:with-param name="members" select="$members" />
      </xsl:call-template>
      <relatedTopics>
        <!-- containing class -->
        <xsl:call-template name="api-link">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="id" select="$current-type/@id" />
        </xsl:call-template>

        <!-- containing members list -->
        <!--xsl:if test="$category != 'constructor'">
          <xsl:call-template name="api-link">
            <xsl:with-param name="qualify-hint" select="true()" />
            <xsl:with-param name="id" select="$current-type/@id" />
            <xsl:with-param name="subgroup" select="$category" />
          </xsl:call-template>
        </xsl:if-->

        <!-- containing namespace -->
        <xsl:call-template name="api-link">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="id" select="$current-type/containers/namespace/@api" />
        </xsl:call-template>
      </relatedTopics>
    </developerReferenceWithoutSyntaxDocument>
  </xsl:template>

  <xsl:template name="generate-api">
    <xsl:param name="api" />
    <xsl:param name="overloaded" as="xs:boolean" select="false()" />
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="product-documentation" tunnel="yes" />
    <xsl:param name="current" tunnel="yes" select="$api" />
    <xsl:param name="current-type" tunnel="yes" select="$api" />
    <xsl:param name="category" as="xs:string?" tunnel="yes" select="()" />
    <xsl:variable name="api-doc" select="cdx:lookup-documentation($api/@id, $product-apis, $documentation)" />
    <developerReferenceWithSyntaxDocument>
      <introduction>
        <xsl:apply-templates select="$api-doc/summary/node()" mode="api-doc" />
      </introduction>
      <xsl:apply-templates select="$api/family" mode="generate" />
      <xsl:apply-templates select="$api/containers" mode="generate" />
      <xsl:apply-templates select="$api" mode="syntax" />
      <xsl:apply-templates select="$api/templates" mode="generate">
        <xsl:with-param name="api-doc" select="$api-doc" />
      </xsl:apply-templates>
      <xsl:apply-templates select="$api/parameters" mode="generate">
        <xsl:with-param name="api-doc" select="$api-doc" />
      </xsl:apply-templates>
      <xsl:apply-templates select="$api/returns" mode="generate">
        <xsl:with-param name="api-doc" select="$api-doc" />
      </xsl:apply-templates>
      <xsl:apply-templates select="$api-doc" mode="exceptions" />
      <xsl:apply-templates select="$api/elements" mode="generate" />
      <xsl:apply-templates select="$api-doc" mode="remarks" />
      <xsl:apply-templates select="$api-doc/example" mode="api-doc" />
      <xsl:apply-templates select="$api-doc" mode="thread-safety" />
      <relatedTopics>
        <xsl:if test="not($api is $current-type)">
          <!-- containing members list -->
          <!--xsl:if test="$category != 'constructor'">
            <xsl:call-template name="api-link">
              <xsl:with-param name="qualify-hint" select="true()" />
              <xsl:with-param name="id" select="$current-type/@id" />
              <xsl:with-param name="subgroup" select="$category" />
            </xsl:call-template>
          </xsl:if-->

          <!-- overloads -->
          <xsl:if test="$overloaded">
            <xsl:call-template name="api-link">
              <xsl:with-param name="qualify-hint" select="true()" />
              <xsl:with-param name="auto-upgrade" select="true()" />
              <xsl:with-param name="id" select="$api/@id" />
            </xsl:call-template>
          </xsl:if>

          <!-- containing class -->
          <xsl:call-template name="api-link">
            <xsl:with-param name="qualify-hint" select="true()" />
            <xsl:with-param name="id" select="$current-type/@id" />
          </xsl:call-template>
        </xsl:if>

        <!-- containing namespace -->
        <xsl:call-template name="api-link">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="id" select="$current-type/containers/namespace/@api" />
        </xsl:call-template>
        <xsl:apply-templates select="$api-doc/seealso" mode="api-doc" />
      </relatedTopics>
    </developerReferenceWithSyntaxDocument>
  </xsl:template>

  <xsl:template match="templates" mode="generate">
    <xsl:param name="api-doc" as="node()?" />
    <genericParameters>
      <xsl:apply-templates select="template" mode="generate">
        <xsl:with-param name="api-doc" select="$api-doc" />
      </xsl:apply-templates>
    </genericParameters>
  </xsl:template>

  <xsl:template match="template" mode="generate">
    <xsl:param name="api-doc" as="node()?" />
    <xsl:variable name="name" select="@name" />
    <genericParameter>
      <parameterReference>
        <xsl:value-of select="@name" />
      </parameterReference>
      <content>
        <para>
          <xsl:variable name="doc" select="$api-doc/typeparam[@name=$name]" />
          <xsl:if test="not($doc)">
            <xsl:message>
              API documentation not found for type parameter
              <xsl:value-of select="name" />
              .
            </xsl:message>
          </xsl:if>
          <xsl:apply-templates select="$doc/node()" mode="api-doc" />
        </para>
      </content>
    </genericParameter>
  </xsl:template>

  <xsl:template match="parameters" mode="generate">
    <xsl:param name="api-doc" as="node()?" />
    <parameters>
      <xsl:apply-templates select="parameter" mode="generate">
        <xsl:with-param name="api-doc" select="$api-doc" />
      </xsl:apply-templates>
    </parameters>
  </xsl:template>

  <xsl:template match="parameter" mode="generate">
    <xsl:param name="api-doc" as="node()?" />
    <xsl:variable name="name" select="@name" />
    <parameter>
      <parameterReference>
        <xsl:value-of select="@name" />
      </parameterReference>
      <content>
        <para cdx:class="parameterType">
          <xsl:text>Type: </xsl:text>
          <xsl:apply-templates select="*" mode="generate" />
        </para>
        <para>
          <xsl:variable name="doc" select="$api-doc/param[@name=$name]" />
          <xsl:if test="not($doc)">
            <xsl:message>
              API documentation not found for parameter
              <xsl:value-of select="name" />
              .
            </xsl:message>
          </xsl:if>
          <xsl:apply-templates select="$doc/node()" mode="api-doc" />
        </para>
      </content>
    </parameter>
  </xsl:template>

  <xsl:template match="returns" mode="generate">
    <xsl:param name="api-doc" />
    <xsl:variable name="subgroup" select="../apidata/@subgroup" />
    <xsl:choose>
      <xsl:when test="$subgroup='method'">
        <xsl:apply-templates select="." mode="generate-return-value">
          <xsl:with-param name="api-doc" select="$api-doc" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$subgroup='property'">
        <xsl:apply-templates select="." mode="generate-property-value">
          <xsl:with-param name="api-doc" select="$api-doc" />
        </xsl:apply-templates>
      </xsl:when>
      <!-- TODO: Do something sensible for fields! -->
      <xsl:otherwise>
        <xsl:if test="$api-doc/(returns|value)">
          <xsl:message>
            <xsl:text>
      				Documentation provided for value of a field.  This documentation will not be rendered and should be moved to the remarks section.
      			</xsl:text>
          </xsl:message>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="returns" mode="generate-return-value">
    <xsl:param name="api-doc" />
    <returnValue>
      <title>Return Value</title>
      <content>
        <para>
          <xsl:text>Type: </xsl:text>
          <xsl:apply-templates select="*" mode="generate" />
        </para>
        <para>
          <xsl:variable name="doc" select="$api-doc/returns" />
          <xsl:if test="not($doc)">
            <xsl:message>
              API documentation not found for return value.
            </xsl:message>
          </xsl:if>
          <xsl:apply-templates select="$doc/node()" mode="api-doc" />
        </para>
      </content>
    </returnValue>
  </xsl:template>

  <xsl:template match="returns" mode="generate-property-value">
    <xsl:param name="api-doc" />
    <returnValue>
      <title>Property Value</title>
      <content>
        <para>
          <xsl:text>Type: </xsl:text>
          <xsl:apply-templates select="*" mode="generate" />
        </para>
        <para>
          <xsl:variable name="doc" select="$api-doc/value" />
          <xsl:if test="not($doc)">
            <xsl:message>
              API documentation not found for property value.
            </xsl:message>
          </xsl:if>
          <xsl:apply-templates select="$doc/node()" mode="api-doc" />
        </para>
      </content>
    </returnValue>
  </xsl:template>

  <xsl:template name="generate-members-list">
    <xsl:param name="category" />
    <xsl:param name="members" />
    <section cdx:class="members">
      <title>
        <xsl:call-template name="category-list-name">
          <xsl:with-param name="category" select="$category" />
        </xsl:call-template>
      </title>
      <content>
        <table cdx:class="members" cdx:category="{$category}">
          <tableHeader>
            <row>
              <entry>
                <xsl:call-template name="category-name">
                  <xsl:with-param name="category" select="$category" />
                </xsl:call-template>
              </entry>
              <entry>Description</entry>
            </row>
          </tableHeader>
          <xsl:choose>
            <xsl:when test="$category = 'member'">
              <xsl:apply-templates select="$members" mode="entry">
                <xsl:with-param name="overloaded" select="false()" />
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each-group select="$members" group-by="string(.[proceduredata/@eii]/implements/member/type/@api)">
                <xsl:sort select="current-grouping-key()" />
                <xsl:for-each-group select="current-group()" group-by="apidata/@name">
                  <xsl:sort select="current-grouping-key()" />
                  <xsl:apply-templates select="current-group()" mode="entry">
                    <xsl:with-param name="overloaded" select="count(current-group()) > 1" />
                  </xsl:apply-templates>
                </xsl:for-each-group>
              </xsl:for-each-group>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </content>
    </section>
  </xsl:template>
  <xsl:template name="members-introduction">
    <xsl:param name="current-type" tunnel="yes" />
    <xsl:text>The </xsl:text>
    <xsl:apply-templates select="$current-type" mode="api-link" />
    <xsl:text>
			type exposes the following members.
		</xsl:text>

    <!--TODO: update the text to say "following methods" etc. -->
  </xsl:template>

  <xsl:template match="elements" mode="generate">
    <xsl:param name="current-type" tunnel="yes" />
    <sectionSimple>
      <xsl:call-template name="members-introduction" />
    </sectionSimple>
    <xsl:variable name="parent-subgroup" select="../apidata/@subgroup" />
    <xsl:variable name="members" select="element/cdx:get-api(@api, $apis)" />
    <xsl:for-each-group select="$members[not(proceduredata/@eii = 'true')]" group-by="cdx:api-subgroup(.)">
      <!-- TODO: this is different to the order in the contents (fields and properties are swapped) - is this desired? -->
      <xsl:sort select="index-of(('constructor', 'property', 'method', 'operator', 'field', 'event'), current-grouping-key())" />
      <xsl:call-template name="generate-members-list">
        <xsl:with-param name="category" select="if ($parent-subgroup = 'enumeration') then 'member' else current-grouping-key()" />
        <xsl:with-param name="members" select="current-group()" />
      </xsl:call-template>
    </xsl:for-each-group>
    <xsl:variable name="explicit-implementations" select="$members[proceduredata/@eii = 'true']" />
    <xsl:if test="$explicit-implementations">
      <xsl:call-template name="generate-members-list">
        <xsl:with-param name="category" select="'explicit'" />
        <xsl:with-param name="members" select="$explicit-implementations" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="api" mode="inherits">
    <xsl:param name="current-type" as="element(api)?" tunnel="yes" select="()" />
    <xsl:choose>
      <xsl:when test="overrides">
        <xsl:text>(Overrides</xsl:text>
        <xsl:call-template name="api-link">
          <xsl:with-param name="id" select="overrides/member/@api" />
          <xsl:with-param name="qualify-hint" select="true()" />
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="cdx:container(.) != $current-type/@id">
        <xsl:text>(Inherited from</xsl:text>
        <xsl:call-template name="api-link">
          <xsl:with-param name="id" select="containers/type/@api" />
          <xsl:with-param name="qualify-hint" select="true()" />
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>
  <xsl:template match="api[apidata/@group='type']" mode="entry">
    <!--TODO: escape address-->
    <row cdx:subgroup="{apidata/@subgroup}" cdx:visibility="{typedata/@visibility}" address="{apidata/@name}">
      <entry>
        <xsl:apply-templates select="." mode="api-link" />
      </entry>
      <entry>
        <xsl:apply-templates select="cdx:lookup-documentation(@id, $apis, $documentation)/summary/node()" mode="api-doc" />
        <xsl:apply-templates select="." mode="inherits" />
      </entry>
    </row>
  </xsl:template>

  <xsl:template match="api[apidata/@group='member']" mode="entry">
    <xsl:param name="overloaded" as="xs:boolean" select="false()" />
    <row cdx:subgroup="{apidata/(@subsubgroup, @subgroup)[1]}" cdx:visibility="{memberdata/@visibility}" cdx:static="{memberdata/@static='true'}" address="{apidata/@name}">
      <entry>
        <xsl:apply-templates select="." mode="api-link"/>
      </entry>
      <entry>
        <xsl:apply-templates select="cdx:lookup-documentation(@id, $apis, $documentation)/summary/node()" mode="api-doc" />
        <xsl:apply-templates select="." mode="inherits" />
      </entry>
    </row>
  </xsl:template>
  <xsl:template match="family" mode="generate">
    <xsl:param name="current" tunnel="yes" />
    <section>
      <title>
        Inheritance Hierarchy
      </title>
      <content>
        <list class="nobullet" cdx:class="inheritance">
          <xsl:apply-templates select="reverse(ancestors/type)" mode="generate-ancestor" />
          <listItem cdx:class="self">
            <xsl:call-template name="api-link">
              <xsl:with-param name="qualify-hint" select="true()" />
              <xsl:with-param name="id" select="$current/@id" />
            </xsl:call-template>
          </listItem>
          <xsl:apply-templates select="descendents/type" mode="generate-child" />
        </list>
      </content>
    </section>
  </xsl:template>

  <xsl:template match="type" mode="generate-ancestor">
    <listItem cdx:class="ancestor">
      <xsl:call-template name="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
        <xsl:with-param name="id" select="@api" />
      </xsl:call-template>
    </listItem>
  </xsl:template>
  <xsl:template match="type" mode="generate-child">
    <listItem cdx:class="child">
      <xsl:call-template name="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
        <xsl:with-param name="id" select="@api" />
      </xsl:call-template>
    </listItem>
  </xsl:template>

  <xsl:template match="containers" mode="generate">
    <sectionSimple>
      <definitionTable cdx:class="containers">
        <definedTerm>Namespace</definedTerm>
        <definition>
          <xsl:call-template name="api-link">
            <xsl:with-param name="id" select="namespace/@api" />
          </xsl:call-template>
        </definition>
        <definedTerm>Assembly</definedTerm>
        <definition>
          <!-- TODO: Work out file name! -->
          <xsl:value-of select="library/@assembly" />
          <xsl:text> (in </xsl:text>
          <xsl:value-of select="library/@assembly" />
          <xsl:text>.dll)</xsl:text>
        </definition>
      </definitionTable>
    </sectionSimple>
  </xsl:template>

  <xsl:template match="type[@ref='true']" mode="generate">
    <cdx:refType>
      <xsl:call-template name="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
        <xsl:with-param name="id" select="@api" />
      </xsl:call-template>
    </cdx:refType>
  </xsl:template>

  <xsl:template match="type" mode="generate">
    <xsl:call-template name="api-link">
      <xsl:with-param name="qualify-hint" select="true()" />
      <xsl:with-param name="id" select="@api" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="referenceTo" mode="generate">
    <cdx:referenceTo>
      <xsl:copy-of select="../@out" />
      <xsl:apply-templates mode="generate" />
    </cdx:referenceTo>
  </xsl:template>

  <xsl:template match="pointerTo" mode="generate">
    <cdx:pointerTo>
      <xsl:apply-templates mode="generate" />
    </cdx:pointerTo>
  </xsl:template>

  <xsl:template match="arrayOf" mode="generate">
    <cdx:arrayOf>
      <xsl:apply-templates mode="generate" />
    </cdx:arrayOf>
  </xsl:template>
</xsl:stylesheet>