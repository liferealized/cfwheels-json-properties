<cfcomponent output="false" mixin="model">

	<cffunction name="init" output="false" access="public" returntype="any">
		<cfset this.version = "1.0,1.1" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="jsonProperty" output="false" access="public" returntype="void">
		<cfargument name="property" type="string" required="true" />
		<cfargument name="type" type="string" required="false" default="array" hint="The JSON type may be set to `array` or `struct`. The default is `array`. All other values will be ignored." />
		<cfscript>
			var loc = {};
			
			if (!StructKeyExists(variables.wheels.class, "jsonProperties"))
				variables.wheels.class.jsonProperties = {};
				
			variables.wheels.class.jsonProperties[arguments.property] = arguments.type;
			
			afterFind(method="$deserializeJSONProperties");
			afterSave(method="$deserializeJSONProperties");
			beforeValidation(method="$serializeJSONProperties");
			beforeDelete(method="$serializeJSONProperties");
		</cfscript>
	</cffunction>
	
	<cffunction name="hasChanged" output="false" access="public" returntype="boolean">
		<cfargument name="property" type="string" required="false" default="">
		<cfscript>
			var returnValue = false;
			var coreHasChanged = core.hasChanged;
			if (StructKeyExists(variables.wheels.class, "jsonProperties"))
				$serializeJSONProperties();
			returnValue = coreHasChanged(argumentCollection=arguments);
			if (StructKeyExists(variables.wheels.class, "jsonProperties") && !$callingFromCrud())
				$deserializeJSONProperties();
		</cfscript>
		<cfreturn returnValue />
	</cffunction>
	
	<cffunction name="$serializeJSONProperties" output="false" access="public" returntype="boolean">
		<cfscript>
			var loc = {};
			for (loc.item in variables.wheels.class.jsonProperties)
			{
				if (!StructKeyExists(this, loc.item))
					this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
				if (!IsSimpleValue(this[loc.item]))
					this[loc.item] = SerializeJSON(this[loc.item]);
			}
		</cfscript>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="$deserializeJSONProperties" output="false" access="public" returntype="boolean">
		<cfscript>
			var loc = {};
			for (loc.item in variables.wheels.class.jsonProperties)
			{
				if (!StructKeyExists(this, loc.item))
					this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
				if (StructIsEmpty(arguments) and IsSimpleValue(this[loc.item]))
					this[loc.item] = DeserializeJSON(this[loc.item]);
			}
		</cfscript>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="$setDefaultObject" output="false" access="public" returntype="any">
		<cfargument name="type" type="string" required="true" />
		<cfscript>
			var returnObject = [];
			if (arguments.type == "struct")
				returnObject = {};
		</cfscript>
		<cfreturn returnObject />
	</cffunction>	
	
	<cffunction name="$callingFromCrud" output="false" access="public" returntype="boolean">
		<cfscript>
			var loc = {};
			loc.returnValue = false;
			loc.stackTrace = CreateObject("java", "java.lang.Throwable").getStackTrace();
			
			loc.iEnd = ArrayLen(loc.stackTrace);
			for (loc.i = 1; loc.i lte loc.iEnd; loc.i++)
			{
				loc.fileName = loc.stackTrace[loc.i].getFileName();
				if (StructKeyExists(loc, "fileName") && !FindNoCase(".java", loc.fileName) && !FindNoCase("<generated>", loc.fileName) && FindNoCase("crud.cfm", loc.fileName))
				{
					loc.returnValue = true;
					break;
				}
			}
		</cfscript>
		<cfreturn loc.returnValue />
	</cffunction>

</cfcomponent>


