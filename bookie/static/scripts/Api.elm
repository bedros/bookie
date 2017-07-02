module Api exposing (..)

import Msg exposing (..)
import Http
import Json.Decode exposing (Value)
import Json.Decode as JsonD
import Json.Encode
import Debug exposing (log)


type ResponseType
    = ApiData Data
    | ApiError Error
    | ResponseError String
    | NoResponse


type alias Data =
    { type_ : String
    , data : Value
    }


type alias Error =
    { type_ : String
    , message : String
    }



------------
-- Update --
------------


update : Msg -> ResponseType
update msg =
    case msg of
        ApiResponse (Ok response) ->
            let
                resp =
                    handleResponse response

                _ =
                    log "Response of the decoding pipeline" resp
            in
                resp

        ApiResponse (Err error) ->
            ResponseError (toString error)

        _ ->
            NoResponse


getBookmarks : Cmd Msg
getBookmarks =
    Http.send ApiResponse (getJson "http://localhost:5000/api/bookmarks")


getJson : String -> Http.Request Value
getJson url =
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson Json.Decode.value
        , timeout = Nothing
        , withCredentials = False
        }


handleResponse : Value -> ResponseType
handleResponse value =
    case JsonD.decodeValue (JsonD.field "type" JsonD.string) value of
        Ok type_ ->
            case type_ of
                "error" ->
                    let
                        ( error_type, error_message ) =
                            decodeError value
                    in
                        ApiError (Error error_type error_message)

                _ ->
                    ApiData (Data type_ (decodeData value))

        Err error ->
            let
                _ =
                    log "Decoding error" error
            in
                ApiError (Error "decoding" error)


decodeError : Value -> ( String, String )
decodeError value =
    case JsonD.decodeValue errorDecoder value of
        Ok result ->
            ( result.type_, result.message )

        Err error ->
            let
                _ =
                    log "Decoding error" error
            in
                ( "decoding", error )


errorDecoder : JsonD.Decoder Error
errorDecoder =
    JsonD.map2
        Error
        (JsonD.field "error_type" JsonD.string)
        (JsonD.field "error_message" JsonD.string)


decodeData : Value -> Json.Encode.Value
decodeData value =
    case JsonD.decodeValue (JsonD.field "data" Json.Decode.value) value of
        Ok data ->
            log "Decoded data" data

        Err error ->
            Json.Encode.string error
