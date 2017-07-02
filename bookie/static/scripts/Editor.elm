module Editor exposing (..)

import Bookmark exposing (Bookmark)
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)


type alias Model =
    { bookmark : Maybe Bookmark
    }


type Msg
    = CreateBookmark
    | EditBookmark Bookmark
    | SaveBookmark
    | DiscardChanges
    | EditTitle String
    | EditUrl String
    | EditDescription String


type EditorMsg
    = EditorSave Bookmark
    | NoOp


init : Model
init =
    Model Nothing



------------
-- Update --
------------


update : Msg -> Model -> ( Model, EditorMsg, Cmd msg )
update msg model =
    case msg of
        CreateBookmark ->
            ( { model | bookmark = Just Bookmark.empty }
            , NoOp
            , Cmd.none
            )

        DiscardChanges ->
            ( { model | bookmark = Nothing }
            , NoOp
            , Cmd.none
            )

        EditBookmark bookmark ->
            ( { model
                | bookmark =
                    Just
                        (Bookmark
                            bookmark.id
                            bookmark.title
                            bookmark.url
                            bookmark.description
                        )
              }
            , NoOp
            , Cmd.none
            )

        SaveBookmark ->
            ( { model | bookmark = Nothing }
            , EditorSave (withDefault (Bookmark.empty) model.bookmark)
            , Cmd.none
            )

        EditTitle title ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkEditing =
                    { bookmark | title = title }
            in
                ( { model | bookmark = Just bookmark }
                , NoOp
                , Cmd.none
                )

        EditUrl url ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkEditing =
                    { bookmark | url = url }
            in
                ( { model | bookmark = Just bookmarkEditing }
                , NoOp
                , Cmd.none
                )

        EditDescription description ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkEditing =
                    { bookmark | description = Just description }
            in
                ( { model | bookmark = Just bookmark }
                , NoOp
                , Cmd.none
                )



----------
-- View --
----------


view : Model -> Html Msg
view model =
    case model.bookmark of
        Just bookmark ->
            viewEditorForm bookmark

        Nothing ->
            div [ id "editor" ] []


viewEditorForm : Bookmark -> Html Msg
viewEditorForm bookmark =
    div
        [ id "editor" ]
        [ input
            [ class "editor-form editor-form-title"
            , defaultValue bookmark.title
            ]
            []
        , input
            [ class "editor-form editor-form-url"
            , defaultValue bookmark.url
            ]
            []
        , input
            [ class "editor-form editor-form-description"
            , defaultValue (withDefault "" bookmark.description)
            ]
            []
        ]
