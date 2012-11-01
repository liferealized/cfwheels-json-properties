<h1>JSON Properties</h1>

<p>
	The JSON properties plugin allows you to easily add structured data to a single database table field. You can easily store arrays and structures without the need for extra tables in your model.
</p>

<p>The JSON properties plugin has a single initialization method that you must call in your models <code>init()</code>.</p>

<h2>Init Method</h2>
<ul>
	<li>jsonProperty
		<ul>
			<li><strong>property</strong> - the model property the serialize and deserialize when interacting with the database.</li>
			<li><strong>type</strong> - possible values include array or struct.</li>
		</ul>
	</li>
</ul>

Once you have initialized your model, there is no extra work required to start using the functionality of this plugin.



<h2>How to Use</h2>

<p>
	Simply add structure data to your JSON property. That's it!
</p>

<h2>Interal workings</h2>
<p>The JSON proerties plugin works by adding callbacks to the initialized model to transparently serialize/deserialize complex data types into strings that 
	can be stored in a database.</p>
<h2>Callbacks Added</h2>
<ul>
	<li>$deserializeJSONProperties is called on AferFind and AfterSave</li>
	<li>$serializeJSONProperties is called on BeforeValidation and BeforeDelete</li>
</ul>

<h2>Uninstallation</h2>
<p>To uninstall this plugin simply delete the <tt>/plugins/AssetBundler-0.9.zip</tt> file.</p>

<h2>Credits</h2>
<p>This plugin was created by <a href="http://iamjamesgibson.com">James Gibson</a>.</p>


<p><a href="<cfoutput>#cgi.http_referer#</cfoutput>">&lt;&lt;&lt; Go Back</a></p>