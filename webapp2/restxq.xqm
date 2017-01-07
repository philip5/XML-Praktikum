(:~
 : This module contains some basic examples for RESTXQ annotations
 : @author BaseX Team
 :)
module namespace page = 'http://basex.org/modules/web-page';
import module namespace m= "mancala/model" at "static/mancalaMethods.xqm";








(:~
 : This function generates the welcome page.
 : @return HTML page
 :)
 (:
 declare
  %rest:path("")
  %rest:single
  
 function page:search() {
 
 
let $in :=
  <books>
    <book>
      <title>XSLT Programmer’s Reference</title> 
      <author>Michael H. Kay</author> 
    </book>
    <book>
      <title>XSLT</title> 
      <author>Doug Tidwell</author> 
      <author>Simon St. Laurent</author>
      <author>Robert Romano</author>
    </book>
  </books>
let $style :=
  <xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
  <xsl:output method='xml'/>
    <xsl:template match="/">
<html>
  <body>
    <div>
      <xsl:for-each select='books/book'>
      <b><xsl:apply-templates select='title'/></b>: <xsl:value-of select='author'/><br/>
      </xsl:for-each>
    </div>
  </body>
</html>
    </xsl:template>
  </xsl:stylesheet>
 
return xslt:transform($in, $style) 
 };

 declare
  %rest:path("")
  %rest:query-param("term", "{$term}")
  %rest:single
function page:search($term) {
  <ul>{
    for $result in db:open('mancalaDB2')//*
    return <li>{ $result }</li>
  }</ul>
  
  
};

 :)
 
 
 
 
 
 
 
 
 declare
  %rest:path("")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  
  
  function page:start()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
 
 <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    </head>
    <body>
 <h3>Hello to Mancala</h3>
      <p>Please Press Submit to continue:</p>
      <form method="post" action="form">
        <p>Have Fun:<br />
       
        <input type="submit" /></p>
      </form>

 </body>
  </html>
};
 
 (:
 declare
  %rest:path("/form")
  %rest:POST
  %rest:form-param("message","{$message}", "(no message)")
  %rest:header-param("User-Agent", "{$agent}")
  
  function page:hello-postman(
    $message as xs:string,
    $agent   as xs:string*)
    as element(response)
{
  <response type='form'>
    <message>{ $message }</message>
    <user-agent>{ $agent }</user-agent>
  </response>

};


:)

declare
  %rest:path("/clicked")
  %rest:query-param("ID", "{$ID}")
  %rest:query-param("gameID", "{$gameID}")
  
  %updating function page:clicked(
    $ID as xs:int, $gameID as xs:int) 
    (:as element(response):)
	{
	
	(db:output(page:search($gameID)),m:executeMove($ID,$gameID))
	
		
	
		
  (:<response>{
	{$fGameState}
  }</response>:)
};



declare
  %rest:path("/clickednewgame")
 
   %updating function page:clickednewgame() 
    
	{
	
	(:let $fGameState := db:output(m:finalGameState()), m:checkGameOver(0)
	:)
	
	
	(db:output(page:search(0)),(m:insertGame(m:newGame())))
		
		
     
		
  (:<response>{
	{$fGameState}
  }</response>:)
};




declare
  %rest:path("/loadcon")
  
  function page:loadcon() 
    
	{
	
	page:search(0)
		

};




(:
declare
  %rest:path("/clicked")
  %rest:GET
  %rest:form-param("ID","{$ID}", 0)
 function page:clicked($ID as xs:int)
	{
	
	<ul>{
		let $in := (db:open('mancalaDB2'))
		{m:intermediateGameState($ID,0)}
		let $style := doc('static/mancalaXSLT.xsl')
		
		for $result in xslt:transform($in, $style)
		
		return (
			<li>{ $result }</li>)
			}</ul>
	
	
	
		<game> {
		return {m:intermediateGameState($ID,0)}
		}</game>
		
		
		{m:executeMove($ID,0)}
		{page:search()}
		
		
		
		
		
		<ul>{
		let $in := (db:open('mancalaDB2'))
		let $style := doc('static/mancalaXSLT.xsl')
		
		for $result in xslt:transform($in, $style)
		
		return (
		<li>{ $result }</li>)
		}</ul>
			
			
		
	
	};:)

 declare
  %rest:path("/form")
  %rest:single
  
 function page:home() {
	<ul>{
		let $in := (db:open('mancalaDB2'))
		let $style := doc('static/mancalaXSLT.xsl')
		
		for $result in xslt:transform($in, $style)
		
		return (
			<li>{ $result }</li>)
			}</ul>
			
			
 };
 (:
 declare
  %rest:path("/form")
  %rest:single
  
 function page:home() {
 <ul>{
 let $x := (m:newGame())
 let $y := (m:insertGame(x))
 
 for $result in page:search($y)
 
 return (
			<li>{ $result }</li>)
			}</ul>
			
			
			
 };
:)
 declare
  %rest:path("/form2")
  %rest:single
  %rest:query-param("gameID","{$gameID}")
 function page:search($gameID as xs:integer) {
	<ul>{
		let $in := (db:open("mancalaDB2")//collection/game[@gameID=$gameID])
		let $style := doc('static/mancalaXSLT.xsl')
		
		for $result in xslt:transform($in, $style)
		
		return (
			<li>{ $result }</li>)
			}</ul>
			
			
 };
 (:
 declare
  %rest:path("/form")
  %rest:single
  
 %updating function page:search() {
	
		
		db:replace("mancalaDB2", /static/mancalaGameState,(xslt:transform((db:open('mancalaDB2')), doc('static/mancalaXSLT.xsl'))))
		
		
			
 };
 :)
 
 
 
 
 
 
 
 
 
(: declare
  %rest:path("")
  %rest:single("EXPENSIVE")
function page:compute() {
   xslt:transform((db:open('mancalaDB2')),
  <xsl:stylesheet version = "2.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
    <xsl:output method= "xml" indent = "yes" omit-xml-declaration = "yes" />
    <xsl:template match = "mancalaXSLT"></xsl:template>
  </xsl:stylesheet>
  )
}; :)


(:
declare
  %rest:path("")
  %rest:single("EXPENSIVE")
function page:compute() {
   xslt:transform(doc("/home/ioannis/Desktop/Mancala.xml"),
  <xsl:stylesheet version = "2.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
    <xsl:output method= "xml" indent = "yes" omit-xml-declaration = "yes" />
    <xsl:template match = "mancalaXSLT"></xsl:template>
  </xsl:stylesheet>
  )
};

 
 
 declare
  %rest:path("")
  %rest:query-param("game", "{$term}")

function page:search($term (:as xs:string:)) {
  <ul>{
    for $result in db:open('mancalaDB2')
	
	
	
	
    return 
	xslt:transform(db:open('mancalaDB2'),
  <xsl:stylesheet version = "2.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
    <xsl:output method= "xml" indent = "yes" omit-xml-declaration = "yes" />
    <xsl:template match = "mancalaXSLT"></xsl:template>
  </xsl:stylesheet>
)
  }</ul>
};

:)