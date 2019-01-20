#!/usr/bin/env bash

#is message empty
isEmpty () {
	local _msg="$1"
	[ -z "$_msg" ] && verbose "Cannot find recent message" && echo true || echo false
}

#is message of type asset
isAssetPair () {
	local _assetPair="$1"
	local _msg="$2"
	[ "$(echo "$_msg" | jq --arg _assetPair "$_assetPair" '.type == $_assetPair')" == "true" ] && echo true || echo false
}

#has interval elapsed
isExpired () {
	local _curTime="$1"
	local _lastTime="$2"
	local _expiryInterval="$3"
	local _expiryTime=$(( _curTime - _expiryInterval ))
	local _expirationDif=$(( _expiryTime - _lastTime ))
	[ "$_lastTime" -lt "$_expiryTime" ] && log "Previous price posted at t = $_lastTime is expired by $_expirationDif seconds" && echo true || echo false
}

#is last scuttlebot message published expired 
isMsgExpired () {
	local _msg="$1"
	local _curTime
	local _lastTime
	_curTime=$(timestampS)
	_lastTime=$(( $(echo "$_msg" | jq '.time') / 1000 ))
	[ "$(isExpired "$_curTime" "$_lastTime" "$OMNIA_MSG_EXPIRY_INTERVAL")" == "true" ] && echo true || echo false
}

#is last price update to Oracle expired
isOracleExpired () {
	local _assetPair="$1"
	local _curTime
	local _lastTime
	_curTime=$(timestampS)
	_lastTime=$(pullOracleTime "$_assetPair")
	[ "$(isExpired "$_curTime" "$_lastTime" "$OMNIA_ORACLE_EXPIRY_INTERVAL")" == "true" ] && echo true || echo false
}

#is spread greater than specified spread limit
isStale () {
	local _oldPrice="$1"
	local _newPrice="$2"
	local _spreadLimit="$3"
	local _spread
	_spread=$(setzer spread "$_oldPrice" "$_newPrice")
	log "Old Price = ${_oldPrice}   New Price = ${_newPrice}"
	log "-> spread = $_spread"
	test=$(bc <<< "${_spread#-} >= ${_spreadLimit}")
	#DEBUG
	verbose "spread = ${_spread#-}"
	verbose "spread limit = ${_spreadLimit}"

	[[ ${test} -ne 0 ]] && log "Spread is greater than ${_spreadLimit}" && echo true || echo false
}

#is spread between existing Scuttlebot price greatner than spread limit
isMsgStale () {
	local _oldPriceMsg="$1"
	local _newPrice="$2"
	local _oldPrice
	_oldPrice=$(echo "$_oldPriceMsg" | jq '.price')
	[ "$(isStale "$_oldPrice" "$_newPrice" "$OMNIA_MSG_SPREAD")" == "true" ] && echo true || echo false
}

#is spread between existing Oracle price greater than spread limit
isOracleStale () {
	local _assetPair="$1"
	local _newPrice="$2"
	local _oldPrice
	_oldPrice=$(pullOraclePrice "$_assetPair")
	[ "$(isStale "$_oldPrice" "$_newPrice" "$OMNIA_ORACLE_SPREAD")" == "true" ] && echo true || echo false
}

#is timestamp of message more recent than timestamp of last Oracle update
isMsgNew () {
	local _assetPair="$1"
	local _msg="$2"
	local _msgTime
	local _oracleTime
	_oracleTime=$(pullOracleTime "$_assetPair")
	_msgTime=$(( $(echo "$_msg" | jq '.time') / 1000 ))
	[ "$_oracleTime" -gt "$_msgTime" ] && verbose "Message is older than last Oracle update, skipping..." && echo false || echo true
}

#are there enough feed messages to establish quorum
isQuorum () {
	local _assetPair="$1"
	local _numFeeds="$2"

	local _quorum
	#get min number of feeds requored for quorum from Oracle contract
	#note we cant trust users not to run modified clients
	#so whether quorum is achieved is reinforced in the contract
	_quorum=$(pullOracleQuorum "$_assetPair")
	verbose "quorum for $_assetPair = $_quorum feeds"

	#DEBUG
	verbose "number of feeds counted = $_numFeeds"

	[ "$_numFeeds" -ge "$_quorum" ] && echo true || ( echo false && verbose "Could not reach quorum ($_quorum), only $_numFeeds feeds reporting." )
}