<cfcomponent>
<!---
	
	saferJSON for ColdFusion version 1.0
	
	Copyright © 2014 Charles Fahey (http://charlesfahey.tumblr.com)
	
	MIT license (enjoy!)
	
	https://github.com/cfaheyCurveJumper/saferJSON-cfc
	
--->
<cfoutput>

	<!---
		
		isValid( testStr [, strict] )
		
		Tests the validity of a JSON string more accurately than isJSON().
		v1.0 by Charles Fahey (http://charlesfahey.tumblr.com)
		
		Returns:
		boolean value indicating whether the string is valid JSON (true) or is not valid (false)
		
		Parameters:
		testStr		a JSON string to be tested for vailidity
		strict		a boolean value. Default is false. When set to true: takes a practice run at deserializing the JSON string. Use sparingly.
		
		Usage:
		isValid( '{ "jsonStr" : "this is valid" }' )
		
	--->
	<cffunction name="isValid" access="public" output="no" returnType="boolean">

		<cfargument name="testStr" type="string" required="true" default="">
		<cfargument name="strict" type="boolean" required="true" default="false">

		<cfset var returnBool = false>
		<cfset var garbageVar = "">
		<cfset var stringUtil = "">

		<!--- clean up our test string --->
		<cfset arguments.testStr = trim( arguments.testStr )>

		<!--- if we have a string to test --->
		<cfif len( arguments.testStr )>

			<!---
				IF ColdFusion thinks it's JSON ( isJSON() )
				AND it looks like either an array OR a struct
				AND the number of opening and closing brakets are equal
			--->
			<cfset returnBool = (
				isJSON( arguments.testStr )
				AND (
					( left( arguments.testStr, 1 ) IS "[" AND right( arguments.testStr, 1 ) IS "]" )
					OR ( left( arguments.testStr, 1 ) IS "{" AND right( arguments.testStr, 1 ) IS "}" )
				)
			)>

			<!--- if we passed basic validation --->
			<cfif returnBool>

				<!--- connect to the java string utility --->
				<cfset stringUtil = createobject( "java", "org.apache.commons.lang.StringUtils" )>

				<!--- count the number of opening braces --->
				<cfset openSqrCnt = stringUtil.countMatches( arguments.testStr, "[" )>
				<cfset openCurlCnt = stringUtil.countMatches( arguments.testStr, "{" )>

				<!--- and closing --->
				<cfset closeSqrCnt = stringUtil.countMatches( arguments.testStr, "]" )>
				<cfset closeCurlCnt = stringUtil.countMatches( arguments.testStr, "}" )>

				<!--- if the number of opening brackets equals the number of closing, we're still good --->
				<cfset returnBool = (
					( openSqrCnt EQ closeSqrCnt )
					AND ( openCurlCnt EQ closeCurlCnt )
				)>

			</cfif>

			<!--- if we passed basic validation and are using the "strict" test --->
			<cfif returnBool AND arguments.strict>

				<!--- we will actually try deserializing with ColdFusion to see what happens --->
				<cftry>
					<cfset garbageVar = deserializeJSON( arguments.testStr )>
					<cfcatch type="any">
						<!--- if it cannot be deserialized, it's effectively not JSON --->
						<cfset returnBool = false>
					</cfcatch>
				</cftry>
			</cfif>

		</cfif>

		<cfreturn returnBool>

	</cffunction>



	<!---
		
		parse( jsonStr )
		
		Deserializes a JSON string, or fails gracefully if the string cannot be deserialized.
		v1.0 by Charles Fahey (http://charlesfahey.tumblr.com)
		
		Returns:
		1) An object (array or struct) if deserialization was successful;
		2) If deserialization failed, returns the original string it was given ( jsonStr ).
		
		Parameters:
		jsonStr		a JSON string to be deserialized
		
		Usage:
		parse( '{ "jsonStr" : "this is valid" }' )
		
	--->
	<cffunction name="parse" access="public" output="no" returnType="any">

		<cfargument name="jsonStr" type="string" required="true" default="">

		<!--- if deserialization fails, we'll return the JSON string --->
		<cfset var returnVal = trim( arguments.jsonStr )>

		<!--- if this seems like valid JSON --->
		<cfif THIS.isValid( arguments.jsonStr )>

			<!--- try to deserialize it --->
			<cftry>

				<cfset returnVal = deserializeJSON( trim( arguments.jsonStr ) )>

				<cfcatch type="any">
					<!--- if it broke, just move on, we'll spit the JSON string right back to them --->
				</cfcatch>
			</cftry>

		</cfif>

		<cfreturn returnVal>

	</cffunction>

</cfoutput>
</cfcomponent>
