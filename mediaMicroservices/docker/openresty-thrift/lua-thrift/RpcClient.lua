--
----Author: xiajun
----Date: 20151020
----
local TSocket = require "TSocket"
local TFramedTransport = require "TFramedTransport"
local TBinaryProtocol = require "TBinaryProtocol"
local THttpTransport = require "THttpTransport"
local Object = require "Object"
local ngx = ngx


local RpcClient = Object:new({
	__type = 'RpcClient',
	timeout = 1001,
	readTimeout = 500
})


function IsIpServiceName(ip, serviceName)
	-- verified works aaaaa
	local k8s_suffix = os.getenv("fqdn_suffix")
	return ip == (serviceName .. k8s_suffix)
end

--初始化RPC连接
function RpcClient:init(ip, port)
	local socket = TSocket:new {
		host = ip,
		port = port,
		readTimeout = self.readTimeout
	}
	socket:setTimeout(self.timeout)


	local transport = TFramedTransport:new {
		trans = socket
	}
	-- SWITCHING FOR THESIS :))
	-- XXX hellou
	if IsIpServiceName(ip, "text-service") then
		transport = THttpTransport:new {
			trans = socket,
			isServer = false,
		}
	end
	-- done with mucking around :)

	local protocol = TBinaryProtocol:new {
		trans = transport
	}
	transport:open()
	return protocol;
end

--创建RPC客户端
function RpcClient:createClient(thriftClient) end

return RpcClient
