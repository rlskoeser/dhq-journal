<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:dhqBiblio="http://digitalhumanities.org/dhq/ns/biblio"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:import href="coins.xsl"/>
    <xsl:import href="../../biblio/DHQ-Biblio-v2/xslt/dhqBiblio-ChicagoLoose-html.xsl"/>

    <!-- Overriding any strip-space in imported stylesheets -->
    <xsl:preserve-space elements="tei:* dhq:* dhqBiblio:title dhqBiblio:additionalTitle"/>
    <!--<xsl:strip-space elements="dhqBiblio:*"/>-->

    <!-- <xsl:param name="aprilfool" select="'true'"/> -->
    <xsl:param name="static_server" select="'https://dhq-static.digitalhumanities.org/'"/>
    <xsl:param name="static_pdf_directory" select="'pdf'"/>
    <xsl:param name="context"/>
    <xsl:param name="docurl"/>
    <xsl:param name="baseurl" select="concat('http://www.digitalhumanities.org/',$context,'/')"/>
    <xsl:param name="vol">
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='volume']"/>
    </xsl:param>
    <xsl:param name="vol_no_zeroes">
        <xsl:call-template name="get-vol">
            <xsl:with-param name="vol"><xsl:value-of select="$vol"/></xsl:with-param>
        </xsl:call-template>
    </xsl:param>
    <xsl:param name="issue">
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue']"/>
    </xsl:param>
    <xsl:param name="id">
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id']"/>
    </xsl:param>
    <xsl:param name="cssFile"/>

  <xsl:param name="biblioData" select="'../../data/biblio-full.xml'"/>

  <!-- +++++++ biblio: start                                +++++++ -->



  <!-- read in biblio file for generating citations from biblio data. -->
  <xsl:variable name="biblio">
    <xsl:sequence select="collection('../../biblio/DHQ-Biblio-v2/data/current?select=*.xml;recurse=yes;on-error=ignore')"/>
  </xsl:variable>

    <!--
    <xsl:copy-of select="document($biblioData)//dhqBiblio:BiblioSet"/>
  </xsl:variable>
  -->
  <!-- generate keys for citations -->
  <xsl:key name="biblioIdKey" match="dhqBiblio:BiblioSet/*" use="@ID"/>


<!-- jawalsh: tempalte below makes Biblio happen -->
<xsl:template match="tei:listBibl//tei:bibl[count(key('biblioIdKey',@key,$biblio)) = 1]" priority="9">
    <div class="bibl"><span class="ref">
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:comment> close </xsl:comment>
      <xsl:apply-templates select="@label"/>
    </span>
      <xsl:if test="normalize-space(@label)">
        <xsl:text>&#160;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="key('biblioIdKey',@key,$biblio)" mode="dhqBiblio:ChicagoLoose"/>
    </div>
  </xsl:template>


  <xsl:template match="tei:listBibl//tei:bibl[@key]" priority="1">
              <div class="bibl fallback"><xsl:call-template name="show-bibl-fallback"/><!-- <strong style="font-weight:bold;"><xsl:value-of select="concat('WARNING: No biblio citation found for @key: ',$key)"/></strong>--></div>
  </xsl:template>



  <!-- +++++++ biblio: end                                  +++++++ -->

  <!-- $assigned-issue is the issue to which this article is assigned -->
  <xsl:variable name="assigned-issue" select="document('../../toc/toc.xml')//journal[@vol=$vol_no_zeroes and @issue=$issue]"/>

  <!-- $published is true() if this article has been published -->
  <xsl:variable name="published" select="$assigned-issue and not($assigned-issue/@preview)"/>


    <xsl:param name="bioFile">
        <xsl:if test="not(@editorial) and $published">../</xsl:if>
        <xsl:text>bios.html</xsl:text>
    </xsl:param>

    <xsl:key name="element-by-id" match="*[@xml:id]" use="@xml:id"/>
    <!-- changing <bibl> to be used where they appear [CRB] -->
    <xsl:variable name="all-notes" select="//tei:note"/>

    <!-- suppressed elements -->
    <xsl:template match="tei:titleStmt/tei:author"/>
    <xsl:template match="dhq:authorInfo/tei:email"/>
    <xsl:template match="dhq:translatorInfo/tei:email"/>


    <xsl:template match="tei:sourceDesc"/>
    <xsl:template match="tei:encodingDesc"/>
    <xsl:template match="tei:profileDesc"/>
    <xsl:template match="tei:revisionDesc"/>
    <xsl:template match="tei:listBibl"/>
    <xsl:template match="dhq:label"/>
    <xsl:template match="dhq:teaser"/>
    <xsl:template match="dhq:langUsage"/>
    <xsl:template match="dhq:keywords"/>
    <xsl:template match="tei:figDesc"/>
    <!-- supressing caption output to call manually and append [CRB] -->
    <xsl:template match="dhq:caption"/>


  <xsl:template match="tei:publicationStmt">
    <xsl:apply-templates select=".//dhq:revisionNote"/>
  </xsl:template>


    <xsl:template name="article_main_body" match="tei:TEI">
      <!--
      <xsl:choose>
        <xsl:when test="$aprilfool = 'true'">
          <xsl:call-template name="pubInfo"/>
          <xsl:apply-templates select="tei:teiHeader"/>
          <p style="margin-top:3em;">Read about DHQ’s <a href="/dhq/about/april1_editorial_policy.html">new publishing model</a>, and, if you must, view the article in its <a href="{concat('/dhq/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'/',$id,'.html?aprilfool=false')}">original verbal form</a>.
          </p>
          <iframe style="margin-bottom:2em; width:100%;height:400px">
            <xsl:attribute name="src">
              <xsl:value-of select="concat('http://voyant-tools.org/tool/Cirrus/?corpus=dhq.',$vol_no_zeroes,'.',$issue,'.',$id,'&amp;archive=http://www.digitalhumanities.org/dhq/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'/',$id,'.xml&amp;inputFormat=TEI&amp;stopList=stop.en.taporware.txt')"/>
            </xsl:attribute>
          </iframe>
         </xsl:when>
        <xsl:otherwise>
        -->
        <div class="DHQarticle">
            <xsl:call-template name="pubInfo"/>
            <xsl:call-template name="toolbar"/>
            <xsl:apply-templates/>
            <xsl:call-template name="notes"/>
            <xsl:call-template name="bibliography"/>
            <xsl:call-template name="toolbar"/>
            <xsl:call-template name="license"/>
        </div>
      <!--
        </xsl:otherwise>
      </xsl:choose>
      -->
    </xsl:template>

    <!-- pubInfo -->
    <xsl:template name="pubInfo">
        <div id="pubInfo">
            <xsl:choose>
                <xsl:when test="$published">
                    <xsl:if test="$assigned-issue/specialTitle">
                        <xsl:apply-templates select="$assigned-issue/specialTitle"/><br />
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Preview</xsl:text><br />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$assigned-issue/title"/><br />
            <xsl:text>Volume&#160;</xsl:text>
            <xsl:value-of select="$vol"/>
            <xsl:text>&#160;Number&#160;</xsl:text>
            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue']"/>
        </div>
    </xsl:template>

    <!-- used to strip extra zeroes on volume number [CRB] -->
    <xsl:template name="get-vol">
        <xsl:param name="vol"/>
        <xsl:choose>
            <xsl:when test="substring($vol,1,1) = '0'">
                <xsl:call-template name="get-vol">
                    <xsl:with-param name="vol">
                        <xsl:value-of select="substring($vol,2)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$vol"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="toolbar">
        <div class="toolbar">
            <a>
                <xsl:choose>
                    <xsl:when test="$published">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/vol/',$vol_no_zeroes,'/',$issue,'/index.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="$assigned-issue/title"/>
                        <xsl:value-of select="concat(' ',$vol_no_zeroes,'.',$issue)"/>
                        <!--
                        <xsl:value-of select="concat(': v',$vol_no_zeroes)"/>
                        <xsl:value-of select="concat(' n',$issue)"/>
                        -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/preview/index.html')"/>
                        </xsl:attribute>
                        <xsl:text>Preview</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            &#x00a0;|&#x00a0;
            <a rel="external">
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'.xml')"/>
                </xsl:attribute>
                <xsl:text>XML</xsl:text>
            </a>
            
                |&#x00a0;
                <a rel="external">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($static_server,$static_pdf_directory,'/',$id,'.pdf')"/>
                    </xsl:attribute>
                    <xsl:text>PDF</xsl:text>
                </a>
            
            |&#x00a0;
            <a href="#" onclick="javascript:window.print();"
                title="Click for print friendly version">Print</a>
        </div>
    </xsl:template>

    <xsl:template name="license">
        <xsl:param name="status" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status"/>
        <div class="license">
            <xsl:choose>
                <xsl:when test="$status = 'CC-BY-ND'">
                    <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
                </xsl:when>
                <xsl:when test="$status = 'CC-BY'">
                    <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
                </xsl:when>
                <xsl:when test="$status = 'CC0'">
                    <a rel="license"
                        href="http://creativecommons.org/publicdomain/zero/1.0/">
                        <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
                    </a>
                    <br />
                    To the extent possible under law, the author(s) have waived all copyright and related or neighboring rights to this work.
                </xsl:when>
                <xsl:otherwise>
                    <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
                </xsl:otherwise>
            </xsl:choose>            
        </div>
    </xsl:template>

    <xsl:template name="toolbar_top">
        <div class="toolbar">
            <form id="taporware" action="get">
                <div>
                    <a>
                        <xsl:choose>
                            <xsl:when test="$published">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('/',$context,'/vol/',$vol_no_zeroes,'/',$issue,'/index.html')"/>
                                </xsl:attribute>
                                <xsl:value-of select="$assigned-issue/title"/>
                                <xsl:value-of select="concat(' ',$vol_no_zeroes,'.',$issue)"/>
                                <!--
                                <xsl:value-of select="concat(': v',$vol_no_zeroes)"/>
                                <xsl:value-of select="concat(' n',$issue)"/>
                                -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('/',$context,'/preview/index.html')"/>
                                </xsl:attribute>
                                <xsl:text>Preview</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                    &#x00a0;|&#x00a0;
                    <a rel="external">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'.xml')"/>
                        </xsl:attribute>
                        <xsl:text>XML</xsl:text>
                    </a>
