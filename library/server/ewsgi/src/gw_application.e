note
	description: "Summary description for {GW_APPLICATION}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GW_APPLICATION

feature -- Process request

	process (env: GW_ENVIRONMENT; a_input: GW_INPUT_STREAM; a_output: GW_OUTPUT_STREAM)
			-- Process request with environment `env', and i/o streams `a_input' and `a_output'
		local
			rescued: BOOLEAN
			req: detachable like new_request
			res: detachable like new_request.matching_response
		do
			if not rescued then
				pre_execute (env)
				req := new_request (env, a_input, a_output)
				res := response (req)
				post_execute (req)
			else
				rescue_execute (req, (create {EXCEPTION_MANAGER}).last_exception)
			end
		end

feature {NONE} -- Execution

	response (req: GW_REQUEST): GW_RESPONSE
--		do
--			Result := req.matching_response
--			execute (req, Result)
		deferred
		end

	pre_execute (env: GW_ENVIRONMENT)
			-- Operation processed before `execute'
		require
			env_attached: env /= Void
		do
		end

	post_execute (req: detachable GW_REQUEST)
			-- Operation processed after `execute', or after `rescue_execute'
		do
		end

	rescue_execute (req: detachable GW_REQUEST; a_exception: detachable EXCEPTION)
			-- Operation processed on rescue of `execute'
		do
			if req /= Void and a_exception /= Void and then attached a_exception.exception_trace as l_trace then
				req.matching_response.write_header ({HTTP_STATUS_CODE}.internal_server_error, Void)
				req.matching_response.write_string ("<pre>" + l_trace + "</pre>")
			end
			post_execute (req)
		end

feature -- Factory

	new_request (env: GW_ENVIRONMENT; a_input: GW_INPUT_STREAM; a_output: GW_OUTPUT_STREAM): GW_REQUEST
			-- New Request context based on `env' and `a_input'
			--| note: you can redefine this function to create your own
			--| descendant of GW_REQUEST_CONTEXT , or even to reuse/recycle existing
			--| instance of GW_REQUEST_CONTEXT	
		deferred
		end

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
