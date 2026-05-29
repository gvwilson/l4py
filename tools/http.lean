import Lean
import Std.Internal.Http.Data.URI
import Std.Internal.Http.Data.Request
import Std.Internal.Http.Internal
import Std.Internal.Async.TCP
import Std.Internal.Async.DNS
open Lean Std.Net Std.Http Std.Http.Internal Std.Internal.IO.Async

-- mccole: http
-- Fetch the body of a plain-HTTP URL using Lean's native HTTP library.
-- Returns none if the URL is malformed, DNS lookup fails,
-- or the TCP connection is refused.  HTTPS is not supported.
def fetchUrl (url : String) : IO (Option String) := do
  try
    -- parse the URL and extract host and port
    let some uri := URI.parse? url | return none
    let some auth := uri.authority | return none
    let host := toString auth.host
    let port : UInt16 := match auth.port with
      | .value p => p
      | _        => URI.Scheme.defaultPort uri.scheme
    -- resolve hostname to one or more IP addresses
    let addrs ← (DNS.getAddrInfo host "http").block
    let some ip := addrs[0]? | return none
    let sockAddr : SocketAddress := match ip with
      | .v4 a => .v4 { addr := a, port := port }
      | .v6 a => .v6 { addr := a, port := port }
    -- build the request target (path + query string)
    let pathStr :=
      let p := toString uri.path
      let q := toString uri.query
      if p.isEmpty then "/" ++ q else p ++ q
    let target := RequestTarget.originForm! pathStr
    let reqHead := (Request.get target
      |>.header! "Host"       host
      |>.header! "Connection" "close").line
    -- connect, send the request, and read the full response
    let client ← TCP.Socket.Client.mk
    (client.connect sockAddr).block
    (client.send (Encode.encode (v := .v11) .empty reqHead).toByteArray).block
    let mut raw : ByteArray := .empty
    let mut done := false
    while !done do
      match ← (client.recv? 4096).block with
      | none       => done := true
      | some chunk => raw := raw ++ chunk
    (client.shutdown).block
    -- strip response headers; body follows the first blank line
    let response := String.fromUTF8? raw |>.getD ""
    return match response.splitOn "\r\n\r\n" with
    | _ :: rest => some (String.intercalate "\r\n\r\n" rest)
    | []        => none
  catch _ =>
    return none
-- mccole: /http

-- mccole: main
def main (args : List String) : IO Unit := do
  let url := args.headD "http://httpbin.org/get"
  IO.println s!"fetching: {url}"
  match ← fetchUrl url with
  | none      => IO.println "request failed"
  | some body =>
    IO.println s!"status: ok ({body.length} bytes)"
    match Json.parse body with
    | .error e => IO.println s!"JSON parse error: {e}"
    | .ok v    =>
      match v with
      | Json.obj m =>
        for (k, val) in m.toList do
          IO.println s!"  {k}: {val}"
      | _ => IO.println s!"body: {body}"
-- mccole: /main
