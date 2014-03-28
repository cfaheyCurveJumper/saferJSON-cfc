saferJSON for ColdFusion
========================

**The problem(s)**
As any ColdFusion dev can tell you, working with JSON in ColdFusion is like feeding yourself soup with a razor blade. Blood everywhere.

The problem is exemplified by the fact that ColdFusion's isJSON() function doesn't protect the deserializeJSON() function from erroring out.

This code should be bullet-proof, but it isn't:

	<!--- if this is a valid JSON string --->
	<cfif isJSON( your_string )>
		
		<!--- deserialize the JSON string (since it's valid) --->
		<cfset your_new_object = deserializeJSON( your_string )>
	
	</cfif>

*Problem 1*

In ColdFusion, if you try to deserialize a string that is not valid JSON you will receive a hard error. Ideally, deserialization should fail gracefully. 

*Problem 2*

Furthermore, the isJSON() method should only return true for strings that can actually be deserialized.

**The Solution(s)**

For these reasons, I've created a ColdFusion CFC (safeJSON.cfc) which has two methods--one for better JSON validation, and one for more graceful deserialization.

*Solution 1: parse( str )*

You can use the parse() method to gracefully deserialize your JSON string, like so:

	<!--- initiate our cfc --->
	<cfobject name="json" component="safeJSON">
	
	<!--- deserialize the JSON string (whether it's valid or not) --->
	<cfset your_new_object = json.parse( your_string )>

If the JSON string cannot be deserialized, the method returns the same string it was given.

*Solution 2: isValid( str )*

If you still need to test the validity of a JSON string, you can use the isValid() method. 

Note: This method tests against the two structures defined as valid JSON at json.org (http://www.json.org). It is stricter than isJSON(), so things like integers will no longer pass as JSON.

Use it like this:

	<!--- initiate our cfc --->
	<cfobject name="json" component="safeJSON">
	
	<!--- test our string --->
	<cfset is_this_JSON = json.isValid( your_string )>

*Solution 2 STRICT: isValid( str, true )*

If you really want to test whether or not ColdFusion will be able to deserialize it, you can also call it like this:

	<!--- initiate our cfc --->
	<cfobject name="json" component="safeJSON">
	
	<!--- test our string using "strict" mode --->
	<cfset is_this_JSON = json.isValid( your_string, true )>

Adding the boolean "true" as the second parameter tells the isValid() method to actually practice deserializing the string. Upside: totally accurate as to whether or not the string is safe for deserialization. Downside: Extra overhead and redundancy. You should rarely need the strict option.

In any event, I hope this helps some of you as much as it's helped me.

**Requires ColdFusion 10+**
