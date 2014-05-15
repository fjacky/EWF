note
	description : "[
			Object representing Authorization http header
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC2617 HTTP Authentication: Basic and Digest Access Authentication", "protocol=URI", "src=http://tools.ietf.org/html/rfc2617"
	EIS: "name=Wikipedia Basic Access Authentication", "protocol=URI", "src=http://en.wikipedia.org/wiki/Basic_access_authentication"
	EIS: "name=Wikipedia Digest Access Authentication", "protocol=URI", "src=http://en.wikipedia.org/wiki/Digest_access_authentication"

class
	HTTP_AUTHORIZATION

inherit
	REFACTORING_HELPER

	DEBUG_OUTPUT

create
	make,
	make_basic_auth,
	make_custom_auth

feature -- Initialization

	make (a_http_authorization: READABLE_STRING_8)
			-- Initialize `Current'.
			-- Parse authorization header.
			--
			-- TODO What should we do if
			-- 		argument is void
			--		empty
			--		neither a Basic nor a Digest authorization
			--		not a VALID Basic or Digest authorization (i.e., starts with "Basic" or "Digest", but does not have proper format)?
			--
			-- TODO `is_bad_request' if non-optional field not quoted or empty...
		require
			-- We do not accept any authentication except Digest and Basic.
			known_authentication: a_http_authorization.has_substring ("Digest") or a_http_authorization.has_substring ("Basic")
		local
			i: INTEGER
			t, s: STRING_8
			u,p: READABLE_STRING_32
			utf: UTF_CONVERTER
			empty_string_8: STRING_8
		do
			create empty_string_8.make_empty

			password := Void

			create http_authorization.make_from_string (a_http_authorization)
			create t.make_empty
			type := t

			if not a_http_authorization.is_empty then
				i := 1
				if a_http_authorization[i] = ' ' then
					i := i + 1
				end
				i := a_http_authorization.index_of (' ', i)
				if i > 0 then
					t.append (a_http_authorization.substring (1, i - 1))
					t.right_adjust; t.left_adjust
					if t.same_string (Basic_auth_type) then
						type := Basic_auth_type
						s := (create {BASE64}).decoded_string (a_http_authorization.substring (i + 1, a_http_authorization.count))
						i := s.index_of (':', 1) --| Let's assume ':' is forbidden in login ...
						if i > 0 then
							u := utf.utf_8_string_8_to_string_32 (s.substring (1, i - 1)) -- UTF_8 decoding to support unicode username
							p := utf.utf_8_string_8_to_string_32 (s.substring (i + 1, s.count)) -- UTF_8 decoding to support unicode password
							login := u
							password := p
							check
								(create {HTTP_AUTHORIZATION}.make_custom_auth (u, p, t)).http_authorization ~ http_authorization
							end
						end
					else
						check
							t.same_string (Digest_auth_type)
						end

						type := Digest_auth_type

						-- XXX Why do we know here that a_http_authorization is attached?
						-- XXX Find out difference between being void and being attached, lear more about void safety etc.

						-- TODO Improve parsing (be more restrictive).

						-- Try to parse the fields, and set them to the epmty string if they didn't match our expectations.

						-- Parse response
						response_value := get_header_value_by_key (a_http_authorization, "response")
						if
							attached response_value as attached_response_value and then
							attached_response_value.count /= 34
						then
							-- Response is not valid, set it to empty string.
							response_value := empty_string_8
						end
						response_value := unquote_string (response_value)

						-- Parse login
						login := get_header_value_by_key (a_http_authorization, "username")
						login := unquote_string (login)

						-- Parse realm
						-- XXX Add further tests for validity of realm value.
						realm_value := get_header_value_by_key (a_http_authorization, "realm")
						realm_value := unquote_string (realm_value)

						-- Parse nonce
						nonce_value := get_header_value_by_key (a_http_authorization, "nonce")
						nonce_value := unquote_string (nonce_value)

						-- Parse uri
						uri_value := get_header_value_by_key (a_http_authorization, "uri")

						-- Parse qop
						qop_value := get_header_value_by_key (a_http_authorization, "qop")
						if
							attached qop_value as attached_qop_value and then
							not (attached_qop_value.is_equal ("auth") or attached_qop_value.is_equal ("auth-int"))
						then
							qop_value := empty_string_8
						end

						-- Parse algorithm
						algorithm_value := get_header_value_by_key (a_http_authorization, "algorithm")
						check
							is_MD5: not attached algorithm_value as attached_algorithm_value or else (attached_algorithm_value.is_empty or attached_algorithm_value.is_case_insensitive_equal ("MD5"))
						end
						-- TODO Check that it is one of the algorithms supplied in the WWW_Authenticate response header.

						-- Parse nc
						nc_value := get_header_value_by_key (a_http_authorization, "nc")
						-- TODO Make sure that it is in hex format.
						-- Make sure it has length 8.

						-- Parse cnonce
						cnonce_value := get_header_value_by_key (a_http_authorization, "cnonce")
						cnonce_value := unquote_string (cnonce_value)

						-- Parse opaque
						opaque_value := get_header_value_by_key (a_http_authorization, "opaque")
						opaque_value := unquote_string (opaque_value)
					end
				end
			end
		ensure
			a_http_authorization /= Void implies http_authorization /= Void

