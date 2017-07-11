module Api exposing (..)

import Http
import Json.Decode exposing (Value)
import Json.Decode as JsonD
import Json.Encode


type Msg
    = Response (Result Http.Error Json.Decode.Value)


type ApiMsg
    = ApiBookmarkConfirmation Data
    | ApiData Data
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
            in
                ( resp, Cmd.none )

        Response (Err error) ->
            ( ApiNetworkError (toString error), Cmd.none )



-----------
-- Utils --
-----------


handleResponse : Value -> ApiMsg
handleResponse value =
    case JsonD.decodeValue (JsonD.field "type" JsonD.string) value of
        Ok type_ ->
            case type_ of
                "bookmarks" ->
                    ApiData (Data type_ (decodeData value))

                "bookmarks insert confirmation" ->
                    ApiBookmarkConfirmation (Data type_ (decodeData value))

                "bookmarks update confirmation" ->
                    ApiBookmarkConfirmation (Data type_ (decodeData value))

                "bookmarks delete confirmation" ->
                    ApiBookmarkConfirmation (Data type_ (decodeData value))

                "error" ->
                    let
                        ( error_type, error_message ) =
                            decodeError value
                    in
                        ApiError (Error error_type error_message)

                _ ->
                    ApiError (Error "unknown type" type_)

        Err error ->
            ApiError (Error "decoding" error)


bookmarksApiAddress : String
bookmarksApiAddress =
    "http://localhost:5000/api/bookmarks"


{-| msg is a wrapper type that will be provided by the client.
It should be able to accept a (Result Error a -> msg) as an argument.
-}
getBookmarks : (Msg -> msg) -> Cmd msg
getBookmarks wrapper =
    Http.send Response (getJson bookmarksApiAddress)
        |> Cmd.map wrapper


postBookmark : (Msg -> msg) -> Value -> Cmd msg
postBookmark wrapper body =
    Http.send Response (postJson bookmarksApiAddress body)
        |> Cmd.map wrapper


putBookmark : (Msg -> msg) -> Value -> Cmd msg
putBookmark wrapper body =
    Http.send Response (putJson bookmarksApiAddress body)
        |> Cmd.map wrapper


deleteBookmark : (Msg -> msg) -> Value -> Cmd msg
deleteBookmark wrapper body =
    Http.send Response (deleteJson bookmarksApiAddress body)
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


postJson : String -> Value -> Http.Request Value
postJson url body =
    submitJson "POST" url body


putJson : String -> Value -> Http.Request Value
putJson url body =
    submitJson "PUT" url body


deleteJson : String -> Value -> Http.Request Value
deleteJson url body =
    submitJson "DELETE" url body


submitJson : String -> String -> Value -> Http.Request Value
submitJson method url body =
    Http.request
        { method = method
        , headers = []
        , url = url
        , body = Http.jsonBody body
        , expect = Http.expectJson Json.Decode.value
        , timeout = Nothing
        , withCredentials = False
        }


decodeError : Value -> ( String, String )
decodeError value =
    case JsonD.decodeValue errorDecoder value of
        Ok result ->
            ( result.type_, result.message )

        Err error ->
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
            data

        Err error ->
            Json.Encode.string error
