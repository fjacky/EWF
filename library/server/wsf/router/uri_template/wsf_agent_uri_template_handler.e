note
	description: "Summary description for {WSF_AGENT_URI_TEMPLATE_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WSF_AGENT_URI_TEMPLATE_HANDLER

inherit
	WSF_URI_TEMPLATE_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_action: like action)
		do
			action := a_action
		end

	action: PROCEDURE [ANY, TUPLE [context: WSF_URI_TEMPLATE_HANDLER_CONTEXT; request: WSF_REQUEST; response: WSF_RESPONSE]]

feature -- Execution

	execute (ctx: WSF_URI_TEMPLATE_HANDLER_CONTEXT; req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			action.call ([ctx, req, res])
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
