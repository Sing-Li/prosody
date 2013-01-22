-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local datamanager = require "util.datamanager";
local usermanager = require "core.usermanager";
local new_sasl = require "util.sasl".new;

local log = module._log;
local host = module.host;

-- define auth provider
local provider = {};
log("debug", "initializing internal_plain authentication provider for host '%s'", host);

function provider.test_password(username, password)
	log("debug", "test password '%s' for user %s at host %s", password, username, host);
	local credentials = datamanager.load(username, host, "accounts") or {};

	if password == credentials.password then
		return true;
	else
		return nil, "Auth failed. Invalid username or password.";
	end
end

function provider.get_password(username)
	log("debug", "get_password for username '%s' at host '%s'", username, host);
	return (datamanager.load(username, host, "accounts") or {}).password;
end

function provider.set_password(username, password)
	local account = datamanager.load(username, host, "accounts");
	if account then
		account.password = password;
		return datamanager.store(username, host, "accounts", account);
	end
	return nil, "Account not available.";
end

function provider.user_exists(username)
	local account = datamanager.load(username, host, "accounts");
	if not account then
		log("debug", "account not found for username '%s' at host '%s'", username, host);
		return nil, "Auth failed. Invalid username";
	end
	return true;
end

function provider.users()
	return datamanager.users(host, "accounts");
end

function provider.create_user(username, password)
	return datamanager.store(username, host, "accounts", {password = password});
end

function provider.delete_user(username)
	return datamanager.store(username, host, "accounts", nil);
end

function provider.get_sasl_handler()
	local getpass_authentication_profile = {
		plain = function(sasl, username, realm)
			local password = usermanager.get_password(username, realm);
			if not password then
				return "", nil;
			end
			return password, true;
		end
	};
	return new_sasl(host, getpass_authentication_profile);
end
	
module:provides("auth", provider);