<!--
                    |&#x00a0;
                    <a href="#" onclick="javascript:window.print();"
                        title="Click for print friendly version">Print Article</a>&#x00a0;|&#x00a0;
                    <select name="taportools" onchange="javascript:gototaporware(this);">
                        <option>Taporware Tools</option>
                        <option value="listword">List Words</option>
                        <option value="findtext">Find Text</option>
                        <option value="colloc">Collocation</option>
                    </select> -->

                    <!--|&#x00a0;

		   <xsl:text>Discuss</xsl:text>
			(<a>
                        	<xsl:attribute name="href">
					<xsl:value-of select="concat('/dhq/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'/',$id,'.html','#disqus_thread')"/>
				</xsl:attribute>
				<xsl:attribute name="data-disqus-identifier">
					<xsl:value-of select="$id"/>
				</xsl:attribute>
				Comments
			</a>)-->
                </div>
            </form>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader">
        <div class="DHQheader">
            <xsl:apply-templates/>
            <xsl:call-template name="coins"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
      <xsl:variable name="nominal-lang" select="if (matches(@xml:lang,'\S')) then string(@xml:lang) else 'en'"/>
      <h1 class="articleTitle lang {$nominal-lang}">
         <xsl:apply-templates/>
      </h1>
    </xsl:template>

    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
        <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="bios">
			<!--
            <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/> -->
            <!-- jawalsh: We had two authors with same first last name and same first initial, so bio didn't link correctly. Replaced commented line above, with code below. Now the full name (with spaces replaced by _ are used for ids). See also bios.xsl where a similar change was made. -->
            <!-- <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',translate(normalize-space(dhq:author_name/text()),' ','_')),$upper,$lower)"/> -->
            <xsl:value-of
      select="lower-case(concat(
        replace(dhq:author_name/dhq:family,'\s',''),
        '_',
        replace(normalize-space(string-join(dhq:author_name/text(),'')),'\s','_') ) )"/>
        </xsl:variable>
        <div class="author">
            <a rel="external">
                <xsl:choose>
                    <xsl:when test="$published">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($bioFile,'#',$bios)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/preview/',$bioFile,'#',$bios)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="dhq:author_name"/>
            </a>
            <xsl:if test="normalize-space(child::dhq:affiliation)">
                <xsl:apply-templates select="tei:email" mode="author"/>
                <xsl:text>,&#160;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="dhq:affiliation"/>
            <xsl:if test="tei:idno[@type='ORCID']">
                <xsl:call-template name="orcid">
                    <xsl:with-param name="orcid" select="normalize-space(tei:idno[@type = 'ORCID'])"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template name="orcid">
        <xsl:param name="orcid"/>
        <xsl:value-of select="' '"/>
        <a href="{$orcid}">
                <img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /><xsl:value-of select="concat('&#x00a0;',$orcid)"/></a>
    </xsl:template>

    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:translatorInfo">
        <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="bios">
            <!--
            <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/> -->
            <!-- jawalsh: We had two authors with same first last name and same first initial, so bio didn't link correctly. Replaced commented line above, with code below. Now the full name (with spaces replaced by _ are used for ids). See also bios.xsl where a similar change was made. -->
            <!-- <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',translate(normalize-space(dhq:author_name/text()),' ','_')),$upper,$lower)"/> -->
            <xsl:value-of
                select="lower-case(concat(
                replace(dhq:translator_name/dhq:family,'\s',''),
                '_',
                replace(normalize-space(string-join(dhq:translator_name/text(),'')),'\s','_') ) )"/>
        </xsl:variable>
        <div class="author">
            <span style="font-style:italic;">Translation: </span><a rel="external">
                <xsl:choose>
                    <xsl:when test="$published">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($bioFile,'#',$bios)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/preview/',$bioFile,'#',$bios)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="dhq:translator_name"/>
            </a>
            <xsl:if test="normalize-space(child::dhq:affiliation)">
                <xsl:apply-templates select="tei:email" mode="author"/>
                <xsl:text>,&#160;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="dhq:affiliation"/>
        </div>
    </xsl:template>

    <xsl:template match="dhq:authorInfo/tei:email|dhq:translatorInfo/tei:email" mode="author">
      <xsl:param name="first" select="replace(., '@', '_at_')"/>
      <xsl:param name="safer-email" select="replace($first, '\.', '_dot_')"/>
      <xsl:text>&#160;&lt;</xsl:text>
      <a href="mailto:{$safer-email}"
        onclick="javascript:window.location.href='mailto:'+deobfuscate('{$safer-email}'); return false;"
        onkeypress="javascript:window.location.href='mailto:'+deobfuscate('{$safer-email}'); return false;">
        <xsl:value-of select="$safer-email"/>
      </a>
      <xsl:text>&gt;</xsl:text>
    </xsl:template>

