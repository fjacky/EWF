note
	description: "Summary description for {GW_AGENT_APPLICATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GW_AGENT_APPLICATION

inherit
	GW_APPLICATION_IMP

create
	make

feature {NONE} -- Implementation

	make (a_callback: like callback)
			-- Initialize `Current'.
		do
			callback := a_callback
		end

feature {NONE} -- Implementation

	callback: FUNCTION [ANY, TUPLE [req: like new_request], GW_RESPONSE]
			-- Procedure called on `execute'

	response (req: like new_request): GW_RESPONSE
		do
			Result := callback.item ([req])
		end

invariant
	callback_attached: callback /= Void

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