--			a_http_authorization.has_substring ("Basic") or a_http_authorization.has_substring ("basic") or a_http_authorization.has_substring ("Digest") or a_http_authorization.has_substring ("digest")
--			a_http_authorization.has_substring ("Basic") or a_http_authorization.has_substring ("basic") or a_http_authorization.has_substring ("Digest") or a_http_authorization.has_substring ("digest")
--			type.is_case_insensitive_equal (basic_auth_type) or type.is_case_insensitive_equal (digest_auth_type)
--			(a_http_authorization.has_substring ("Basic") or a_http_authorization.has_substring ("basic")) implies type.is_case_insensitive_equal (basic_auth_type)
--			(a_http_authorization.has_substring ("Digest") or a_http_authorization.has_substring ("digest")) implies type.is_case_insensitive_equal (digest_auth_type)

		end

	make_basic_auth (u: READABLE_STRING_32; p: READABLE_STRING_32)
			-- Create a Basic authentication.
		do
			io.putstring ("HTTP_AUTHORIZATION.make_basic_auth()%N")

			make_custom_auth (u, p, Basic_auth_type)
		end

	make_custom_auth (u: READABLE_STRING_32; p: READABLE_STRING_32; a_type: READABLE_STRING_8)
			-- Create a custom `a_type' authentication.
		require
			a_type_accepted: a_type.is_case_insensitive_equal (Basic_auth_type)
							or a_type.is_case_insensitive_equal (Digest_auth_type)
		local
			t: STRING_8
			utf: UTF_CONVERTER
		do
			io.putstring ("HTTP_AUTHORIZATION.make_custom_auth()%N")

			login := u
			password := p
			create t.make_from_string (a_type)
			t.left_adjust; t.right_adjust
			type := t
			if t.is_case_insensitive_equal (Basic_auth_type) then
				type := Basic_auth_type
				create http_authorization.make_from_string ("Basic " + (create {BASE64}).encoded_string (utf.string_32_to_utf_8_string_8 (u + {STRING_32} ":" + p)))
			elseif t.is_case_insensitive_equal (Digest_auth_type) then
				type := Digest_auth_type
				to_implement ("HTTP Authorization %""+ t +"%", not yet implemented")
				create http_authorization.make_from_string (t + " ...NOT IMPLEMENTED")
			else
				to_implement ("HTTP Authorization %""+ t +"%", not yet implemented")
				create http_authorization.make_from_string ("Digest ...NOT IMPLEMENTED")
			end
		end

feature -- Access

	http_authorization: IMMUTABLE_STRING_8

	-- We always have a type.
	type: READABLE_STRING_8


	-- The remaining fields are SHOULD be void if type is "Basic",
	-- and MUST NOT be void if type is "Digest".
	-- If type is "Digest", then some fields may be empty.

	login: detachable READABLE_STRING_8

	password: detachable READABLE_STRING_8

	realm_value: detachable READABLE_STRING_8

	nonce_value: detachable READABLE_STRING_8

	nc_value: detachable READABLE_STRING_8

	cnonce_value: detachable READABLE_STRING_8

	qop_value: detachable READABLE_STRING_8

	response_value: detachable READABLE_STRING_8

	opaque_value: detachable READABLE_STRING_8

	uri_value: detachable READABLE_STRING_8

	algorithm_value: detachable READABLE_STRING_8

feature -- Status report

	is_basic: BOOLEAN
			-- Is Basic authorization?
		do
			Result := type.is_case_insensitive_equal (Basic_auth_type)
		end

	is_digest: BOOLEAN
			-- Is Basic authorization?
		do
			Result := type.is_case_insensitive_equal (Digest_auth_type)
		end

	is_authorized(server_username: READABLE_STRING_8; server_password: detachable READABLE_STRING_8; server_realm: detachable READABLE_STRING_8;
				server_nonce_list: detachable ARRAYED_LIST[STRING_8]; server_method: detachable READABLE_STRING_8; server_uri: detachable READABLE_STRING_8;
				server_algorithm: detachable READABLE_STRING_8; entity_body: detachable READABLE_STRING_8; server_qop: detachable READABLE_STRING_8): BOOLEAN
			-- Validates authentication.
			--
			-- Here we need the values which the server has sent in the WWW-Authenticate header.
			--
			-- TODO `server_nonce_list' should also contain latest nonce-count values from client.
			-- TODO uri may be changed by proxies. Which uri should we take, the one from the request or the one from the authorization-header?
			-- TODO This method could be modified s.t. it does not take the cleartext password as an argument.
			-- TODO Be more flexible: Do not only support auth, MD5 etc.			
		require
			not_auth_int: not attached server_qop as attached_server_qop or else attached_server_qop.is_case_insensitive_equal ("auth")
			is_MD5: not attached server_algorithm or else server_algorithm.is_case_insensitive_equal ("MD5")
		local
			HA1: STRING_8
			HA2: STRING_8
			response_expected: STRING_8
			nonce_found: BOOLEAN
		do
			-- Basic
			if 	type.is_case_insensitive_equal (basic_auth_type) then
				if
					attached password as attached_password and
					attached login as attached_login and
					attached server_password as attached_server_password
				then
					Result := attached_password.is_case_insensitive_equal (attached_server_password) and attached_login.is_case_insensitive_equal (server_username)
				end
			else
				check
					is_digest: type.is_case_insensitive_equal (digest_auth_type)
				end

				if
					attached realm_value as attached_realm_value and
					attached response_value as attached_response_value and
					attached server_password as attached_server_password and
					attached server_username as attached_server_username and
					attached server_realm as attached_server_realm and
					attached server_method as attached_server_method and
					attached server_uri as attached_server_uri and
					attached server_nonce_list as attached_server_nonce_list and
					attached nonce_value as attached_nonce_value
				then
					-- Do we know the nonce from the Authorization-header?
					-- XXX The following could be optimized, for example move to other position, start at end etc.
					from
						attached_server_nonce_list.start
					until
						attached_server_nonce_list.exhausted
					loop

						nonce_found := nonce_found or attached_server_nonce_list.item.is_case_insensitive_equal (attached_nonce_value)
						attached_server_nonce_list.forth
					end

					if
						attached_server_nonce_list.last.is_case_insensitive_equal (attached_nonce_value)
					then
						-- The nonce is the one we expected.
						HA1 := compute_hash_a1 (attached_server_username, attached_server_realm, attached_server_password, server_algorithm, attached_nonce_value)

						HA2 := compute_hash_a2 (attached_server_method, attached_server_uri, server_algorithm, entity_body, server_qop, false)

						response_expected := compute_expected_response (HA1, HA2, attached_nonce_value, server_qop, server_algorithm, nc_value, cnonce_value)

						Result := response_expected.is_equal (attached_response_value)
					elseif
						nonce_found
						-- FIXME
					then
						-- The nonce is not the one we expected.
						-- Maybe it is in the list of nonces from the client.
						-- Then, the nonce could just be stale, and the user agent doesn't have to prompt for the credentials again.
						-- The result is false anyway.

						HA1 := compute_hash_a1 (attached_server_username, attached_server_realm, attached_server_password, server_algorithm, attached_nonce_value)

						HA2 := compute_hash_a2 (attached_server_method, attached_server_uri, server_algorithm, entity_body, server_qop, false)

						response_expected := compute_expected_response (HA1, HA2, attached_nonce_value, server_qop, server_algorithm, nc_value, cnonce_value)

						stale := response_expected.is_equal (attached_response_value)

						io.putstring ("Nonce is not the expected one. Stale: " + stale.out + "%N")
					else
						io.putstring ("We don't know this nonce:%N   " + attached_nonce_value + ".%N")
						io.putstring ("We only know those:%N")

						from
							attached_server_nonce_list.start
						until
							attached_server_nonce_list.exhausted
						loop
							io.putstring ("   " + attached_server_nonce_list.item + ".%N")
							attached_server_nonce_list.forth
						end
					end
				else
					io.putstring ("Could not compute expected response since something was not attached.")
				end
			end
		end

	is_quoted (s: STRING_32): BOOLEAN
		-- Returns type iff `s' begins and ends with a quote sign.
		do
			-- Also test that lenght is greater than one, otherwise the string could consist of just one quote sign.
			Result := s.starts_with ("%"") and s.ends_with ("%"") and (s.count >= 2)
		end

	debug_output: STRING_32
			-- String that should be displayed in debugger to represent `Current'.
		do
			create Result.make_empty
			Result.append (type)
			Result.append (" ")
			if attached login as l_login then
				Result.append ("login=[")
				Result.append (l_login)
				Result.append ("] ")
			end
			if attached password as l_password then
				Result.append ("password=[")
				Result.append (l_password)
				Result.append ("] ")
			end
		end

	is_bad_request: BOOLEAN
			-- True, if there was a syntactical error in the digest-response.
			-- If a directive or its value is improper, or required directives are missing,
			-- the proper response is 400 Bad Request.
			--
			-- TODO Make more use of this.

	stale: BOOLEAN
			-- True iff authorization was stale.

