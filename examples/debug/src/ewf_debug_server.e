note
	description: "[
				application service
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_DEBUG_SERVER

inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end

	APPLICATION_LAUNCHER

create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			set_service_option ("verbose", True)
			set_service_option ("port", 9090)
			set_service_option ("base", "/www-debug/debug_service.fcgi")
		end

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			dbg: WSF_DEBUG_HANDLER
			m: WSF_PAGE_RESPONSE
		do
			create dbg.make
			dbg.execute_starts_with ("", req, res)
			--create m.make_with_body ("This is ewf debug")
			--res.send (m)
		end

end

