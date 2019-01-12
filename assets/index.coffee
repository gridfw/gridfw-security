###*
 * Cookie parser for GridFW
 * @copyright khalid RAFIK 2018
###
'use strict'

cookie = require 'cookie'
CryptoJS = require('crypto-js')
AESCrypto = CryptoJS.AES

# reload
_parseCookies = null
module.exports=
	name: 'cookie-parser'
	# init/reload the plugin
	reload: (app, settings)->
		settings ?= Object.create null
		#=include _set-cookie.coffee
		#=include _parse-cookies.coffee
		# secret
		_secret = settings.secret
		throw new Error "settings.secret expected string or null" if _secret and typeof _secret isnt 'string'
		# cookie parser
		_parseCookies = parseCookie
		# enable
		# Context plugins
		Object.defineProperties app.Context.prototype,
			# get cookies
			cookies:
				get: _parseCookies
				configurable: on
			signedCookies:
				get: _parseCookies
				configurable: on
			# set cookie
			cookie:
				value: setCookie
				configurable: on
			clearCookie:
				value: clearCookie
				configurable: on
		# Request
		Object.defineProperties app.Request.prototype,
			cookies:
				get: _parseCookies
				configurable: on
			signedCookies:
				get: _parseCookies
				configurable: on
		return
	# disable the plugin
	# disable: (app)->
	# 	app.info 'cookie-parser', 'This plugin could not be disabled'
	# enable the plugin
	# enable: (app)->
	# 	return