feature -- Digest computation

	compute_hash_A1 (server_username: READABLE_STRING_8; server_realm: READABLE_STRING_8; server_password: READABLE_STRING_8; server_algorithm: detachable READABLE_STRING_8; server_nonce: READABLE_STRING_8): STRING_8
			-- Compute H(A1).
			-- TODO Support for MD5-sess and other algorithms.
		require
			is_digest: is_digest
			is_MD5: not attached server_algorithm or else server_algorithm.is_case_insensitive_equal ("MD5")
		local
			hash: MD5
			A1: READABLE_STRING_8
		do
			create hash.make

			A1 := server_username + ":" + server_realm + ":" + server_password

			hash.update_from_string (A1);

			Result := hash.digest_as_string

			Result.to_lower

--			io.putstring ("Computed HA1: " + Result + "%N")
		end

	compute_hash_A2 (server_method: READABLE_STRING_8; server_uri: READABLE_STRING_8; server_algorithm: detachable READABLE_STRING_8;  entity_body: detachable READABLE_STRING_8; server_qop: detachable READABLE_STRING_8; for_auth_info: BOOLEAN): STRING_8
			-- Compute H(A2)
			-- TODO Support auth-int
			--
			-- `for_auth_info' MUST be set to True iff  we compute the hash for the Authentication-Info header.
		require
			not_auth_int: not attached server_qop as attached_server_qop or else attached_server_qop.is_case_insensitive_equal ("auth")
			is_MD5: not attached server_algorithm or else server_algorithm.is_case_insensitive_equal ("MD5")
		local
			hash: MD5
			A2: READABLE_STRING_8
		do
			-- Special treatment of Authentication-Info header.
			if for_auth_info then
				A2 := ":" + server_uri
			else
				A2 := server_method + ":" + server_uri
			end

			create hash.make

			hash.update_from_string (A2)

			Result := hash.digest_as_string

			Result.to_lower

--			io.putstring ("Computed HA2: " + Result + "%N")
		end

	compute_expected_response(ha1: READABLE_STRING_8; ha2: READABLE_STRING_8; server_nonce: READABLE_STRING_8; server_qop: detachable READABLE_STRING_8; server_algorithm: detachable READABLE_STRING_8; a_nc: detachable READABLE_STRING_8; a_cnonce: detachable READABLE_STRING_8) : STRING_8
			-- Computes UNQUOTED expected response.
			-- TODO Support for
		require
			not_auth_int: not attached server_qop as attached_server_qop or else attached_server_qop.is_case_insensitive_equal ("auth")
			is_MD5: not attached server_algorithm or else server_algorithm.is_case_insensitive_equal ("MD5")
		local
			hash: MD5
			unhashed_response: READABLE_STRING_8
		do
			create Result.make_empty

			-- TODO Delete the following lines
--			cnonce_value := "%"0a4f113b%""

			if
				attached server_qop as attached_server_qop
			then
				if
					attached a_nc as attached_nc_value and
					attached a_cnonce as attached_cnonce_value
				then
					-- Standard (for digest) computation of response.

					create hash.make

					unhashed_response := ha1 + ":" + server_nonce + ":" + attached_nc_value + ":" + attached_cnonce_value + ":" + attached_server_qop + ":" + ha2

--					io.put_string ("Expected unhashed response: " + unhashed_response)
--					io.new_line

					hash.update_from_string (unhashed_response)

					Result := hash.digest_as_string

					Result.to_lower

--					io.put_string ("Expected unquoted response: " + Result)
--					io.new_line
				end
			else
				-- qop directive is not present.
				-- Use construction for backwards compatibility with RFC 2069

				create hash.make

				unhashed_response := ha1 + ":" + server_nonce + ":" + ha2

				hash.update_from_string (unhashed_response)

				Result := hash.digest_as_string

				Result.to_lower

				io.put_string ("RFC 2069 mode. Expected unquoted response: " + Result)
				io.new_line
			end
		end


feature -- Access

	get_header_value_by_key(h: READABLE_STRING_8; k: STRING_8): READABLE_STRING_8
			-- From header `h', get value associated to key `k'.
			-- Returns empty string if `h' does not contain such a value.
		local
			i,j: INTEGER
			result_string: STRING
		do
			-- We assume that each key-value pair begins with a space and ends with '='.
			i := h.substring_index (" " + k + "=", 1)

			if i = 0 then
				create result_string.make_empty

				Result := result_string

				io.putstring ("Parsed " + k +": empty string%N")
			else
				i := h.index_of ('=', i)

				j :=  h.index_of (',', i + 1)

				-- Special treatment of last pair, since it is not terminated by a coma.
				if j = 0 and i > 0 then
					j := h.count + 1
				end

				check
					not(i+1 > j-1 or i = 0 or j = 0)
				end

				Result := h.substring (i+1, j-1)

--				io.putstring ("Parsed " + k +": " + Result + "%N")
			end
		end

	unquote_string(s: detachable READABLE_STRING_8): STRING_8
			-- Returns string without quotes.
			-- If `s' is not quoted, or not attached, returns empty string.
			--
			-- Do not set `is_bad_request', because maybe the field was optional.
		local
			i, j: INTEGER
			rs: STRING_32
		do
			if
				attached s as attached_s
			then
				create rs.make_from_string (attached_s)

				rs.left_adjust
				rs.right_adjust

				i := rs.index_of ('"', 1)
				j := rs.index_of ('"', i+1)

				if i+1 > j-1 or i = 0 or j = 0 then
					io.putstring ("Not able to unquote string: " + attached_s + "%N")
					create Result.make_empty
				else
					Result := rs.substring (i+1, j-1)
				end
			else
				io.putstring ("Not able to unquote string: Void%N")
				create Result.make_empty
			end
		end

--	get_unquoted_string(s: STRING_32) : STRING_32
--			-- If the original string contains quotes, then remove the quotes.
--		do
--			if s.has ('"') then
--				Result := unquote_string (s)
--			else
--				Result := s
--			end
--		end

feature -- Element change

--	set_Void_if_unquoted (s: detachable READABLE_STRING_32): detachable READABLE_STRING_32
--			-- Set `s' to Void if it is not quoted
--		do
--			if
--				attached s as attached_s and then
--				not is_quoted (attached_s)
--			then
--				-- Login is not valid, set it to void.
--				Result := Void
--			else
--				Result := s
--			end
--		end

