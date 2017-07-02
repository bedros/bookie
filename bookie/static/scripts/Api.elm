module Api exposing (..)

import Http
import Json.Decode exposing (Value)
import Json.Decode as JsonD
import Json.Encode
import Debug exposing (log)


type Msg
    = Response (Result Http.Error Json.Decode.Value)


type ApiMsg
    = ApiData Data
    | ApiError Error
    | ApiNetworkError String


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


update : Msg -> ( ApiMsg, Cmd msg )
update msg =
    case msg of
        Response (Ok response) ->
            let
                resp =
                    handleResponse response

                _ =
                    log "Response of the decoding pipeline" resp
            in
                ( resp, Cmd.none )

        Response (Err error) ->
            ( ApiNetworkError (toString error), Cmd.none )


{-| msg is a wrapper type that will be provided by the client.
It should be able to accept a (Result Error a -> msg) as an argument.
-}
getBookmarks : (Msg -> msg) -> Cmd msg
getBookmarks wrapper =
    Http.send Response (getJson "http://localhost:5000/api/bookmarks")
        |> Cmd.map wrapper


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


handleResponse : Value -> ApiMsg
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
