note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	HELLO_WORLD

create
	make

feature {NONE} -- Initialization

	make
		do
			print ("Example: start a Nino web server on port " + port_number.out + ", %Nand reply Hello World for any request such as http://localhost:8123/%N")
			(create {GW_NINO_APPLICATION}.make_custom (agent response, "")).listen (port_number)
		end

	response (req: GW_REQUEST): GW_RESPONSE
		do
			Result := req.matching_response
			Result.output.put_header (200, <<["Content-Type", "text/plain"]>>)
			Result.output.put_string ("Hello World!%N")
		end

	port_number: INTEGER = 8123

note
	copyright: "2011-2011, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
