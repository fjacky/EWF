note
	description: "Summary description for {EWF_ROUTER_URI_TEMPLATE_PATH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WSF_URI_TEMPLATE_MAPPING

inherit
	WSF_ROUTER_MAPPING

create
	make,
	make_from_string

feature {NONE} -- Initialization

	make_from_string (s: READABLE_STRING_8; h: like handler)
		do
			make (create {URI_TEMPLATE}.make (s), h)
		end

	make (tpl: URI_TEMPLATE; h: like handler)
		do
			template := tpl
			handler := h
		end

feature -- Access		

	handler: WSF_URI_TEMPLATE_HANDLER

	template: URI_TEMPLATE

feature -- Element change

	set_handler	(h: like handler)
		do
			handler := h
		end

feature -- Status

	routed_handler (req: WSF_REQUEST; res: WSF_RESPONSE; a_router: WSF_ROUTER): detachable WSF_HANDLER
		local
			tpl: URI_TEMPLATE
			p: READABLE_STRING_32
			ctx: detachable WSF_URI_TEMPLATE_HANDLER_CONTEXT
		do
			p := source_uri (req)
			tpl := based_uri_template (template, a_router)
			if attached tpl.match (p) as tpl_res then
				Result := handler
				create ctx.make (req, tpl, tpl_res, source_uri (req))
				a_router.execute_before (Current)
				ctx.apply (req)
				handler.execute (ctx, req, res)
				ctx.revert (req)
				a_router.execute_after (Current)
			end
		rescue
			if ctx /= Void then
				ctx.revert (req)
			end
		end

feature {NONE} -- Implementation

	based_uri_template (a_tpl: like template; a_router: WSF_ROUTER): like template
		do
			if attached a_router.base_url as l_base_url then
				Result := a_tpl.duplicate
				Result.set_template (l_base_url + a_tpl.template)
			else
				Result := a_tpl
			end
		end


end