<!-- Make sure the blank abstracts do not appear -->
    <xsl:template match="dhq:abstract">
      <xsl:if test="normalize-space()">
        <div id="abstract">
            <h2>Abstract</h2>
            <xsl:apply-templates/>
        </div>
      </xsl:if>
    </xsl:template>

    <xsl:template match="tei:text">
        <div id="DHQtext">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:text//tei:text" priority="2">
      <xsl:variable name="nominal-lang" select="if (matches(@xml:lang,'\S')) then string(@xml:lang) else 'en'"/>
      <div class="lang {$nominal-lang}">
        <xsl:apply-templates/>
      </div>
    </xsl:template>

    <xsl:template match="tei:div">
        <xsl:variable name="depth">
            <xsl:value-of select="count(ancestor::tei:div)"/>
        </xsl:variable>
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="assign-class">
                <xsl:with-param name="addClass" select="concat('div',$depth)"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xdoc:doc>division heads</xdoc:doc>
    <xsl:template match="tei:head">
        <xsl:if test="normalize-space(.)">
        <xsl:choose>
            <xsl:when test="parent::tei:div">
                <xsl:variable name="depth">
                    <xsl:value-of select="count(ancestor::tei:div)"/>
                </xsl:variable>
                <xsl:choose>
                <!-- need first when/@test to avoid duplicate heads in slides -->

                    <xsl:when test="($depth) &gt; 6">
                        <xsl:element name="h6">
                            <xsl:call-template name="assign-class"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="h{$depth}">
                            <xsl:call-template name="assign-class"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- when tei:head is not a child of tei:div, do nothing [CRB] -->
            </xsl:otherwise>
        </xsl:choose>
        </xsl:if>
    </xsl:template>

  <xsl:template match="tei:list/tei:head">
    <div class="label bold"><xsl:apply-templates/></div>
  </xsl:template>


    <xsl:template match="tei:quote[@rend = 'inline']|tei:called|tei:title[@rend = 'quotes']|tei:q|tei:said|tei:soCalled">
        <xsl:call-template name="quotes"/>
    </xsl:template>

    <xsl:template priority="2"
      match="tei:cit/tei:quote[@rend='block'] | tei:epigraph/tei:quote[@rend='block']">
      <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:quote[@rend='block']">
        <blockquote>
            <!-- added to allow block elements within tei:quote [CRB] -->
            <xsl:choose>
                <xsl:when test="descendant::tei:list or descendant::tei:sp or descendant::tei:table or descendant::tei:lg or descendant::tei:xtext or descendant::tei:p"><xsl:apply-templates/></xsl:when>
                <xsl:when test="ancestor::tei:p"><p><xsl:apply-templates/></p></xsl:when>
                <xsl:otherwise><p class="ptext"><xsl:apply-templates/></p></xsl:otherwise>
            </xsl:choose>
        </blockquote>
    </xsl:template>

    <xsl:template match="tei:cit">
        <xsl:choose>
            <xsl:when test="tei:quote[@rend='block']/descendant::tei:list">
                <blockquote class="quotedlist">
                    <!-- added to allow block elements within tei:quote [CRB] -->
                    <xsl:choose>
                        <xsl:when test="child::tei:p"><xsl:apply-templates select="tei:quote"/></xsl:when>
                        <xsl:when test="descendant::tei:list or descendant::tei:sp or descendant::tei:table or descendant::tei:lg or descendant::tei:xtext"><xsl:apply-templates/></xsl:when>
                        <xsl:otherwise><p class="ptext"><xsl:apply-templates/></p></xsl:otherwise>
                    </xsl:choose>
                </blockquote>
            </xsl:when>
            <xsl:when test="tei:quote[@rend='block']">
                <xsl:choose>
                    <!-- When a linegroup, we don't want to use blockquotes since they need hanging indents [CRB] -->
                    <xsl:when test="descendant::tei:lg"><div class="lg"><xsl:apply-templates/></div></xsl:when>
                    <xsl:otherwise>
                        <blockquote>
                            <xsl:choose>
                                <xsl:when test="descendant::tei:list or descendant::tei:lg"><xsl:apply-templates/></xsl:when>
                                <xsl:when test="descendant::tei:p"><xsl:apply-templates select="tei:quote"/></xsl:when>
                                <xsl:when test="ancestor::tei:p"><p><xsl:apply-templates/></p></xsl:when>
                                <xsl:otherwise><p class="ptext"><xsl:apply-templates/></p></xsl:otherwise>
                            </xsl:choose>
                        </blockquote>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates mode="scrubbing"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:epigraph">
        <xsl:choose>
            <xsl:when test="tei:quote[@rend='block']/tei:list">
                <blockquote class="quotedlist">
                    <!-- added to allow block elements within tei:quote [CRB] -->
                    <xsl:choose>
                        <xsl:when test="descendant::tei:list or descendant::tei:sp or descendant::tei:table or descendant::tei:lg or descendant::tei:xtext"><xsl:apply-templates/></xsl:when>
                        <xsl:when test="descendant::tei:p"><xsl:apply-templates select="tei:quote"/></xsl:when>
                        <xsl:otherwise><p class="ptext"><xsl:apply-templates/></p></xsl:otherwise>
                    </xsl:choose>
                </blockquote>
            </xsl:when>
            <xsl:when test="tei:quote[@rend='block']">
                <div>
                    <xsl:call-template name="assign-class"/>
                    <xsl:choose>
                        <xsl:when test="descendant::tei:list or descendant::tei:lg or descendant::tei:sp"><xsl:apply-templates/></xsl:when>
                        <xsl:when test="descendant::tei:p"><xsl:apply-templates select="tei:quote"/></xsl:when>
                        <xsl:when test="ancestor::tei:p"><p><xsl:apply-templates/></p></xsl:when>
                        <xsl:otherwise><p class="ptext"><xsl:apply-templates/></p></xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="assign-class"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p">
        <!-- added to allow <div>-free paragraphs in block elements [CRB] -->
        <xsl:choose>
            <xsl:when test="parent::tei:note or ancestor::tei:list[@type='gloss']"><xsl:apply-templates/><br/><br/></xsl:when>
            <xsl:when test="ancestor::dhq:abstract"><p><xsl:apply-templates/></p></xsl:when>
            <xsl:when test="ancestor::tei:sp">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:eg or ancestor::tei:list or ancestor::tei:quote[@rend='block'] or ancestor::tei:floatingText">
                        <div class="ptext">
                            <table summary="quoted speech">
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="preceding-sibling::tei:p">
                                            <td class="speaker">&#160;</td><td><xsl:apply-templates/></td></xsl:when>
                                        <xsl:otherwise>
                                            <td class="speaker"><xsl:value-of select="preceding-sibling::tei:speaker"/></td><td><xsl:apply-templates/></td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                            </table>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:variable name="counter">
                         <xsl:number count="//tei:p[not(ancestor::dhq:example or ancestor::tei:figure or ancestor::tei:quote or parent::tei:note or ancestor::tei:sp[ancestor::tei:eg or ancestor::tei:list or ancestor::tei:quote[@rend='block']])]" from="//tei:body" level="any"/>
                      </xsl:variable>
                        <div class="counter">
                          <a href="#p{$counter}">
                            <xsl:value-of select="$counter"/>
                          </a>
                        </div>
                        <div class="ptext" id="p{$counter}">
                            <table summary="quoted speech">
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="preceding-sibling::tei:p">
                                            <td class="speaker">&#160;</td><td><xsl:apply-templates/></td></xsl:when>
                                        <xsl:otherwise>
                                            <td class="speaker"><xsl:value-of select="preceding-sibling::tei:speaker"/></td><td><xsl:apply-templates/></td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                            </table>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::tei:quote">
                <xsl:choose>
                    <xsl:when test="(parent::tei:quote/following-sibling::tei:ref or parent::tei:quote/following-sibling::tei:ptr) and following-sibling::tei:p"><p class="ptext"><xsl:apply-templates/></p></xsl:when>
                    <xsl:when test="(parent::tei:quote/following-sibling::tei:ptr) and not(child::tei:list)"><p class="quote"><xsl:apply-templates/><xsl:apply-templates select="parent::tei:quote/following-sibling::tei:ptr"/></p></xsl:when>
                    <xsl:when test="(parent::tei:quote/following-sibling::tei:ref) and not(child::tei:list)"><p class="quote"><xsl:apply-templates/><xsl:apply-templates select="parent::tei:quote/following-sibling::tei:ref"/></p></xsl:when>
                    <xsl:otherwise><div class="ptext"><xsl:apply-templates/></div></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::tei:list or ancestor::dhq:example or ancestor::tei:eg or ancestor::tei:figure">
                <div class="ptext"><xsl:apply-templates/></div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="counter">
                        <xsl:number count="//tei:p[not(ancestor::dhq:example or ancestor::tei:figure or ancestor::tei:quote or parent::tei:note or ancestor::tei:sp[ancestor::tei:epigraph or ancestor::tei:quote[@rend='block']])]"
                            from="//tei:body" level="any"/>
              </xsl:variable>
                <xsl:if test="ancestor::tei:text">
                    <div class="counter">
                      <a href="#p{$counter}">
                        <xsl:value-of select="$counter"/>
                      </a>
                    </div>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="child::tei:figure and not(text())"><xsl:apply-templates/></xsl:when>
                    <xsl:otherwise>
                      <div class="ptext" id="p{$counter}">
                        <xsl:apply-templates/>
                      </div></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:stage">
        <span class="stage">&#91;<xsl:apply-templates/>&#93;</span>
    </xsl:template>

    <xsl:template match="tei:sp">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:speaker"/>

    <xsl:template match="tei:title">
        <cite>
            <xsl:call-template name="assign-class"/>
            <xsl:apply-templates/>
        </cite>
    </xsl:template>

    <xsl:template match="dhq:example">
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="assign-class"/>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="tei:head">
                    <xsl:apply-templates select="tei:head" mode="caption"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="label-no-caption"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>

    </xsl:template>

    <xsl:template match="tei:gi">
        <span class="monospace">
        <xsl:value-of select="concat('&lt;',normalize-space(.),'>')"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:att">
        <span class="monospace">
            <xsl:value-of select="concat('@',normalize-space(.))"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:figure">
                <div>
                    <xsl:call-template name="id"/>
                    <xsl:call-template name="assign-class"/>
                    <xsl:apply-templates/>
                    <xsl:choose>
                        <xsl:when test="tei:head">
                            <xsl:apply-templates select="tei:head" mode="caption"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="label-no-caption"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </div>
    </xsl:template>

    <xsl:template match="tei:label" mode="figureLabel">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="tei:figure/tei:head" mode="caption">
        <!-- wrap <p>-less captions in <div class="ptext"> for width uniformity [CRB] -->
        <xsl:if test="child::node()">
            <div class="caption">
            <!-- what is the special case for the xsl:if below? -->
            <xsl:if test="not(ancestor::tei:table)">
            <div class="label">
                <xsl:apply-templates select=".." mode="label"/>
                <xsl:text>.&#160;</xsl:text>
                <xsl:apply-templates select="./tei:label" mode="figureLabel"/>
            </div>
            </xsl:if>
        <xsl:apply-templates/>
                <!-- I think this is only needed for 000009.xml; problem convertion from dhq:caption to head -->
        <xsl:apply-templates select="following-sibling::dhq:caption" mode="caption"/>
        </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dhq:caption" mode="caption">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:table/tei:head" mode="caption">
        <div class="caption">
            <div class="label">
            <xsl:apply-templates select="." mode="label"/>
            <xsl:text>.&#160;</xsl:text>
            <xsl:apply-templates select="./tei:label" mode="figureLabel"/>
            </div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dhq:example/tei:head" mode="caption">
        <div class="caption">
            <div class="label">
                <xsl:apply-templates select="." mode="label"/>
                <xsl:text>.&#160;</xsl:text>
                <xsl:apply-templates select="./tei:label" mode="figureLabel"/>
            </div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:graphic">
        <xsl:param name="video_id">
            <xsl:value-of select="@url"/>
        </xsl:param>
        <xsl:choose>
            <xsl:when test="@type='video'">
                <object type="application/x-shockwave-flash" data="{$video_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" width="400" height="300">
                    <param name="allowfullscreen" value="true"/>
                    <param name="allowscriptaccess" value="always"/>
                    <param name="movie" value="{$video_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1"/>
                    <embed src="{$video_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="300"></embed>
                </object>
            </xsl:when>
            <xsl:when test="ancestor::tei:p or parent::tei:cell">
                <a href="{@url}" rel="external">
                    <xsl:call-template name="createImgTag">
                        <xsl:with-param name="url" select="@url"/>
                        <xsl:with-param name="style" select="@style"/>
                        <xsl:with-param name="altText" select="../tei:figDesc/text()"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise><div class="ptext">
                <a href="{@url}" rel="external">
                    <xsl:call-template name="createImgTag">
                        <xsl:with-param name="url" select="@url"/>
                        <xsl:with-param name="style" select="@style"/>
                        <xsl:with-param name="altText" select="../tei:figDesc/text()"/>
                    </xsl:call-template>
                </a>
            </div>
            </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
   <xsl:template name="createImgTag">
	<xsl:param name="url"/>
	<xsl:param name="style"/>
	<xsl:param name="altText"/>
