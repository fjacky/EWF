note
	description: "Summary description for {WSF_ROUTER_MAPPING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WSF_ROUTER_MAPPING

feature -- Access		

	handler: WSF_HANDLER
		deferred
		end

feature -- Status

	routed_handler (req: WSF_REQUEST; res: WSF_RESPONSE; a_router: WSF_ROUTER): detachable WSF_HANDLER
		deferred
		end

feature -- Helper

	source_uri (req: WSF_REQUEST): READABLE_STRING_32
			-- URI to use to find handler.
		do
			Result := req.path_info
		end

note
	copyright: "2011-2012, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
