	<target name="${APPNAME}_any" extends="_common">
		<root class="${APP_ROOT}" feature="make_and_launch"/>
		<library name="cgi" location="$ISE_LIBRARY\contrib\library\web\framework\ewf\wsf\connector\cgi-safe.ecf"/>
		<library name="libfcgi" location="$ISE_LIBRARY\contrib\library\web\framework\ewf\wsf\connector\libfcgi-safe.ecf"/>
		<library name="nino" location="$ISE_LIBRARY\contrib\library\web\framework\ewf\wsf\connector\nino-safe.ecf"/>
		<cluster name="launcher" location=".\launcher\any\" recursive="true"/>
		<cluster name="src" location=".\src\" recursive="true"/>
	</target>