<img src="{$url}" style="{$style}" alt="{$altText}" />
</xsl:template>
    <xsl:template match="tei:media">
        <xsl:param name="mediaURL">
            <xsl:value-of select="@url"/>
        </xsl:param>
        <xsl:choose>
            <xsl:when test="@mimeType='video/mp4'">
                <div><iframe src="{$mediaURL}" frameborder="0" allow="autoplay; fullscreen" allowfullscreen="">
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when test="@width">
                                <xsl:value-of select="@width"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'640'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:choose>
                            <xsl:when test="@height">
                                <xsl:value-of select="@height"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'524'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:comment>Gimme some comment!</xsl:comment></iframe></div>
            </xsl:when>
            <xsl:when test="@mimeType='audio/mpeg'">
                <audio controls="">
                    <source src="{@url}" type="{@mimeType}"/>
                    Your browser does not support the audio tag: <xsl:value-of select="tei:desc"/>
                </audio>
            </xsl:when>
            <xsl:when test="@mimeType='audio/x-ms-wma'">
                <a href="{@url}"><img src="data:image/svg+xml;utf8;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTYuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgd2lkdGg9IjE2cHgiIGhlaWdodD0iMTZweCIgdmlld0JveD0iMCAwIDk2Ljk5MiA5Ni45OTIiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDk2Ljk5MiA5Ni45OTI7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4KPGc+Cgk8cGF0aCBkPSJNODIuMjk3LDE3LjAwMkw2Ni4wMjgsMC43MzJDNjUuNTU5LDAuMjYzLDY0LjkyNCwwLDY0LjI2LDBIMTYuNDYzYy0xLjM4MSwwLTIuNSwxLjExOS0yLjUsMi41djkxLjk5MiAgIGMwLDEuMzgxLDEuMTE5LDIuNSwyLjUsMi41aDY0LjA2NmMxLjM4MSwwLDIuNS0xLjExOSwyLjUtMi41VjE4Ljc2OUM4My4wMjksMTguMTA1LDgyLjc2NiwxNy40NzEsODIuMjk3LDE3LjAwMnogTTQ4LjYzNCw2Mi4yMDkgICBjMCwwLjc3NS0wLjQ0OCwxLjQ4LTEuMTQ5LDEuODExYy0wLjI3MSwwLjEyNy0wLjU2MiwwLjE4OS0wLjg1MSwwLjE4OWMtMC40NTcsMC0wLjkxLTAuMTU2LTEuMjc2LTAuNDZsLTEwLjkzMy05LjA2aC01LjgyMyAgIGMtMS4xMDQsMC0yLTAuODk2LTItMlY0NC43MmMwLTEuMTA0LDAuODk2LTIsMi0yaDUuODIzbDEwLjkzMy05LjA2YzAuNTk4LTAuNDk1LDEuNDI2LTAuNjAxLDIuMTI3LTAuMjcgICBjMC43MDEsMC4zMjksMS4xNDksMS4wMzQsMS4xNDksMS44MVY2Mi4yMDl6IE01Ni4zMTksNTkuMDg0Yy0wLjA0OCwwLjAwMy0wLjA5NywwLjAwNS0wLjE0NCwwLjAwNSAgIGMtMC41MjksMC0xLjAzOS0wLjIwOS0xLjQxNC0wLjU4NmwtMC4yNy0wLjI2OWMtMC43MDEtMC43LTAuNzgzLTEuODExLTAuMTkxLTIuNjA1YzEuNDk2LTIuMDE5LDIuMjg3LTQuNDEzLDIuMjg3LTYuOTI0ICAgYzAtMi43MDEtMC44OTgtNS4yMzQtMi41OTctNy4zMjZjLTAuNjQ2LTAuNzk1LTAuNTg3LTEuOTUsMC4xMzgtMi42NzVsMC4yNjgtMC4yNjhjMC4zOTktMC4zOTksMC45MzYtMC42MTcsMS41MTYtMC41ODMgICBjMC41NjQsMC4wMjgsMS4wOTEsMC4yOTQsMS40NDcsMC43MzFjMi4zNTUsMi44ODMsMy42MDIsNi4zODMsMy42MDIsMTAuMTJjMCwzLjQ3OS0xLjEwMiw2Ljc5NC0zLjE4Myw5LjU4MSAgIEM1Ny40MzIsNTguNzUxLDU2Ljg5OCw1OS4wNDIsNTYuMzE5LDU5LjA4NHogTTY0LjU4OCw2NS4yNjRjLTAuMzYxLDAuNDI4LTAuODg1LDAuNjg2LTEuNDQzLDAuNzA5ICAgYy0wLjAyNywwLTAuMDU3LDAuMDAyLTAuMDg0LDAuMDAyYy0wLjUyOSwwLTEuMDM5LTAuMjExLTEuNDE0LTAuNTg2bC0wLjI2NC0wLjI2NGMtMC43MzQtMC43MzItMC43ODMtMS45MDYtMC4xMTUtMi43MDEgICBjMy4yMjYtMy44MzYsNS4wMDItOC43MDgsNS4wMDItMTMuNzE5YzAtNS4yMTItMS45MDEtMTAuMjI5LTUuMzU0LTE0LjEyOGMtMC43LTAuNzkxLTAuNjY1LTEuOTg5LDAuMDgtMi43MzdsMC4yNjMtMC4yNjMgICBjMC4zODktMC4zOTEsMC44OTUtMC42MDYsMS40NzUtMC41ODhjMC41NTEsMC4wMTYsMS4wNywwLjI1OSwxLjQzOCwwLjY3MWM0LjE3NCw0LjY5OSw2LjQ3MywxMC43NTMsNi40NzMsMTcuMDQ1ICAgQzcwLjY0MSw1NC43Niw2OC40OTEsNjAuNjQxLDY0LjU4OCw2NS4yNjR6IE02Mi4wNTEsMjIuMzQyYy0wLjMzNywwLTAuNjU4LTAuMTMzLTAuODk2LTAuMzcxICAgYy0wLjIzNy0wLjIzOC0wLjM3Mi0wLjU2MS0wLjM3Mi0wLjg5N2wwLjAwMi0xNS4xMjZMNzcuMTgsMjIuMzQzTDYyLjA1MSwyMi4zNDJMNjIuMDUxLDIyLjM0MnoiIGZpbGw9IiMwMDAwMDAiLz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8L3N2Zz4K"><xsl:attribute name="alt"><xsl:value-of select="tei:desc"/></xsl:attribute></img></a>

            </xsl:when>
            <xsl:otherwise>
                <div class="ptext"><strong>Debug: </strong> Unhandled media type.</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:code">
        <span class="monospace"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="tei:eg">
        <blockquote class="eg">
            <pre>
                <code>
                    <xsl:if test="@lang and normalize-space(@lang) != 'code_general'">
                        <xsl:attribute name="class">
                                <xsl:value-of select="@lang"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </code>
            </pre>
        </blockquote>
    </xsl:template>

    <xsl:template match="tei:label">
        <span>
            <xsl:call-template name="assign-class">
                <xsl:with-param name="defaultRend">bold</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:xtext">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:lg">
        <xsl:choose>
            <xsl:when test="ancestor::tei:cit or ancestor::tei:epigraph"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="assign-class"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:l">
        <div>
            <xsl:call-template name="assign-class"/>
        <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:emph|tei:term">
        <em>
            <xsl:call-template name="assign-class"/>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="tei:list">
            <xsl:apply-templates select="tei:head"/>
            <xsl:choose>
                <xsl:when test="parent::tei:p">
                    <xsl:choose>
                <xsl:when test="@type='gloss'">
                    <dl>
                        <xsl:apply-templates mode="gloss" select="tei:item"/>
                    </dl>
                </xsl:when>
                <xsl:when test="@type='inline'">
                    <xsl:apply-templates select="tei:item" mode="inline"/>
                </xsl:when>
                <xsl:when test="@type='unordered'">
                    <ul>
                        <xsl:call-template name="assign-class"/>
                        <xsl:apply-templates select="tei:item"/>
                    </ul>
                </xsl:when>
                <xsl:when test="@type='bibl'">
                    <xsl:apply-templates select="tei:item" mode="bibl"/>
                </xsl:when>
                <xsl:when test="@type='ordered'">
                    <ol>
                        <xsl:call-template name="assign-class"/>
                        <xsl:apply-templates select="tei:item"/>
                    </ol>
                </xsl:when>
                <xsl:when test="@type='simple'">
                    <ul>
                        <xsl:call-template name="assign-class">
                            <xsl:with-param name="defaultRend">simple</xsl:with-param>
                        </xsl:call-template>
                        <xsl:apply-templates select="tei:item"/>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <ul>
                        <xsl:call-template name="assign-class"/>
                        <xsl:apply-templates select="tei:item"/>
                    </ul>
                </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- if list isn't inside a paragraph, wrap it in a <div class="ptext"> for standard display width [CRB] -->
                <xsl:otherwise>
                    <div class="ptext">
                        <xsl:choose>
                            <xsl:when test="@type='gloss'">
                                <dl>
                                    <xsl:apply-templates select="tei:item" mode="gloss"/>
                                </dl>
                            </xsl:when>
                            <xsl:when test="@type='inline'">
                                <xsl:apply-templates select="tei:item" mode="inline"/>
                            </xsl:when>
                            <xsl:when test="@type='unordered'">
                                <ul>
                                    <xsl:call-template name="assign-class"/>
                                    <xsl:apply-templates select="tei:item"/>
                                </ul>
                            </xsl:when>
                            <xsl:when test="@type='bibl'">
                                <xsl:apply-templates select="tei:item" mode="bibl"/>
                            </xsl:when>
                            <xsl:when test="@type='ordered'">
                                <ol>
                                    <xsl:call-template name="assign-class"/>
                                    <xsl:apply-templates select="tei:item"/>
                                </ol>
                            </xsl:when>
                            <xsl:when test="@type='simple'">
                                <ul>
                                    <xsl:call-template name="assign-class">
                                      <xsl:with-param name="addClass">simple</xsl:with-param>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="tei:item"/>
                                </ul>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:call-template name="assign-class"/>
                                    <xsl:apply-templates select="tei:item"/>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:item">
        <li>
            <xsl:call-template name="id"/>
            <xsl:call-template name="assign-class"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="tei:item" mode="gloss">
        <dd>
            <xsl:call-template name="id"/>
            <xsl:call-template name="assign-class"/>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <!-- Support for dhq:appendix removed [CRB] -->
    <!--<xsl:template match="dhq:appendix">
        <div id="appendix">
        <xsl:choose>
            <xsl:when test="tei:head">
                <h1><xsl:value-of select="tei:head"/></h1>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <h1>Appendix</h1>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        </div>
    </xsl:template>-->

    <!-- utilities -->
    <xdoc:doc>Passes xml:id from TEI element to corresponding XHTML element.</xdoc:doc>
    <xsl:template name="id">
        <xsl:if test="@xml:id">
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template name="style">
        <xsl:if test="@style">
            <xsl:attribute name="style">
                <xsl:value-of select="@style"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="id">
        <xsl:value-of select="@xml:id"/>
        <xsl:if test="not(@xml:id)">
            <xsl:value-of select="generate-id()"/>
        </xsl:if>
    </xsl:template>

    <xdoc:doc>
        <xdoc:short>Transfers TEI @rend values to XHTML @class values.</xdoc:short>
        <xdoc:detail>This template assumes a specific encoding practice whereby TEI @rend values are
            analagous to XHTML classes, a whitespace separated list of styles. The template accepts
            a "defaultRend" parameter passed in from the calling template. The default rendition
            values will be concatenated with the content of @rend. So the title template may have a
            defaultRend of "i" (for italics), which could then be combined with additional styles
            listed in @rend, e.g., "u" (for underlined) or "b" (for bold).</xdoc:detail>
    </xdoc:doc>

  <xsl:template name="assign-class">
    <xsl:param name="addClass"/>
    <xsl:param name="defaultRend"/>
    <xsl:variable name="class">
      <xsl:value-of select="local-name()"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@rend"/>
      <xsl:if test="not(normalize-space(@rend))">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$defaultRend"/>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$addClass"/>
    </xsl:variable>
    <xsl:attribute name="class">
      <xsl:value-of select="normalize-space($class)"/>
    </xsl:attribute>
  </xsl:template>

    <xsl:template name="rend">
      <xsl:param name="defaultRend" select="local-name()"/>
      <!-- this needs to be refactored; also this same code appears elsewhere
           e.g. toc.xsl -->
      <!-- presently it appears that @rend = 'none' overrides any class assignment
           set by $defaultRend, so
           @class='{$defaultRend[not(@rend='none')]} {@rend}' -->

      <!-- choose: when @rend is given and not empty add a @class
             choose: when $defaultRend is given and @rend is not 'none' make
                     the value $defaultRend + @rend
                     otherwise make it @rend -->
      <!-- otherwise if there's a $default then add it -->

        <xsl:choose>
            <xsl:when test="@rend and @rend != ''">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$defaultRend != '' and @rend != 'none'">
                            <xsl:value-of select="concat($defaultRend,' ',@rend)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@rend"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$defaultRend !=''">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$defaultRend"/>
                    </xsl:attribute>

                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="preceding-sibling::tei:quote[descendant::tei:sp]">
                <tr><td colspan="2">
                    <!-- if <ref> is a child of <cit>, place parens around it [CRB] -->
                    <xsl:if test="ancestor::tei:cit or ancestor::tei:epigraph"><xsl:text>&#160;(</xsl:text></xsl:if>
                    <xsl:choose>
                        <!-- if <ref> has no target, don't make it a link [CRB] -->
                        <xsl:when test="not(@target)">
                            <xsl:apply-templates mode="scrubbing"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@target, '#')">
                            <xsl:call-template name="internal_ref"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="normalize-space(.)">
                                    <xsl:call-template name="external_ref"/>
                                </xsl:when>
                                <xsl:otherwise><xsl:call-template name="external_ref_empty"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="ancestor::tei:cit or ancestor::tei:epigraph"><xsl:text>)</xsl:text></xsl:if>
                </td></tr>
            </xsl:when>
            <xsl:when test="ancestor::tei:cit[not(parent::tei:p)]/descendant::tei:list">
                <p class="ref">
                <!-- if <ref> is a child of <cit>, place parens around it [CRB] -->
                    <xsl:if test="ancestor::tei:cit or ancestor::tei:epigraph"><xsl:text>&#160;(</xsl:text></xsl:if>
                <xsl:choose>
                    <!-- if <ref> has no target, don't make it a link [CRB] -->
                    <xsl:when test="not(@target)">
                        <xsl:apply-templates mode="scrubbing"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@target, '#')">
                        <xsl:call-template name="internal_ref"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.)">
                                <xsl:call-template name="external_ref"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:call-template name="external_ref_empty"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                    <xsl:if test="ancestor::tei:cit or ancestor::tei:epigraph"><xsl:text>)</xsl:text></xsl:if>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <!-- if <ref> is a child of <cit>, place parens around it [CRB] -->
                <xsl:if test="parent::tei:cit or parent::tei:epigraph"><xsl:text>&#160;(</xsl:text></xsl:if>
                <xsl:choose>
                    <!-- if <ref> has no target, don't make it a link [CRB] -->
                    <xsl:when test="not(@target)">
                        <xsl:apply-templates mode="scrubbing"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@target, '#')">
                        <xsl:call-template name="internal_ref"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.)">
                                <xsl:call-template name="external_ref"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:call-template name="external_ref_empty"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="parent::tei:cit or parent::tei:epigraph"><xsl:text>)</xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="internal_ref">
        <xsl:choose>
            <xsl:when test="substring(@target,2) = //@xml:id">
                <a href="{@target}">
                    <xsl:apply-templates mode="scrubbing"/>
                </a>
            </xsl:when>
            <!-- mark it as an error if target doesn't have a match [CRB] -->
            <xsl:otherwise>
                <span class="error"><a href="{@target}">
                    <xsl:apply-templates mode="scrubbing"/>
                </a></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

  <xsl:template name="external_ref">
    <!-- creating string for opening a function that opens a new window (Ashwini)-->
    <a href="{@target}" onclick="window.open('{@target}'); return false">
      <xsl:call-template name="id"/>
      <xsl:call-template name="assign-class"/>
      <xsl:apply-templates mode="scrubbing"/>
    </a>
  </xsl:template>

  <xsl:template name="external_ref_empty">
    <!-- creating string for opening a function that opens a new window (Ashwini)-->
    <a href="{@target}" onclick="window.open('{@target}'); return false">
      <xsl:call-template name="id"/>
      <xsl:call-template name="assign-class"/>
      <xsl:value-of select="@target"/>
    </a>
  </xsl:template>



    <!-- tables: start -->

    <xsl:template match="tei:table">
        <div>
            <xsl:call-template name="id"/>
            <xsl:attribute name="class">table</xsl:attribute>


            <table>
                <xsl:call-template name="assign-class"/>
                <!--<xsl:call-template name="id"/>-->
                <xsl:apply-templates select="tei:row"/>
            </table>
            <xsl:choose>
                <xsl:when test="tei:head">
                    <xsl:apply-templates select="tei:head" mode="caption"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="label-no-caption"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="label-no-caption">
        <div class="caption-no-label">
            <!-- what is the special case for the xsl:if below? -->
                <div class="label">
                    <xsl:apply-templates select="." mode="label"/>
                    <xsl:text>.&#160;</xsl:text>
                </div>
        </div>
    </xsl:template>


    <xsl:template match="tei:row">
        <tr>
            <xsl:choose>
                <xsl:when test="not(@role = 'data') and not(@role='')">
                    <xsl:call-template name="assign-class">
                        <xsl:with-param name="addClass">
                            <xsl:value-of select="@role"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="assign-class"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="id"/>
            <xsl:call-template name="style"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="tei:cell">
        <td valign="top">
            <xsl:call-template name="id"/>
            <xsl:call-template name="assign-class">
                <xsl:with-param name="addClass" select="string(@role[not(.='data')])"/>
            </xsl:call-template>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@cols"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@rows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rows"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="id"/>
            <xsl:call-template name="style"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <!-- tables: end -->

    <!-- notes -->

    <xsl:template match="tei:note">
        <xsl:apply-templates select="." mode="generated-reference"/>
    </xsl:template>

    <xsl:template match="tei:note" mode="generated-reference">
        <a class="noteRef" href="#{generate-id()}">
            <xsl:text>[</xsl:text>
            <xsl:number level="any" from="tei:body"/>
            <xsl:text>]</xsl:text>
        </a>
    </xsl:template>

    <xsl:template match="tei:note" mode="notes">
        <div class="endnote">
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <span class="noteRef lang en">
                <xsl:text>[</xsl:text>
                <xsl:number level="any" from="tei:body"/>
                <xsl:text>]&#160;</xsl:text>
                <xsl:apply-templates/>
            </span>
        </div>
    </xsl:template>

    <xsl:template match="tei:note" mode="notes_other">
        <xsl:variable name="language"><xsl:value-of select="ancestor::tei:text/@xml:lang"/></xsl:variable>
        <div class="endnote">
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('noteRef lang ', ancestor::tei:text/@xml:lang)"/>
                </xsl:attribute>
                <xsl:text>[</xsl:text>
                <xsl:number level="any" from="//tei:body"/>
                <xsl:text>]&#160;</xsl:text>
                <xsl:apply-templates/>
            </span>
        </div>
    </xsl:template>

    <xsl:template name="notes">
        <xsl:if test="$all-notes">
            <div id="notes">
                <h2>Notes</h2>
                <xsl:for-each select="tei:text">
                    <xsl:if test="ancestor::tei:text">
                        <xsl:variable name="language">
                            <xsl:value-of select="ancestor::tei:text/@xml:lang"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="ancestor::tei:text[@xml:lang='en' or string-length(@xml:lang)=0]">
                                <xsl:apply-templates select=".//tei:note" mode="notes"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select=".//tei:note" mode="notes_other"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:text[@xml:lang='en' or string-length(@xml:lang)=0]">
                        <xsl:apply-templates select="/*/tei:text[@xml:lang='en' or string-length(@xml:lang)=0]//tei:note" mode="notes"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="/*/tei:text[@xml:lang='en' or string-length(@xml:lang)=0]//tei:note" mode="notes_other"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:hi">
        <span>
            <xsl:call-template name="assign-class"/>
            <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- jawalsh: stuff for dhq-annex: start -->
    <xsl:template match="tei:ptr[@type = 'dhq-annex-embed']">
      <div>
      <iframe src="{@target}" style="{@style}">
        <p>Your browser does not support iframes. Embedded document may be found at <a href="{@target}"><xsl:value-of select="@target"/></a>
        </p>
      </iframe>
      <p>
        View embedded content above in its own browser window at: <a href="{@target}"><xsl:value-of select="@target"/></a>.
      </p>
      </div>
    </xsl:template>

    <!-- jawalsh: stuff for dhq-annex: end   -->

    <!-- stuff from wendell: start -->

    <xsl:template match="tei:ptr">
        <!-- may point at anything with an id, including tables, notes, bibls, figures, examples, divs -->
        <xsl:choose>
            <xsl:when test="preceding-sibling::tei:quote[@rend='block']/descendant::tei:list or preceding-sibling::tei:quote[@rend='block']/descendant::tei:sp">
                <xsl:choose>
                    <xsl:when test="key('element-by-id', substring-after(@target, '#'))">
                        <p class="ptr">
                            <xsl:apply-templates select="key('element-by-id', substring-after(@target, '#'))" mode="generated-reference">
                                <xsl:with-param name="loc" select="@loc"/>
                                <!-- pointers to bibl elements accept $loc parameters -->
                            </xsl:apply-templates>
                        </p>
                    </xsl:when>
                    <!-- mark it as an error if target doesn't have a match; may be useful to add a CSS rule
                        (on your local development server) to color red content that has the class "error"
                        to help find broken internal and malformed links [CRB] -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="substring-after(@target, 'http')">
                                <a>
                                    <xsl:attribute name="class">ref</xsl:attribute>
                                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                                    <xsl:value-of select="@target"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="error"><a>
                                    <xsl:attribute name="class">ref</xsl:attribute>
                                    <xsl:attribute name="href"><xsl:choose><xsl:when test="@target"><xsl:value-of select="@target"/></xsl:when>
                                        <xsl:otherwise><xsl:text>#</xsl:text><xsl:value-of select="generate-id()"/></xsl:otherwise></xsl:choose></xsl:attribute>
                                    <xsl:value-of select="@target"/>
                                </a></span></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="ancestor::tei:cit"><xsl:text>&#160;</xsl:text></xsl:if>
                <xsl:choose>
                    <xsl:when test="key('element-by-id', substring-after(@target, '#'))">
                        <xsl:apply-templates select="key('element-by-id', substring-after(@target, '#'))" mode="generated-reference">
                            <xsl:with-param name="loc" select="@loc"/>
                            <!-- pointers to bibl elements accept $loc parameters -->
                        </xsl:apply-templates>
                    </xsl:when>
                    <!-- mark it as an error if target doesn't have a match [CRB] -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="substring-after(@target, 'http')">
                                <a>
                                    <xsl:attribute name="class">ref</xsl:attribute>
                                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                                    <xsl:value-of select="@target"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="error"><a>
                                    <xsl:attribute name="class">ref</xsl:attribute>
                                    <xsl:attribute name="href"><xsl:choose><xsl:when test="@target"><xsl:value-of select="@target"/></xsl:when>
                                        <xsl:otherwise><xsl:text>#</xsl:text><xsl:value-of select="generate-id()"/></xsl:otherwise></xsl:choose></xsl:attribute>
                                    <xsl:value-of select="@target"/>
                                </a></span></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- adjusted to allow for use of existing @id, generate-id() otherwise [CRB] -->
    <xsl:template match="*" mode="generated-reference">
        <a>
            <xsl:attribute name="class">ref</xsl:attribute>
            <xsl:attribute name="href"><xsl:text>#</xsl:text><xsl:choose><xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise></xsl:choose></xsl:attribute>
            <xsl:apply-templates select="." mode="label"/>
        </a>
    </xsl:template>

    <xsl:template match="tei:bibl" mode="generated-reference">
        <xsl:param name="loc" select="false()"/>
        <xsl:text>[</xsl:text>
        <a>
            <xsl:attribute name="class">ref</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:choose>
                    <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="." mode="label"/>
        </a>
        <xsl:if test="$loc">
            <xsl:text>,&#160;</xsl:text>
            <xsl:value-of select="$loc"/>
        </xsl:if>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:bibl" mode="label">
        <xsl:apply-templates select="@label"/>
    </xsl:template>

    <xsl:template match="tei:table" mode="label">
        <xsl:text>Table&#160;</xsl:text>
        <xsl:number level="any" from="tei:text"/>
    </xsl:template>

    <xsl:template match="tei:table/tei:head" mode="label">
        <xsl:text>Table&#160;</xsl:text>
        <xsl:number count="tei:table" level="any" from="tei:text"/>
    </xsl:template>

   <xsl:template match="dhq:example" mode="label">
        <xsl:text>Example&#160;</xsl:text>
        <xsl:number level="any" from="tei:text"/>
    </xsl:template>

    <xsl:template match="dhq:example/tei:head" mode="label">
        <xsl:text>Example&#160;</xsl:text>
        <xsl:number count="//dhq:example/tei:head" level="any" from="tei:text"/>
    </xsl:template>

    <xsl:template match="tei:figure" mode="label">
        <xsl:text>Figure&#160;</xsl:text>
        <xsl:number count="tei:figure[not(ancestor::tei:table)]" level="any" from="tei:text"/>
    </xsl:template>

    <xsl:template match="*" mode="label">
        <xsl:value-of select="local-name()"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:number level="any"/>
    </xsl:template>

    <xsl:template name="bibliography">
        <xsl:if test="/tei:TEI/tei:text/tei:back/tei:listBibl">
            <div id="worksCited">
                <h2>Works Cited</h2>
                <xsl:apply-templates select="/tei:TEI/tei:text/tei:back/tei:listBibl//tei:bibl">
                    <xsl:sort data-type="text" select="(@sortKey, @label)[1]"/>
                    <!-- insert logic for calling biblio -->
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>

  <xsl:template match="tei:listBibl/tei:bibl">
    <div class="bibl">
      <xsl:call-template name="show-bibl-fallback"/>
    </div>
  </xsl:template>

  <xsl:template
    match="tei:label[not(*[not(self::tei:bibl)] | text()[normalize-space(.)])]/tei:bibl |
    tei:item[not(*[not(self::tei:bibl)] | text()[normalize-space(.)])]/tei:bibl">
    <!-- bibl elements appearing inside label with nothing else
         get special treatment: no parens -->
    <span class="bibl">
      <!-- this time show-bibl is not called, so the @label, if any, will not show -->
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:bibl">
      <xsl:text>&#160;(</xsl:text>
      <span class="bibl">
        <xsl:call-template name="show-bibl-fallback"/>
      </span><xsl:text>)&#160;</xsl:text>
    </xsl:template>

  <xsl:template name="show-bibl-fallback">
    <span class="ref">
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:comment> close </xsl:comment>
      <xsl:apply-templates select="@label"/>
    </span>
    <xsl:if test="normalize-space(@label)">
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>


    <xsl:template match="tei:foreign">
        <span>
            <xsl:call-template name="assign-class">
                <xsl:with-param name="defaultRend">i</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- returns a pair of quote marks appropriate to the language and nesting level -->
  <xsl:function name="dhq:quotes" as="xs:string+">
    <xsl:param name="who" as="node()"/>