feature -- Constants

	Basic_auth_type: STRING_8 = "Basic"
	Digest_auth_type: STRING_8 = "Digest"

invariant
	type_valid: is_digest or is_basic
	digest_well_formed: is_digest implies
		(
		attached response_value as attached_response_value and then not attached_response_value.is_empty and
		attached login as attached_login and then not attached_login.is_empty and
		attached realm_value as attached_realm and then not attached_realm.is_empty and
		attached nonce_value as attached_nonce_value and then not attached_nonce_value.is_empty and
		attached uri_value as attached_uri_value and then not attached_uri_value.is_empty and
			(
				((attached qop_value as attached_qop_value and then not attached_qop_value.is_empty) implies
					(attached cnonce_value as attached_cnonce_value and then not attached_cnonce_value.is_empty) and
					(attached nc_value as attached_nc_value and then not attached_nc_value.is_empty)
				) and
				((not attached qop_value as attached_qop_value or else attached_qop_value.is_empty) implies
					(not attached cnonce_value as attached_cnonce_value or else attached_cnonce_value.is_empty) and
					(not attached nc_value as attached_nc_value or else attached_nc_value.is_empty))
			)

		)
	supported_qop: attached qop_value as attached_qop_value implies attached_qop_value.is_empty or attached_qop_value.is_case_insensitive_equal ("auth")
	supported_algorithm: attached algorithm_value as attahced_algorithm_value implies attahced_algorithm_value.is_empty or attahced_algorithm_value.is_case_insensitive_equal ("MD5")
end
