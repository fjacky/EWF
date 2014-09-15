note
	description: "Summary description for {HTTPD_SERVER_I}."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_SERVER_I

inherit
	HTTPD_DEBUG_FACILITIES

	HTTPD_LOGGER

feature {NONE} -- Initialization

	make (a_factory: like factory)
			-- `a_cfg': server configuration
			-- `a_factory': connection handler builder
		do
			make_configured (create {like configuration}.make, a_factory)
		end

	make_configured (a_cfg: like configuration; a_factory: like factory)
			-- `a_cfg': server configuration
			-- `a_factory': connection handler builder
		do
			configuration := a_cfg
			factory := a_factory

			build_controller

			initialize
		end

	build_controller
			-- Build `controller'.
		do
			create controller
		end

	initialize
			-- Initialize Current server.
		do
			is_shutdown_requested := False
		end

feature	-- Access

	is_verbose: BOOLEAN
			-- Is verbose for output messages.

	configuration: HTTPD_CONFIGURATION
			-- Associated server configuration.

	controller: separate HTTPD_CONTROLLER

	factory: separate HTTPD_REQUEST_HANDLER_FACTORY

feature -- Access: listening

	port: INTEGER
			-- Effective listening port.
			--| If 0 then it is not launched successfully!

feature -- Status: listening

	is_launched: BOOLEAN
			-- Server launched and listening on `port'	

	is_terminated: BOOLEAN
			-- Is terminated?

	is_shutdown_requested: BOOLEAN
			-- Set true to stop accept loop

feature {NONE} -- Access: server

	request_counter: INTEGER
			-- request counter, incremented for each new incoming connection.			

feature -- Execution

	launch
		do
			apply_configuration
			is_terminated := False
			if is_verbose then
				log ("%N%NStarting Web Application Server (port=" + configuration.http_server_port.out + "):%N")
			end
			is_shutdown_requested := False
			listen
			on_terminated
		end

	on_terminated
		require
			is_terminated
		do
			if is_terminated then
				log ("%N%NTerminating Web Application Server (port="+ port.out +"):%N")
			end
			if attached output as o then
				o.flush
				o.close
			end
		end

	shutdown_server
		do
			debug ("dbglog")
				dbglog ("Shutdown requested")
			end
			is_shutdown_requested := True
			controller_shutdown (controller)
		end

	controller_shutdown (ctl: attached like controller)
		do
			ctl.shutdown
		end

feature -- Listening

	listen
			-- <Precursor>
			-- Creates a socket and connects to the http server.
			-- `a_server': The main server object
		local
			l_listening_socket,
			l_accepted_socket: detachable HTTPD_STREAM_SOCKET
			l_http_port: INTEGER
			l_connection_handler: HTTPD_CONNECTION_HANDLER
		do
			is_terminated := False
			is_launched := False
			port := 0
			is_shutdown_requested := False
			l_http_port := configuration.http_server_port

			if
				attached configuration.http_server_name as l_servername and then
				attached (create {INET_ADDRESS_FACTORY}).create_from_name (l_servername) as l_addr
			then
				l_listening_socket := new_listening_socket (l_addr, l_http_port)
			else
				l_listening_socket := new_listening_socket (Void, l_http_port)
			end

			if not l_listening_socket.is_bound then
				if is_verbose then
					log ("Socket could not be bound on port " + l_http_port.out)
				end
			else
				l_http_port := l_listening_socket.port
				create l_connection_handler.make (Current)
				from
					l_listening_socket.listen (configuration.max_tcp_clients)
					if is_verbose and then configuration.is_secure then
						log ("%NHTTP Connection Server ready on port " + l_http_port.out +" : https://localhost:" + l_http_port.out + "/")
					elseif is_verbose then
						log ("%NHTTP Connection Server ready on port " + l_http_port.out +" : http://localhost:" + l_http_port.out + "/")
					end
					on_launched (l_http_port)
				until
					is_shutdown_requested
				loop
					l_listening_socket.accept
					if not is_shutdown_requested then
						l_accepted_socket := l_listening_socket.accepted
						if l_accepted_socket /= Void then
							request_counter := request_counter + 1
							if is_verbose then
								log ("#" + request_counter.out + "# Incoming connection...(socket:" + l_accepted_socket.descriptor.out + ")")
							end
							debug ("dbglog")
								dbglog (generator + ".before process_incoming_connection {" + l_accepted_socket.descriptor.out + "}" )
							end
							l_connection_handler.process_incoming_connection (l_accepted_socket)
							debug ("dbglog")
								dbglog (generator + ".after process_incoming_connection {" + l_accepted_socket.descriptor.out + "}")
							end
						end
					end
					update_is_shutdown_requested (l_connection_handler)
				end
				wait_for_connection_handler_completion (l_connection_handler)
				l_listening_socket.cleanup
				check
					socket_is_closed: l_listening_socket.is_closed
				end
			end
			if is_launched then
				on_stopped
			end
			if is_verbose then
				log ("HTTP Connection Server ends.")
			end
		rescue
			log ("HTTP Connection Server shutdown due to exception. Please relaunch manually.")

			if l_listening_socket /= Void then
				l_listening_socket.cleanup
				check
					listening_socket_is_closed: l_listening_socket.is_closed
				end
			end
			if is_launched then
				on_stopped
			end
			is_shutdown_requested := True
			retry
		end

feature {NONE} -- Factory

	new_listening_socket (a_addr: detachable INET_ADDRESS; a_http_port: INTEGER): HTTPD_STREAM_SOCKET
		do
			if a_addr /= Void then
				create Result.make_server_by_address_and_port (a_addr, a_http_port)
			else
				create Result.make_server_by_port (a_http_port)
			end
		end

feature {NONE} -- Helpers

	wait_for_connection_handler_completion (h: HTTPD_CONNECTION_HANDLER)
		do
			h.wait_for_completion
			debug ("dbglog")
				dbglog ("Shutdown ready from connection_handler point of view")
			end
		end

	update_is_shutdown_requested (a_connection_handler: HTTPD_CONNECTION_HANDLER)
		do
			is_shutdown_requested := is_shutdown_requested or shutdown_requested (controller)
			if is_shutdown_requested then
				a_connection_handler.shutdown
			end
		end

	shutdown_requested (a_controller: separate HTTPD_CONTROLLER): BOOLEAN
			-- Shutdown requested on concurrent `a_controller'?
		do
			Result := a_controller.shutdown_requested
		end

feature -- Event

	on_launched (a_port: INTEGER)
			-- Server launched using port `a_port'
		require
			not_launched: not is_launched
		do
			is_launched := True
			port := a_port
		ensure
			is_launched: is_launched
		end

	on_stopped
			-- Server stopped
		require
			is_launched: is_launched
		do
			is_launched := False
			is_terminated := True
		ensure
			stopped: not is_launched
		end

feature -- Configuration change

	apply_configuration
		require
			is_not_launched: not is_launched
		do
			is_verbose := configuration.is_verbose
		end

feature -- Output

	output: detachable FILE

	set_log_output (f: FILE)
		do
			output := f
		end

	log (a_message: separate READABLE_STRING_8)
			-- Log `a_message'
		local
			m: STRING
		do
			create m.make_from_separate (a_message)
			if attached output as o then
				o.put_string (m)
				o.put_new_line
			else
				io.error.put_string (m)
				io.error.put_new_line
			end
		end

note
	copyright: "2011-2014, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