<!-- $langspec is either $who's nearest ancestor w/ xml:lang, or the root element if no @xml:lang is found.
     The point of $langspec is *only* to determine the scope of counting levels. -->
    <xsl:variable name="langspec" select="$who/ancestor-or-self::*[exists(@xml:lang)][last()]"/>
    <!-- $nominal-lang is the value of xml:lang given ('fr','de','jp' etc etc.) or 'en' if none is found (with deference) -->
    <xsl:variable name="nominal-lang" select="if (exists($langspec)) then ($langspec/@xml:lang) else 'en'"/>

    <!-- $levels are counted among (inline) ancestors that 'toggle' quotes. -->
    <!-- An intervening $langspec has the effect of turning levels off. So a French quote inside an English
         quote restarts with guillemets, while an English quote inside French restarts with double quote. -->
    <!-- Note in this implementation, we exploit the overlapping requirement between French and English to optimize.
         More languages may require more logic. -->

    <!--tei:quote[@rend = 'inline']|tei:called|tei:title[@rend = 'quotes']|tei:q|tei:said|tei:soCalled-->
    <xsl:variable name="scope" select="($langspec | $who/ancestor-or-self::tei:note)[last()]"/>
    <xsl:variable name="levels" select="$who/(ancestor::tei:quote[@rend='inline'] |
                                              ancestor::tei:called | ancestor::soCalled |
                                              ancestor::tei:q | ancestor::said |
                                              ancestor::tei:title[@rend='quotes'])[ancestor-or-self::* intersect $scope]"/>
    <!-- $level-count is 0 for an outermost quote; we increment it unless the language is French -->
    <xsl:variable name="level-count" select="count($levels) + (if (starts-with($nominal-lang,'fr')) then 0 else 1) "/>
    <!-- Now level 0 gets guillemet, while odd-numbered levels get double quotes -->
    <xsl:choose>
    <!-- Note we emit pairs of xsl:text b/c we actually want discrete strings, returning a pair -->
      <xsl:when test="$level-count = 0">
        <xsl:text>«</xsl:text>
        <xsl:text>»</xsl:text>
      </xsl:when>
      <xsl:when test="$level-count mod 2 (: odds :)">
        <xsl:text>“</xsl:text>
        <xsl:text>”</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>‘</xsl:text>
        <xsl:text>’</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:template name="quotes">
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:variable name="quote-marks" select="dhq:quotes(.)"/>
    <xsl:sequence select="$quote-marks[1]"/>
    <xsl:copy-of select="$contents"/>
    <xsl:sequence select="$quote-marks[2]"/>
  </xsl:template>

    <!-- 'scrubbing' mode removes whitespace-only text nodes
         appearing first and last in their parent, to be used
         where cleanup is called for due to extra whitespace
         inserted from editors, such as at the beginning
         of quote, cit and ref elements

         e.g.
           pragmatic books like <name>Susan Hockey’s</name> <ref target="#hockey2000">
             <title rend="italic">Electronic Texts in the Humanities</title>
           </ref> and case-based studies ... (article 1)
    -->
    <xsl:template match="node()" mode="scrubbing">
      <xsl:apply-templates select="."/>
    </xsl:template>

    <!-- Any whitespace-only text will be dropped if it doesn't have a
         preceding sibling text node with content (this can happen when
         comments are present) or element node, or no following sibling
         similarly -->
  <xsl:template mode="scrubbing" priority="2" match="text()[not(normalize-space())]
         [not(preceding-sibling::* | preceding-sibling::text()[normalize-space()]) or
          not(following-sibling::* | following-sibling::text()[normalize-space()])]"/>

  <xsl:template match="dhq:revisionNote">
      <div class="revisionNote">
        <h2 style="font-size:90%;">Revision Note</h2>
        <p>
        <xsl:apply-templates/>
            <xsl:if test="@next">
                The <a href="{concat('/dhq/vol/',$vol_no_zeroes,'/',$issue,'/',substring-before($id,'_'),'/',@next,'.html')}">revised version</a> is available.
            </xsl:if>
            <xsl:if test="@previous">
          The <a href="{concat('/dhq/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'/',@previous,'.html')}">previous version of the article</a> will remain available.
            </xsl:if>

        </p>
      </div>
    </xsl:template>

  <xsl:template match="tei:anchor">
    <a id="{@xml:id}"><xsl:comment>This comment is a hack.</xsl:comment></a>
  </xsl:template>

  <xsl:template match="m:*">
    <xsl:element name="m:{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

    <xsl:template match="dhq:passThroughCode">
<xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dhq:passThroughCode//*">
<xsl:element name="{local-name()}" >
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>

    </xsl:template>


</xsl:stylesheet>
