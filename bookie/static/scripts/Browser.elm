module Browser exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Bookmark exposing (Bookmark)
import Maybe exposing (withDefault)


type alias Model =
    { selectedBookmark : Maybe Bookmark
    }


type Msg
    = SelectBookmark Bookmark
    | DeselectBookmark


type BrowserMsg
    = BrowserSelection (Maybe Bookmark)


init : Model
init =
    Model Nothing



------------
-- Update --
------------


update : Msg -> Model -> ( Model, BrowserMsg, Cmd msg )
update msg model =
    case msg of
        SelectBookmark bookmark ->
            ( { model | selectedBookmark = Just bookmark }
            , BrowserSelection (Just bookmark)
            , Cmd.none
            )

        DeselectBookmark ->
            ( { model | selectedBookmark = Nothing }
            , BrowserSelection Nothing
            , Cmd.none
            )



----------
-- View --
----------


view : Model -> Dict.Dict Int Bookmark -> Html Msg
view model bookmarks =
    div [ id "browser" ]
        [ viewBrowserTable model bookmarks ]


viewBrowserTable : Model -> Dict.Dict Int Bookmark -> Html Msg
viewBrowserTable model bookmarks =
    ul
        []
        (viewBrowserTableHeader
            :: (List.map
                    (\bkmk -> viewTableRow model bkmk)
                    (Dict.values bookmarks)
               )
        )


viewBrowserTableHeader : Html Msg
viewBrowserTableHeader =
    li
        []
        [ viewTableCell
            [ class "entry-header entry-title" ]
            [ text "Title" ]
        , viewTableCell
            [ class "entry-header entry-url" ]
            [ text "Url" ]
        , viewTableCell
            [ class "entry-header entry-description" ]
            [ text "Description" ]
        ]


viewTableRow : Model -> Bookmark -> Html Msg
viewTableRow model bookmark =
    let
        classes =
            case model.selectedBookmark of
                Just selectedBookmark ->
                    if selectedBookmark.id == bookmark.id then
                        "selected-row"
                    else
                        ""

                Nothing ->
                    ""
    in
        li
            [ onClick (SelectBookmark bookmark)
            , class classes
            ]
            [ viewTableCell
                [ class "entry-title" ]
                [ text bookmark.title ]
            , viewTableCell
                [ class "entry-url" ]
                [ a [] [ text bookmark.url ] ]
            , viewTableCell
                [ class "entry-description" ]
                [ text (withDefault "" bookmark.description) ]
            , viewTableCell
                [ class "entry-selector"
                , onClick (SelectBookmark bookmark)
                ]
                []
            ]


viewTableCell : List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg
viewTableCell attributes view_ =
    div attributes view_
