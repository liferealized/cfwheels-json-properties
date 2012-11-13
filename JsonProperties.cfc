<cfcomponent output="false" mixin="model">

	<cffunction name="init" output="false" access="public" returntype="any">
		<cfset this.version = "1.0,1.1,1.1.8" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="jsonProperty" output="false" access="public" returntype="void">
		<cfargument name="properties" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="array" hint="The JSON type may be set to `array` or `struct`. The default is `array`. All other values will be ignored." />
		<cfargument name="pack" type="boolean" required="false" default="false" hint="If you are storing homoginized query like data set pack to `true`." />
		<cfargument name="gzip" type="boolean" required="false" default="false" />
		<cfscript>
			var loc = {};
			
			if (!StructKeyExists(variables.wheels.class, "jsonProperties"))
				variables.wheels.class.jsonProperties = {};

			if (!StructKeyExists(variables.wheels.class, "gzip"))
				variables.wheels.class.gzip = CreateObject("component", "plugins.jsonproperties.gzip.Gzip").init();

			if (!StructKeyExists(variables.wheels.class, "jsonh"))
				variables.wheels.class.jsonh = CreateObject("component", "plugins.jsonproperties.jsonh.jsonh").init();
			
			if (StructKeyExists(arguments, "property"))
				arguments.properties = arguments.property;

			for (loc.property in listToArray(arguments.properties))
				variables.wheels.class.jsonProperties[loc.property] = { type = arguments.type, pack = arguments.pack, gzip = arguments.gzip };
			
			afterFind(method="$deserializeJSONProperties");
			afterInitialization(method="$deserializeJSONProperties");
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
					this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item].type);
				if (!IsSimpleValue(this[loc.item]) and !IsBinary(this[loc.item]))
				{
					if (variables.wheels.class.jsonProperties[loc.item].pack)
					{
						this[loc.item] = variables.wheels.class.jsonh.serialize(this[loc.item]);
					}
					else
					{
						this[loc.item] = SerializeJSON(this[loc.item]);
					}
					
					if (variables.wheels.class.jsonProperties[loc.item].gzip)
						this[loc.item] = variables.wheels.class.gzip.deflate(this[loc.item]);
				}
			}
		</cfscript>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="$deserializeJSONProperties" output="false" access="public" returntype="boolean">
		<cfscript>
			var loc = { connectionArgs = this.$hashedConnectionArgs() };

			if (isNew() and (!StructKeyExists(request.wheels.transactions, loc.connectionArgs) or !request.wheels.transactions[loc.connectionArgs])) 
				return true;

			if (IsInstance())
			{
				for (loc.item in variables.wheels.class.jsonProperties)
				{

					if (!StructKeyExists(this, loc.item))
						this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item].type);

					if (variables.wheels.class.jsonProperties[loc.item].gzip and isBinary(this[loc.item]))
						this[loc.item] = variables.wheels.class.gzip.inflate(this[loc.item]);

					if (variables.wheels.class.jsonProperties[loc.item].pack and IsSimpleValue(this[loc.item]) and Len(this[loc.item]) and isJSON(this[loc.item]))
						this[loc.item] = variables.wheels.class.jsonh.deserialize(this[loc.item]);

					if (IsSimpleValue(this[loc.item]) and Len(this[loc.item]) and isJSON(this[loc.item]))
						this[loc.item] = DeserializeJSON(this[loc.item]);
				}
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
	
	<cffunction name="$convertToString" returntype="string" access="public" output="false">
		<cfargument name="value" type="Any" required="true">
		<cfscript>
			if (IsBinary(arguments.value))
				return ToString(arguments.value);
			else if (IsDate(arguments.value))
				return CreateDateTime(year(arguments.value), month(arguments.value), day(arguments.value), hour(arguments.value), minute(arguments.value), second(arguments.value));
			else if (IsArray(arguments.value) || IsStruct(arguments.value))
				return SerializeJSON(arguments.value);
		</cfscript>
		<cfreturn arguments.value>
	</cffunction>	

</cfcomponent>


