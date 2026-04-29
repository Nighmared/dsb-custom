--
----Author: xiajun
----Date: 20151020
----
local TSocket = require "TSocket"
local TSocketSSL = require "TSocketSSL"
local TFramedTransport = require "TFramedTransport"
local TBinaryProtocol = require "TBinaryProtocol"
local THttpTransport = require "THttpTransport"

local Object = require "Object"

local RpcClient = Object:new({
	__type = 'RpcClient',
	timeout = 3000,
})

local function IsIpServiceName(ip, serviceName)
	-- verified works aaaaa
	local k8s_suffix = os.getenv("fqdn_suffix")
	return ip == (serviceName .. k8s_suffix)
end

--初始化RPC连接
function RpcClient:init(ip, port, timeout, ssl)
	local serverless = os.getenv("serverless")
	-- below two "lists" of service names could be different in the future
	-- could prepare multiple to be serverless and switch to http, but not
	-- neccessarily deploying all at once on knative
	local dest_is_http = (IsIpServiceName(ip, "user-service") or false)
	local dest_is_knative = serverless and (IsIpServiceName(ip, "user-service") or false)

	if dest_is_knative then
		port = 80 -- make knative happy
	end
	if (ssl == true) then
		socket = TSocketSSL:new {
			host = ip,
			port = port
		}
	else
		socket = TSocket:new {
			host = ip,
			port = port
		}
	end
	socket:setTimeout(timeout)
	local transport = TFramedTransport:new {
		trans = socket
	}
	if dest_is_http then
		transport = THttpTransport:new {
			trans = socket,
			isServer = false,
		}
	end

	local protocol = TBinaryProtocol:new {
		trans = transport
	}
	transport:open()
	return protocol;
end

--创建RPC客户端
function RpcClient:createClient(thriftClient) end

return RpcClient
