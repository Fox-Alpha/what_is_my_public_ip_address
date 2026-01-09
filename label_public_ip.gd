extends Label
##
## Label to get public IP ADDRESS
##
## Getting your public IP ADDRESS and shows in Label Text
## Using OnReady or Funx eg. on Button Click
##
## Using simple API from https://api.ipify.org
## Can get IP as JSON String {"ip":"46.142.242.20"}

## Request for Plain Text IP Format IPv4
static var HTTP_REQUEST_IPV4 : String = "https://api.ipify.org"
## Request for Plain Text IP Format IPv6
static var HTTP_REQUEST_IPV6 : String = "https://api6.ipify.org"
## Request for Plain Text IP Format IPv4 if available as IPv6
static var HTTP_REQUEST_IPV46 : String = "https://api64.ipify.org"
## Request for Plain Text IP Format IPv4 as JSON String
static var HTTP_REQUEST_IPV4_AS_JSON : String = "https://api.ipify.org/?format=json"
## Request for Plain Text IP Format IPv4 Alternate API Uri
static var HTTP_REQUEST_IPV4ALT := "https://api.ipy.ch/?format=json"
## Request for Plain Text IP Format IPv4 Using for Debuggung eg test errorhandling
static var _HTTP_REQUEST_IPV4DBGERR := "https//api.ipy.ch/?format=json"

## Reference to HTTPRequest Node
@onready var http_request: HTTPRequest = $HTTPRequest

## Option for JSON ot NOT
@export var ip_as_json :bool = false

## IP Format, not yet implemented
enum ipformat {
	IPV4,
	IPV6,
	IPV4_6
}

## Default format IPv4
@export var ip_format : ipformat = ipformat.IPV4

## When to querry
enum processrequest {
	on_ready,
	on_func
}
## Default Querry in funx eg. on button click
@export var process_request : processrequest = processrequest.on_func

## The resolved IP Address or Error MSG
@export var public_ip : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(_on_http_request_completed)
	if process_request == processrequest.on_ready:
		var _req = await http_requested()
		text = public_ip
		pass


## Callvack of HTTPRequest
func _on_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Anfrage abgeschlossen. Statuscode:", response_code)
	var json := JSON.new()
	if response_code == 200: # 200 OK bedeutet Erfolg
		var json_string := body.get_string_from_utf8() # Daten in String konvertieren
		if ip_as_json:
			var json_data := json.parse(json_string, true) # JSON parsen
			if json_data == OK:
				print("Erfolgreich geparste Daten:", json.get_parsed_text())
				# Greife auf Daten zu, z. B. den Namen der neuesten Version
				if typeof(json.data) == TYPE_DICTIONARY:
					public_ip = json.data.get("ip")
					print("Öffentliche IP Adresse: ", public_ip)
			else:
				printerr("Fehler beim Parsen der JSON-Daten. Nutzen RAW String: ", json.get_error_message())
				public_ip = json_string
				print("Öffentliche IP Adresse:", public_ip)
		else:
			public_ip = json_string
	else:
		print("HTTP-Anfrage fehlgeschlagen.")
		public_ip = "Fehler bei Abfrage"
	pass


## awaitable function
## returns request error
## or request_complete result array
func http_requested() -> Variant:
	if ip_as_json:
		#var uri := "https://api.ipy.ch/?format=json"
		http_request.set_tls_options(TLSOptions.client())

		var _e = http_request.request(_HTTP_REQUEST_IPV4DBGERR)
		print("Request send to: ", HTTP_REQUEST_IPV4_AS_JSON)
		if _e != OK:
			return [_e]
		pass
	else:
		var _e = http_request.request_raw(HTTP_REQUEST_IPV4)
		if _e != OK:
			return [_e]
		pass

	return await http_request.request_completed


## callable for button click
## sets the label Text
func _on_request_button_pressed() -> void:
	var req = await http_requested()
	if req[0] == OK:
		text = public_ip
	else:
		text = "Request gescheitert, " + error_string(req[0])
	pass # Replace with function body.
