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
	if IsIpServiceName(ip, "user-service") then
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
