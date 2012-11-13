<cfcomponent output="false">
  
  <cffunction name="init" access="public" output="false" returntype="any">
    <cfreturn this />
  </cffunction>

  <cffunction name="serialize" access="public" output="false" returntype="string">
    <cfargument name="array" type="array" required="true" />
    <cfreturn serializeJSON(this.pack(arguments.array)) />
  </cffunction>

  <cffunction name="deserialize" access="public" output="false" returntype="array">
    <cfargument name="string" type="string" required="true" />
    <cfreturn this.unpack(deserializeJSON(arguments.string)) />
  </cffunction>
  
  <cffunction name="pack" access="public" output="false" returntype="array">
    <cfargument name="array" type="array" required="true" />
    <cfscript>
      var loc = {};

      loc.keys = (arguments.array.len()) ? structKeyArray(arguments.array[1]).sort("textnocase") : [];
      loc.result = [];

      loc.result.append(loc.keys.len());
      loc.result.append(loc.keys, true);

      for (loc.i = 1; loc.i lte arguments.array.len(); loc.i++)
      {
        for (loc.j = 1; loc.j lte loc.keys.len(); loc.j++)
        {
          loc.result.append(arguments.array[loc.i][loc.keys[loc.j]]);
        }
      }
    </cfscript>
    <cfreturn loc.result />
  </cffunction>
  
  <cffunction name="unpack" access="public" output="false" returntype="array">
    <cfargument name="array" type="array" required="true" />
    <cfscript>
      var loc = {};

      loc.length = arguments.array.len();
      loc.keyLength = (loc.length) ? arguments.array[1] : 0;
      loc.result = [];

      loc.i = 2 + loc.keyLength;

      while (loc.i lte loc.length)
      {
        loc.struct = {};
        loc.j = 1;

        while (loc.j lte loc.keyLength)
        {
          loc.j++;
          loc.struct[arguments.array[loc.j]] = arguments.array[loc.i];
          loc.i++;
        }

        loc.result.append(loc.struct);
      }
    </cfscript>
    <cfreturn loc.result />
  </cffunction>

</cfcomponent>