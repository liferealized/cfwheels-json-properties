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

			if (!StructKeyExists(variables.wheels.class, "gzip") and arguments.gzip)
				variables.wheels.class.gzip = CreateObject("component", "plugins.jsonproperties.gzip.Gzip").init();

			if (!StructKeyExists(variables.wheels.class, "jsonh") and arguments.pack)
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

	<cffunction name="hasChanged" access="public" output="false" returntype="boolean">
		<cfargument name="property" type="string" required="false" default="" />
		<cfscript>
			var loc = {};

			// always return true if $persistedProperties does not exists
			if (!StructKeyExists(variables, "$persistedProperties"))
				return true;

			if (!Len(arguments.property))
			{
				// they haven't specified a particular property so loop through
				// them all
				arguments.property = StructKeyList(variables.wheels.class.properties);
			}

			arguments.property = ListToArray(arguments.property);

			loc.iEnd = ArrayLen(arguments.property);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				loc.key = arguments.property[loc.i];
				if (StructKeyExists(this, loc.key))
				{
					if (!StructKeyExists(variables.$persistedProperties, loc.key))
					{
						return true;
					}
					else
					{
						// hehehehe... convert each datatype to a string
						// for easier comparision
						loc.a = $convertToString(this[loc.key]);
						loc.b = $convertToString(variables.$persistedProperties[loc.key]);

						if(Compare(loc.a, loc.b) neq 0)
						{
							return true;
						}
					}
				}
			}
		</cfscript>
		<cfreturn false>
	</cffunction>

	<cffunction name="$convertToString" returntype="string" access="public" output="false">
		<cfargument name="value" type="Any" required="true">
		<cfargument name="type" type="string" required="false" default="">
		<cfscript>
			var loc = {};
			
			if (!len(arguments.type))
			{
				if (IsArray(arguments.value))
				{
					arguments.type = "array";
				}
				else if (IsStruct(arguments.value))
				{
					arguments.type = "struct";
				}
				else if (IsBinary(arguments.value))
				{
					arguments.type = "binary";
				}
				else if (IsNumeric(arguments.value))
				{
					arguments.type = "integer";
				}
				else if (IsDate(arguments.value))
				{
					arguments.type = "datetime";
				}
			}
			
			switch (arguments.type)
			{
				case "array": case "struct":
					arguments.value = serializeJSON(arguments.value);
					break;
				case "binary":
					arguments.value = ToString(arguments.value);
					break;
				case "float": case "integer":
					arguments.value = Val(arguments.value);
					break;
				case "boolean":
					arguments.value = ( arguments.value IS true );
					break;
				case "datetime":
					// createdatetime will throw an error
					if(IsDate(arguments.value))
					{
						arguments.value = CreateDateTime(year(arguments.value), month(arguments.value), day(arguments.value), hour(arguments.value), minute(arguments.value), second(arguments.value));
					}
					break;
			}
		</cfscript>
		<cfreturn arguments.value>
	</cffunction>

</cfcomponent>


